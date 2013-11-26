class FillOrientationOnVideoFiles < ActiveRecord::Migration
  def up
    VideoFile.all.each do |video_file|
      next if video_file.orientation.present?

      raw_meta  = `ffprobe -print_format json -show_format -show_streams -v quiet -i 'public/v/#{video_file.id}/original.#{video_file.extension}'`
      return nil unless raw_meta

      raw_meta = JSON.parse(raw_meta).with_indifferent_access
      stream = raw_meta[:streams].find { |s| s[:codec_type] == 'video' }
      return nil unless stream

      video_file.orientation = [90, 270].include?(stream['tags']['rotate'].to_i) ? 1 : 0
      video_file.save
    end
  end
end
