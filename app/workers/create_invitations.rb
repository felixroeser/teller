class CreateInvitations
  include Sidekiq::Worker

  def perform(opts)
    opts = opts.with_indifferent_access

    logger.info "Creating invitations..."

    ap opts

    user = User.find(opts[:user_id])
    albums = user.albums.where(id: opts[:album_ids])
    recipient_emails = opts[:recipient_emails]

    if user.blank? or albums.blank? or recipient_emails.blank?
      logger.info "...skipping as input is blank"
      return
    end

    invitations = recipient_emails.collect do |recipient_email|
      # Create the invitation
      invitation = Invitation.new({
        user: user, 
        album_ids: albums.map(&:id), 
        recipient_email: recipient_email, 
        state: 'open',
        message: opts[:message].present? ? opts[:message] : nil,
        locale: opts[:locale] || 'en'
      })
      invitation.save ? invitation : nil
    end.compact

    logger.info "... created #{invitations.size} invitations: #{invitations.map(&:id).join(', ')}"

  end
end