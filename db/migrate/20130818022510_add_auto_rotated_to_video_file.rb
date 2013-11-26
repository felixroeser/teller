class AddAutoRotatedToVideoFile < ActiveRecord::Migration
  def change
    add_column :video_files, :auto_rotated, :integer
  end
end
