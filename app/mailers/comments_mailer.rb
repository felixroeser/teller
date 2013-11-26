class CommentsMailer < ActionMailer::Base
  default from: Teller::GLOBALS[:mailer][:default_from]

  def created(comment)
    @comment = comment

    @inline_thumbs = [@comment.posting].collect do |posting|
      path = posting.media.thumb_path(true)
      file_name = "#{posting.media.id}_thumb.#{posting.media.extension}"
      attachments.inline[file_name] = File.read( path )
      file_name
    end

    mail({
      to: @comment.posting.album.users.map(&:email),
      reply_to: @comment.user.email,
      subject: t('comments_mailer.created.subject', album: @comment.posting.album.title, user: @comment.user.name)
    })
  end
end
