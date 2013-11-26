class AddFormatToImageFile < ActiveRecord::Migration

  class ImageFile < ActiveRecord::Base
    def full_path_for(resolution)
      "#{Rails.root}/public/i/#{self.id}/#{resolution}.#{self.extension}"
    end
  end

  def change
    add_column :image_files, :format, :string
    ImageFile.reset_column_information
    reversible do |dir|
      dir.up do
        say "Population format with #{ImageFile.count} existing objects"
        ImageFile.all.each do |image_file|
          format = MiniMagick::Image.open(image_file.full_path_for(:original))['format']
          image_file.update_attribute :format, format
        end
      end
    end
  end
end
