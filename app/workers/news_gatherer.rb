class NewsGatherer
  include Sidekiq::Worker
  sidekiq_options queue: :low


  def perform(interval =  'daily', opts = {})
    opts = opts.with_indifferent_access

    p = {
      blank: [],
      present: [],
      unchanged: []
    }

    Sidekiq.redis do |redis|

      p[:last_run], p[:newer_as] = last_run_and_newer_as(interval)
      
      redis.set("news:#{interval}:last_run_at", Time.now.to_i) unless opts[:debug]

      p[:eligible_album_ids] = eligible_album_ids(p[:newer_as])
      (p[:eligible_user_ids] = eligible_user_ids(p[:eligible_album_ids])).each do |user_id|
        new_posting_ids = new_postings_for_user_id(user_id)

        if new_posting_ids.blank?
          p[:blank] << user_id
          next
        end

        current_checksum = Digest::SHA1.hexdigest( new_posting_ids.join(',') )

        if current_checksum == (redis.get("news:u:#{user_id}:sender_checksum") || 'not_available')
          p[:unchanged] << user_id
          next
        end

        p[:present] << user_id

        unless opts[:debug]
          redis.set "news:u:#{user_id}:sender_checksum", current_checksum
          NewsSender.perform_async(action: 'digest', user_id: user_id) 
        end
      end

    end

    p
  end

  def last_run_and_newer_as(interval)
    Sidekiq.redis do |redis|
      last_run = redis.get("news:#{interval}:last_run_at")
      newer_as = if last_run
        Time.at(last_run.to_i)
      else
        1.day.ago
      end
      return [last_run, newer_as]
    end
  end 

  def eligible_album_ids(newer_as)
    Posting.where('created_at > ?', newer_as).uniq.pluck(:album_id).compact
  end

  def eligible_user_ids(album_ids)
    Subscription.where(album_id: album_ids).uniq.pluck(:user_id)
  end

  def new_postings_for_user_id(user_id)
    Sidekiq.redis do |redis|
      keys = Subscription.where(user_id: user_id).pluck(:album_id).collect { |aid| "news:u:#{user_id}:a:#{aid}" }
      return keys.present? ? redis.sunion(keys).sort : []
    end
  end

end