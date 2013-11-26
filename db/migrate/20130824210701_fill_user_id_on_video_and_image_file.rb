class FillUserIdOnVideoAndImageFile < ActiveRecord::Migration
  def up
    [ImageFile.all.to_a, VideoFile.all.to_a].flatten.each do |media|
      next unless media.posting
      
      media.user_id = media.posting.user_id
      media.save
    end
  end
end
