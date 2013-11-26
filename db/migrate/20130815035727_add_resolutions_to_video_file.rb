class AddResolutionsToVideoFile < ActiveRecord::Migration
  def change
    add_column :video_files, :resolutions, :string, array: true
  end
end
