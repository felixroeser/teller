class AlbumOwnershipsMailer < ActionMailer::Base
  default from: Teller::GLOBALS[:mailer][:default_from]

  def created(album_ownership)
    @album_ownership = album_ownership

    attachments['album.vcf'] = {
      mime_type: 'text/vcard',
      content: @album_ownership.user.vcard
    }

    mail({
      to: @album_ownership.user.email,
      subject: t('album_ownerships_mailer.created.subject', album: @album_ownership.album.title)
    })
  end
end
