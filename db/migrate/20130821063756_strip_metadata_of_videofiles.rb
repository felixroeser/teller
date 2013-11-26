class StripMetadataOfVideofiles < ActiveRecord::Migration
  def up
    VideoFile.all.each do |video_file|

      %w(webm mp4).each do |format|
        files = Dir["public/v/#{video_file.id}/*.#{format}"].select { |s| s.split('/').last.split('.').first.to_i != 0 }

        files.each do |file|
          FileUtils.mv File.expand_path(file, Rails.root), '/tmp/some_video'
          `ffmpeg -i /tmp/some_video -codec copy -map_metadata -1 #{file}`
        end

      end


    end
  end
end
