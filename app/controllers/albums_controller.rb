class AlbumsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_album, only: [:show, :edit, :update, :destroy]

  before_action :can_create_album, only: [:new, :create]
  before_action :check_edit_permissions, only: [:show, :edit, :update, :destroy]

  # GET /albums
  def index
    redirect_to me_path(anchor: 'albums')
  end

  # GET /albums/1
  def show
  end

  # GET /albums/new
  def new
    @album = Album.new
  end

  # GET /albums/1/edit
  def edit
  end

  # POST /albums
  def create
    @album = Album.new(album_params)

    if !current_user.albums_left?
      redirect_to albums_path, alert: 'No cant create more albums!'
    elsif @album.save
      @album.users << current_user
      if current_user.album_ownerships.count > 1
        redirect_to @album, notice: 'Album was successfully created.'
      end
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /albums/1
  def update
    if @album.update(album_params)
      redirect_to @album, notice: 'Album was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /albums/1
  def destroy
    @album.destroy
    redirect_to me_path, notice: 'Album was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_album
      @album = current_user.albums.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def album_params
      params.require(:album).permit(:title, :state, :display_age, :begins_at)
    end

    def can_create_album
      redirect_to "/subscriptions" unless current_user.can_create_album?
    end

    def check_edit_permissions
      redirect_to "/albums/#{@album.id}/postings" unless @album.editable_by(current_user)
    end
end
