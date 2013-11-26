class FillResolution < ActiveRecord::Migration
  def up
  	ImageFile.all.each do |image_file|
  		next unless image_file.resolutions.blank?

  		full_paths = Dir["#{image_file.out_path}/*"]

  		found_resolutions = full_paths.collect { |full_path| full_path.split('/').last.split('.').first }

                image_file.resolutions = []

  		ImageFile.resolutions.keys.map(&:to_s).each do |resolution|
  		  image_file.resolutions << resolution if found_resolutions.include?(resolution)
  		end

  		image_file.save
  	end
  end
end
