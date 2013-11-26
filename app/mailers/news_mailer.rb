class NewsMailer < ActionMailer::Base
  default from: Teller::GLOBALS[:mailer][:default_from]

  def digest(user, markers_by_album)
  	@user = user
  	@markers_by_album = markers_by_album
	  @albums = Album.where(id: @markers_by_album.keys).includes(:users)

    @inline_thumbs = Posting.where(id: @markers_by_album.values.flatten).latest_first.limit(5).includes(:media).collect do |posting|
      path = posting.media.thumb_path(true)
      file_name = "#{posting.media.id}_thumb.#{posting.media.extension}"
      attachments.inline[file_name] = File.read( path )
      file_name
    end

    I18n.with_locale(@user.locale) do
    	mail({
    		to: @user.email,
    		subject: t('news_mailer.digest.subject', albums: @albums.map(&:title).join(', '))
    	})
    end
  end
end
