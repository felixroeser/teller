class AddOriginalFileSizeAndOriginalDurationToVideoFile < ActiveRecord::Migration

  class VideoFile < ActiveRecord::Base
  end

  def change
    add_column :video_files, :original_file_size, :integer
    add_column :video_files, :original_duration, :integer

    VideoFile.reset_column_information
    reversible do |dir|
      dir.up do
        say "Getting file size and duration for #{VideoFile.count} videos"

        VideoFile.all.each do |video_file|
          video_file.original_file_size = File.size?("public/v/#{video_file.id}/original.#{video_file.extension}")
          video_file.original_duration = video_file.duration
          video_file.save
        end
      end
    end

  end
end
