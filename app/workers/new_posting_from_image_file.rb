class NewPostingFromImageFile
  include Sidekiq::Worker
  sidekiq_options queue: :expensive

  def perform(payload={})
    payload = payload.with_indifferent_access
    ap payload

    user = User.where(id: payload[:user_id]).first

    full_path = payload[:media][:full_path]
    file_name = payload[:media][:file_name]
    extension = payload[:media][:extension]
    sha1      = payload[:media][:sha1]

    ap ['user?', user.present?, 'exists?', File.exist?(full_path), full_path,file_name, extension]

    return unless user && File.exist?(full_path)

    image_file = ImageFile.create(original_name: file_name, extension: extension, sha1: sha1, user_id: user.id)

    FileUtils.mkdir_p image_file.out_path

    image_file.original_width, image_file.original_height, image_file.ratio, image_file.resolutions = resize(image_file.out_path, full_path, extension)
    copy_original(image_file.out_path, full_path, extension)

    image_file.format, image_file.orientation, meta_data = get_meta(full_path)
    image_file.state = 'imported'
    image_file.original_file_size = File.size?(full_path)
    image_file.save

    meta_data[:disc_usage] = `du -s '#{image_file.out_path}'`.split("\t").first.to_i * 1024

    logger.info "...resized to #{image_file.out_path} and saved!"

    posting = Posting.create(meta_data.merge({user: user, media: image_file, state: 'blank'}))

    UpdatePosting.perform_async(id: posting.id, action: 'created')

    logger.info "...posting #{posting.id} created"

    unless payload[:keep_tempfile]
      FileUtils.remove_dir full_path.split('/')[0..-2].join('/') rescue nil
    end

    [posting.id, nil]
  end

  private

  def get_meta(in_full_path)
    image = MiniMagick::Image.open(in_full_path)

    format = image['format']
    orientation = image['EXIF:orientation'].to_i
    meta = {}

    if format == 'JPEG'
      exifr = EXIFR::JPEG.new(in_full_path)

      meta[:recorded_at] = exifr.date_time
      if exifr.gps.present?
        meta[:geo_long] = exifr.gps.latitude
        meta[:geo_lat] = exifr.gps.longitude
      end
    end

    [format, orientation, meta]
  end

  def copy_original(out_path, full_path, extension)
    FileUtils.copy full_path, "#{out_path}/original.#{extension}"
  end

  def resize(out_path, in_full_path, extension)
    image = MiniMagick::Image.open(in_full_path)

    original_width  = image["width"]
    original_height = image["height"]
    ratio           = original_width / original_height.to_f

    resolutions = ImageFile.resolutions.collect do |name, opts|
      faktor = opts[:max] / [original_width, original_height].max.to_f

      next if faktor >= 1

      new_width  = original_width * faktor
      new_height = original_height * faktor

      image.resize [new_width, new_height].join('x')
      image.quality "85"
      image.strip

      image.write "/#{out_path}/#{name}.#{extension}"
      name
    end.compact

    [original_width, original_height, ratio, resolutions]
  end

  def move_original
    # TBI
  end

end
