class ImportMediaFromBoxNet
  include Sidekiq::Worker
  # sidekiq_options queue: "medium"

  def perform(payload={})
    payload = payload.with_indifferent_access

    ap payload

    return unless payload[:box_user_id] || payload[:box_folder_id].to_i == 0

    # Find the MediaSource and User
    media_source = MediaSource.
      where(provider:'boxnet').
      where("meta -> 'user_id' = :user_id", user_id: payload[:box_user_id]).
      first

    user = media_source.user

    ap ['mediasource?', media_source.present?, 'user?', user.present?]

    return unless media_source && user

    logger.info 'Token check'

    ap media_source.meta

    session = create_boxnet_session(media_source.meta['token'])
    session = check_session(session, media_source)

    logger.info 'Downloading...'

    # Get the folder name
    # s.get 'https://api.box.com/2.0/folders/967183305'
    folder = session.get("https://api.box.com/2.0/folders/#{media_source.meta['dir_id']}")

    file, error = download(session, payload[:box_file_name], folder['name'] )

    if file[:path] && !error
      logger.info "Download successful #{file[:path]}"
      media = {
        file_name: payload[:box_file_name],
        extension: payload[:box_file_extension],
        full_path: file[:path],
        sha1:      file[:file].sha1
      }

      enqueue_media(media, media_source, user)
    else
      logger.error "Download failed"
    end
  end

  private

  def check_session(session, media_source)
    session.get 'https://api.box.com/2.0/users/me'
    session
  rescue # RubyBox::AuthError => ex
    ap ['refresh needed', session.refresh_token(media_source.meta['refresh_token'])]

    token, refresh_token = [
      session.instance_variable_get('@access_token').token,
      session.instance_variable_get('@access_token').refresh_token
    ]

    ap ['updating token', token, refresh_token]

    media_source.meta = media_source.meta.merge({'token' => token, 'refresh_token' => refresh_token })
    media_source.save

    session
  end

  def create_boxnet_session(token)
    RubyBox::Session.new({
      client_id: CONFIG[:boxnet][:client_id],
      client_secret: CONFIG[:boxnet][:secret],
      access_token: token
    })
  end

  def download(session, filename, dir)
    ap session
    logger.info "Downloading from box.net #{filename} from #{dir}"

    # Get meta infos
    client = RubyBox::Client.new(session)

    remote_path = "/#{dir}/#{filename}"

    file = client.file(remote_path)

    path = "/tmp/#{file.sha1}"

    logger.info "...to #{path}/#{filename}"

    FileUtils.mkdir_p path

    f = open("#{path}/#{filename}", 'wb')
    f.write( file.download )
    f.close

    [{path: "#{path}/#{filename}", file: file}, nil]
  end

  def enqueue_media(media, media_source, user)
    ap media
    if ImageFile.extension_supported?(media[:extension])
      NewPostingFromImageFile.perform_async(media: media, media_source_id: media_source.id, user_id: user.id)
    elsif VideoFile.extension_supported?(media[:extension])
      NewPostingFromVideoFile.perform_async(media: media, media_source_id: media_source.id, user_id: user.id)
    else
      logger.warn "...unsupported extension"        
    end    
  end

end