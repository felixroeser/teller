class UpdateAlbumOwnership
  include Sidekiq::Worker

  def perform(opts)
    opts = opts.with_indifferent_access

    logger.info "Updating AlbumOwnership #{opts[:album_id]} #{opts[:user_id]}... with #{opts[:action]}"

    album_ownership = AlbumOwnership.where(album_id: opts[:album_id], user_id: opts[:user_id]).first

    if album_ownership.blank?
      logger.info "... album_ownership not found!"
      return
    end

    case opts[:action]
    when 'created'
      after_created(album_ownership)
    end
      
  end

  private

  def after_created(album_ownership)
    # Send out an email
    AlbumOwnershipsMailer.created(album_ownership).deliver
  end

end