# max_albums
class UserSetMaxAlbums
  include Sidekiq::Worker

  def perform(opts)
    opts = opts.with_indifferent_access

    logger.info "UserSetMaxAlbums..."
    ap opts

    user  = User.find(opts[:user_id])

    return if user.blank?

    user.max_albums = (opts[:max_albums] || 5).to_i
    user.save

    # Send out a nice email
    UserMailer.can_create_albums_now(user).deliver

  end

end