class ImageFilesController < ApplicationController

  def show
  	@image_file = ImageFile.where(id: params[:id]).first

  	redirect_to(@image_file.posting || postings_path)
  end

  def rotate
    degrees = params[:degrees].to_i
    
    @image_file = ImageFile.where(id: params[:id]).first

    ImageFileRotator.perform_async(params[:id], degrees) if degrees != 0
  end
end