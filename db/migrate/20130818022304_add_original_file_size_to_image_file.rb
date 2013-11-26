class AddOriginalFileSizeToImageFile < ActiveRecord::Migration

  class ImageFile < ActiveRecord::Base
  end

  def change
    add_column :image_files, :original_file_size, :integer

    ImageFile.reset_column_information
    reversible do |dir|
      dir.up do
        say "Getting file size for #{ImageFile.count} images"

        ImageFile.all.each do |image_file|
          image_file.original_file_size = File.size?("public/i/#{image_file.id}/original.#{image_file.extension}")
          image_file.save
        end
      end
    end

  end
end
