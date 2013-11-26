class Albums::PromotionsController < ApplicationController
  
  before_action :set_album
  before_filter :authenticate_user!
  before_action :check_permissions

  def new
    if @album.subscribers.count == 0
      flash[:alert] = "Your album doesnt have any subscribers you could promote!"
      redirect_to @album
    end
  end

  def create
    @user = User.find(params[:subscriber_id])

    if @album.users.include?(@user)
      flash[:alert] = "#{@user.name} is already a co-owner"
      render action: 'new'
    elsif @user.blank? or @album.subscribers.exclude?(@user)
      flash[:alert] = 'Subscriber not found!'
      render action: 'new'    
    else
      CreatePromotion.perform_async(album_id: @album.id, user_id: @user.id)
      flash[:notice] = "#{@user.name} will become a co-owner shortly!"
      redirect_to @album
    end
  end

  private

  def set_album
    @album = Album.find(params[:album_id])
  end

  def check_permissions
    redirect_to '/' unless @album.editable_by(current_user)
  end

end
