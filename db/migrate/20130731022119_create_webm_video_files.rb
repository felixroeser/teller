class CreateWebmVideoFiles < ActiveRecord::Migration
  def up
    say "Creating webm version for #{VideoFile.count} videos"
    VideoFile.pluck(:id).each do |video_file_id|
      VideoFileConverter.new.perform(video_file_id, 'to_webm') 
      say "...finished #{video_file_id}"
    end
  end
end
