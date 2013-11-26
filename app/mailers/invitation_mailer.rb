class InvitationMailer < ActionMailer::Base
  default from: Teller::GLOBALS[:mailer][:default_from]

  def invite(invitation)
    @invitation = invitation
    @albums = @invitation.user.albums.where(id: invitation.album_ids)
    @pseudo_user = @invitation.recipient && @invitation.recipient.pseudo

    # Inline attachments
    @inline_thumbs = {}
    @albums.each do |album|
      @inline_thumbs[album.id] = album.postings.where(media_type: 'ImageFile').limit(3).latest_first.collect do |posting|
        key = "#{posting.media.id}.#{posting.media.extension}"
        attachments.inline[key] = File.read( posting.media.thumb_path(true) )
        key
      end
    end

    I18n.with_locale(@invitation.locale) do
      mail({
        to: @invitation.recipient_email,
        subject: I18n.t("invitation_mailer.invite.subject", inviter: @invitation.user.name)
      })
    end
  end

  def accepted(invitation)
    @invitation = invitation

    # See http://stackoverflow.com/questions/11097855/ruby-on-rails-3-2-mailer-localize-mail-subject-field
    I18n.with_locale(@invitation.user.locale) do
      mail({
        to: @invitation.user.email,
        subject: I18n.t("invitation_mailer.accepted.subject", recipient: @invitation.recipient.name)
      })
    end
  end

  def subscriptions_created(invitation)
    @invitation = invitation

    I18n.with_locale(@invitation.user.locale) do
      mail({
        to: @invitation.recipient.email,
        subject: "You subscribed to new albums"
      })    
    end
  end

  # InvitationMailer.rejected(Invitation.first).deliver
  def rejected(invitation)
    @invitation= invitation

    I18n.with_locale(@invitation.user.locale) do
      mail({
        to: @invitation.user.email,
        subject: I18n.t("invitation_mailer.rejected.subject", recipient: @invitation.recipient_email)
      })
    end
  end

end
