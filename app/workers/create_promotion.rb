class CreatePromotion
  include Sidekiq::Worker

  def perform(opts)
    opts = opts.with_indifferent_access

    logger.info "Creating promotion..."
    ap opts

    album = Album.find(opts[:album_id])
    user  = User.find(opts[:user_id])

    return if album.blank? or user.blank?
    return if album.users.include?(user) or album.subscribers.exclude?(user)

    # FIXME add unique index and use a transaction
    ActiveRecord::Base.transaction do
      Subscription.where(album_id: album.id, user_id: user.id).destroy_all
      AlbumOwnership.create(album: album, user: user, role: 'coowner')
    end
  end

end