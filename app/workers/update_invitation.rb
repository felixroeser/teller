class UpdateInvitation
  include Sidekiq::Worker

  def perform(opts)
    opts = opts.with_indifferent_access

    logger.info "Updating invitation #{opts[:id]}... with #{opts[:action]}"

    invitation = Invitation.find_by_id(opts[:id])

    if invitation.blank?
      logger.info "... invitation #{opts[:id]} not found!"
      return
    end

    case opts[:action]
    when 'created'
      after_created(invitation)
    when 'accept'
      acting_user = User.find opts[:acting_user_id]
      accept(invitation, acting_user)
    when 'reject'
      reject(invitation)
    end
      
  end

  private

  def after_created(invitation)
    recipient = User.where(email: invitation.recipient_email).first

    # Shall we create a pseudo user?
    if recipient.blank?
      create_pseudo_user!(invitation)
    else
      invitation.recipient = recipient
      invitation.save
    end

    InvitationMailer.invite(invitation).deliver
  end

  def create_pseudo_user!(invitation)
    password = `pwgen -N 1`.chomp

    user = User.create({
      email: invitation.recipient_email,
      name: invitation.recipient_email.split('@').first,
      password: password,
      password_confirmation: password,
      pseudo_password: password,
      pseudo: true,
      reviewed: false
    })

    invitation.recipient = user
    invitation.save

    invitation
  end

  def accept(invitation, acting_user)
    return unless invitation.open?

    pseudo_recipient = if invitation.recipient.pseudo && invitation.recipient != acting_user
      invitation.recipient
    else
      nil
    end

    invitation.state = 'accepted'
    invitation.accepted_at = Time.now
    invitation.recipient = acting_user
    if invitation.save
      # Create subscriptions
      subscriptions = invitation.user.albums.where(id: invitation.album_ids).collect do |album|
        subscription = Subscription.new(user: acting_user, album: album)
        subscription.save ? subscription : nil
      end.compact

      InvitationMailer.accepted(invitation).deliver
      InvitationMailer.subscriptions_created(invitation).deliver
      pseudo_recipient.destroy if pseudo_recipient
    else
      false
    end
  end

  def reject(invitation)
    return unless invitation.open?

    invitation.state = 'rejected'
    invitation.rejected_at = Time.now
    invitation.save

    # Mail the inviter
    
    true
  end

end