class NewPostingFromVideoFile
  include Sidekiq::Worker
  sidekiq_options queue: :expensive

  def perform(payload={})
    payload = payload.with_indifferent_access
    ap payload

    user = User.where(id: payload[:user_id]).first
    return [nil, 'user_doesnt_exist'] unless user

    full_path = payload[:media][:full_path]
    return [nil, 'file_doesnt_exist'] unless File.exist?(full_path)

    file_name = payload[:media][:file_name] || full_path.split('/').last 
    extension = payload[:media][:extension] || file_name.split('.').last.downcase
    sha1      = payload[:media][:sha1]      || `shasum '#{full_path}'`.split(' ').first

    meta      = parse_meta(full_path)
    return [nil, 'invalid_video'] unless meta
    ap meta

    video_file = if payload[:posting_id]
      Posting.find(payload[:posting_id]).media
    else
      VideoFile.create(original_name: file_name, extension: extension, sha1: sha1, user_id: user.id)    
    end

    FileUtils.mkdir_p video_file.out_path

    cmd = generate_convert_command(video_file, full_path, meta)
    ap ['converting', video_file.id, video_file.out_path, cmd]
    `#{cmd}`

    # copy or move original
    if payload[:keep_tempfile]
      target = File.expand_path("#{video_file.out_path}/original.#{extension}")
      FileUtils.copy(full_path, target) unless target == full_path
    else
      FileUtils.mv full_path, "#{video_file.out_path}/original.#{extension}"
      FileUtils.remove_dir full_path.split('/')[0..-2].join('/') rescue nil
    end

    # Update video_file
    video_file.original_width = meta[:width]
    video_file.original_height = meta[:height]
    video_file.original_duration = meta[:duration].to_i
    video_file.original_file_size = meta[:file_size]
    video_file.duration = meta[:duration] > 150 ? 150 : meta[:duration].to_i
    video_file.ratio = meta[:width] > meta[:height] ? meta[:width] / meta[:height].to_f : meta[:height] / meta[:width].to_f
    video_file.state = 'imported'
    video_file.resolutions = calc_resolutions_and_rotations(meta).inject({}) { |h, (height, data)| h[height] = data[:width] ; h }
    video_file.auto_rotated = meta[:rotation] if meta[:rotation] != 0
    video_file.orientation = [90, 270].include?(meta[:rotation]) ? 1 : 0
    video_file.save

    posting_attrs = {
      user: user,
      recorded_at: meta[:recorded_at],
      geo_lat: meta[:location].first,
      geo_long: meta[:location].last,
      media: video_file,
      disc_usage: `du -s 'public/v/#{video_file.id}'`.split("\t").first.to_i * 1024
    }

    if payload[:posting_id]
      posting = Posting.find(payload[:posting_id])
      posting.update_attributes posting_attrs
    else
      # Create posting
      posting = Posting.create(posting_attrs.merge(state: 'blank'))

      UpdatePosting.perform_async(id: posting.id, action: 'created')
    end

    logger.info "...posting #{posting.id} created"

    [posting.id, nil]
  end

  private  

  def calc_resolutions_and_rotations(meta)
    out = {}

    VideoFile.encoding_params.each do |res, p|
      # ap [res, meta[:height], meta[:width], res < meta[:width], res < meta[:height]]
      next if res > meta[:width] && res > meta[:height]

      # FIXME no need to set all attrs over and over again
      out[res] = {
        scale: meta[:height] / res.to_f,
        ratio: meta[:width] > meta[:height] ? meta[:width] / meta[:height].to_f : meta[:height] / meta[:width].to_f,
        height: res,
        width: (meta[:width] / (meta[:height] / res.to_f)).to_i,
        duration: meta[:duration] > 150 ? 150 : meta[:duration],
        cut: meta[:duration] > 150,
      }

      if meta[:rotation] != 0

        out[res][:rotation], out[res][:flip] =  case meta[:rotation]
        when 90
          [1, nil]
        when 180
          [nil, [:hflip,:vflip]]
        when 270
          [2, nil]
        end

        if [90, 270].include?(meta[:rotation])
          out[res][:width] = (out[res][:height] / out[res][:ratio]).to_i
        end
      end

      # h264 needs % 2
      out[res][:width] += 1 unless out[res][:width] % 2 == 0
    end

    out
  end

  def generate_convert_command(video_file, in_full_path, meta)

    ap rar = calc_resolutions_and_rotations(meta)
    out_path = video_file.out_path

    [
      "ffmpeg -y -i #{in_full_path} -threads #{Teller::GLOBALS[:ffmpeg][:threads]}",
      webm_commands(meta, rar, out_path),
      mp4_commands(meta, rar, out_path),
      poster_commands(meta, rar, out_path),
      thumbnail_commands(meta, rar, out_path)
    ].flatten.join(" ")
  end

  def webm_commands(meta, rar, out_path)
    rar.collect do |res, p|
      enc_p = VideoFile.encoding_params[res][:webm]

      # Lower the bitrate for portrait mode
      bitrate = p[:height] > p[:width] ? (enc_p[:bitrate] / (p[:height] / p[:width].to_f) ).to_i : enc_p[:bitrate]

      [
        meta[:cutter] ? "-t #{meta[:duration]}" : nil,
        "-c:v libvpx",
        "-b:v #{bitrate}k",
        "-vf '#{vf_arg(p)}'",
        "-c:a libvorbis",
        "-ab #{enc_p[:abitrate] || 128}k",
        "-map_metadata -1",
        "#{out_path}/#{res}.webm"
      ].compact.join(' ')
    end
  end

  def mp4_commands(meta, rar, out_path)
    # TODO copy audio and video is already the right coded is present

    rar.collect do |res, p|
      enc_p = VideoFile.encoding_params[res][:mp4]

      [
        meta[:cutter] ? "-t #{meta[:duration]}" : nil,
        '-vcodec libx264',
        '-tune film',
        "-preset #{enc_p[:preset]}",
        "-crf #{enc_p[:crf]}",
        "-vprofile #{enc_p[:profile]}",
        "-vf '#{vf_arg(p)}'",
        "-acodec libvo_aacenc",
        "-ac 2",
        "-ar 44100",
        "-ab #{enc_p[:abitrate] || 128}k",
        "-map_metadata -1",
        "#{out_path}/#{res}.mp4"
      ].compact.join(' ')
    end
  end

  def poster_commands(meta, rar, out_path)
    rar.collect do |res, p|
      [
        "-ss 1",
        "-vframes 1",
        "-vf '#{vf_arg(p)}'",
        "-vcodec png",
        "-f image2",
        "#{out_path}/poster_#{res}.png"
      ].compact.join(' ')
    end
  end

  def thumbnail_commands(meta, rar, out_path)
    p = rar.first.last

    [
      "-ss 1",
      "-vframes 1",
      "-vf '#{vf_arg(p.dup.merge({fix_scale: meta[:width] > meta[:height] ? '140:-1' : '-1:140'}))}'",
      "-vcodec png",
      "-f image2",
      "#{out_path}/thumb.png"      
    ].join(' ')
  end

  def vf_arg(p)
    [
      p[:rotation] ? "transpose=#{p[:rotation]}" : nil,
      p[:flip] ? p[:flip] : nil,  # see http://blog.adruna.org/2010/12/ffmpeg-video-rotation-filter/
      p[:fix_scale] ? "scale=#{p[:fix_scale]}" : "scale=#{p[:width]}x#{p[:height]}"
      # "scale=#{p[:width]}x#{p[:height]}"
    ].flatten.compact.join(',')
  end


  def parse_meta(full_path)
    raw_meta  = `ffprobe -print_format json -show_format -show_streams -v quiet -i '#{full_path}'`
    return nil unless raw_meta

    raw_meta = JSON.parse(raw_meta).with_indifferent_access

    meta = {}

    stream = (raw_meta[:streams] || []).find { |s| s[:codec_type] == 'video' }
    return nil unless stream

    meta[:width] = stream['width']
    meta[:height] = stream['height']
    meta[:duration] = stream['duration'].to_f
    meta[:rotation] = stream['tags']['rotate'].to_i
    meta[:recorded_at] = Time.parse stream['tags']['creation_time'] rescue nil
    meta[:file_size] = File.size?(full_path)
    meta[:location] = if raw_meta['format']['tags']['location'] =~ /((?:\+|\-)\d+.\d+)((?:\+|\-)\d+.\d+)/
      [$1, $2]
    else
      [nil, nil]
    end rescue nil

    meta
  end

end
