class ChangeResolutionOnVideoFile < ActiveRecord::Migration

  class VideoFile < ActiveRecord::Base
  end
  
  def up
  	remove_column :video_files, :resolutions
  	add_column :video_files, :resolutions, :hstore

    VideoFile.reset_column_information

    VideoFile.all.each do |video_file|

    	resolutions = Dir["public/v/#{video_file.id}/*.mp4"].collect { |s| s.split('/').last.split('.').first.to_i }.select { |s| s != 0 }.sort.reverse

    	video_file.resolutions = {}

    	resolutions.each do |res|
	      raw_meta  = `ffprobe -print_format json -show_format -show_streams -v quiet -i 'public/v/#{video_file.id}/#{res}.mp4'`
	      raw_meta = JSON.parse(raw_meta).with_indifferent_access
	      stream = raw_meta[:streams].find { |s| s[:codec_type] == 'video' }

        video_file.resolutions[res] = stream['width'].to_i
    	end

    	video_file.save
    end

  end

  def down
  	puts "There's no way back!"
  end
end
