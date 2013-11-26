class Albums::SubscriptionsController < ApplicationController

  before_filter :authenticate_user!

  before_action :set_album
  before_action :set_subscription, only: [:destroy]
  before_action :check_edit_permissions

  def index
    @subscriptions = @album.subscriptions.includes(:user).newest_first
  end

  def destroy
    @subscription.destroy

    flash[:notice] = "#{@subscription.user.name} is not subscriber in #{@album.title}!"

    if @album.subscriptions.exists? 
      redirect_to albums_subscriptions_url(album_id: @album.id)
    else
      redirect_to album_path(@album)
    end
  end

  private 

  def set_album
    @album = Album.where(id: params[:album_id]).first
  end

  def set_subscription
    @subscription = @album.subscriptions.where(id: params[:id]).first
  end

  def check_edit_permissions
    redirect_to albums_path unless @album.editable_by(current_user)
  end

end