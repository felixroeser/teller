class ReprocessVideosWithFfmpeg < ActiveRecord::Migration
  def up
    VideoFile.all.each do |video_file|
      next if video_file.posting.blank?

      # Delete deprecated files
      Dir["#{video_file.out_path}/*"].
        select { |full_path| full_path.split('/').last.split('.').first != 'original' }.
        each { |full_path| FileUtils.rm full_path }

      NewPostingFromVideoFile.new.perform({
        user_id: video_file.user_id,
        posting_id: video_file.posting.id,
        media: {
          full_path: "#{video_file.out_path}/original.#{video_file.extension}"
        },
        keep_tempfile: true
      })
    end
  end
end
