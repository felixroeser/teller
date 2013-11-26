require 'digest/sha1'

class UploadsController < ApplicationController

  before_filter :authenticate_user!, except: [:show]
  before_action :check_permissions, except: [:index, :show]

  def index
    redirect_to new_upload_path
  end

  def new
  end

  def create
    uploaded_io = params[:file]

    path = "/tmp/#{Digest::SHA1.hexdigest([current_user.id, uploaded_io.original_filename].join(':'))}"
    filename = uploaded_io.original_filename
    extension = filename.split('.').last.downcase
    full_path = "#{path}/#{filename}"

    Rails.logger.info "...saving uploaded file to #{path}/#{filename}"

    FileUtils.mkdir_p path

    File.open(full_path, 'wb') do |file|
      file.write(uploaded_io.read)
    end

    shasum = `shasum '#{full_path}'`.split(' ').first

    media = {
      file_name: filename,
      extension: extension,
      full_path: full_path,
      sha1: shasum
    }

    ap media

    if ImageFile.extension_supported?(media[:extension])
      NewPostingFromImageFile.perform_async(media: media, user_id: current_user.id)
    elsif VideoFile.extension_supported?(media[:extension])
      NewPostingFromVideoFile.perform_async(media: media, user_id: current_user.id)
    else
      Rails.logger.warn "...unsupported extension"
    end

  end

  private

    def check_permissions
      redirect_to '/' unless current_user.can_create_album? || current_user.has_albums?
    end

end