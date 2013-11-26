class NewsSender
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform(opts={})
    opts = opts.with_indifferent_access

    case opts[:action]
    when 'digest'
      send_user_digest(opts[:user_id])
   	end
  end

  private

  
  def send_user_digest(user_id)

    user = User.where(id: user_id).first
    return if user.nil?

    markers_by_album = user.markers_by_album
    return if markers_by_album.blank?

    NewsMailer.digest(user, markers_by_album).deliver
  end

end  