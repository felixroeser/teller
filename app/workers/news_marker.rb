require 'digest/sha1'

class NewsMarker
  include Sidekiq::Worker

  def perform(opts={})
    opts = opts.with_indifferent_access

    Sidekiq.redis do |redis|

      case opts[:action]
      when 'destroy'
        destroy_markers(opts, redis)
      when 'create'
        create_markers(opts, redis)
      end

    end
  end

  private

  def destroy_markers(opts, redis)
    opts[:user_ids].product(opts[:album_ids]).each do |user_id, album_id|
      if opts[:posting_ids].present?
        redis.srem "news:u:#{user_id}:a:#{album_id}", opts[:posting_ids]
      else
        redis.del "news:u:#{user_id}:a:#{album_id}"
      end
    end    
  end

  def create_markers(opts, redis)
    opts[:user_ids].product(opts[:album_ids]).each do |user_id, album_id|        
      redis.sadd "news:u:#{user_id}:a:#{album_id}", opts[:posting_ids] if opts[:posting_ids].present?
    end    
  end

end
