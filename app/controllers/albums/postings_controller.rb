class Albums::PostingsController < ApplicationController
  before_action :set_album
  before_action :set_posting, except: [:index]

  before_filter :authenticate_user!
  before_action :check_permissions

  def index
    @postings = @album.postings.published.latest_first.includes(:media, :user).page(params[:page])
    enqueue_news_marker
  end

  def show
  end

  private

  def set_album
    @album = Album.find(params[:album_id])
  end

  def set_posting
    @posting = @album.postings.where(id: params[:id]).first
  end

  def check_permissions
    redirect_to '/' unless @album.readable_by(current_user)
  end

  def enqueue_news_marker
    NewsMarker.perform_async({
      action: 'destroy' , user_ids: [current_user.id], album_ids: [@album.id], posting_ids: @postings.map(&:id)
    })
  end

end
