class PostingMailer < ActionMailer::Base
  default from: Teller::GLOBALS[:mailer][:default_from]

  def published_notify_coowners(posting, owners)
    @posting = posting

    if @posting.media.is_a?(ImageFile)
      path = "./public" + @posting.media.image_path_for('low')

      attachments[ path.split('/').last ] = {
        mime_type: "image/#{@posting.media.extension}",
        content: File.read(path)
      }
    else
      path = "./public" + @posting.media.poster_path

      attachments['poster.png'] = {
        mime_type: "image/png",
        content: File.read(path)
      }
    end

    mail({
      to: owners.map(&:email),
      subject: "#{@posting.user.name} posted #{@posting.title} in #{@posting.album.title}"
    })    
  end

  def created_notify_poster(posting)
    @posting = posting

    I18n.with_locale(@posting.user.locale) do
      mail({
        to: @posting.user.email,
        subject: I18n.t("posting_mailer.created_notify_poster.subject")
      })
    end
  end
end
