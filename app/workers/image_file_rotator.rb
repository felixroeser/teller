class ImageFileRotator
  include Sidekiq::Worker
  sidekiq_options queue: :expensive

  def perform(image_file_id,degrees=0)
  	return if degrees == 0
  	return unless image_file = ImageFile.find(image_file_id)

  	ap ['ImageFileRotator', image_file_id, degrees]

  	['original'].concat(image_file.resolutions).each do |file_name|
  		full_path = "#{image_file.out_path}/#{file_name}.#{image_file.extension}"
  		image = MiniMagick::Image.open(full_path)
  		image.rotate degrees
  		image.write full_path
  	end 

  end
end
