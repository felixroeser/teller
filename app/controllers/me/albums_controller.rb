class Me::AlbumsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_album


  def show
    posting_ids = []
    Sidekiq.redis do |redis|
      posting_ids = redis.smembers "news:u:#{current_user.id}:a:#{@album.id}"
    end

    @postings = Posting.where(id: posting_ids).published.oldest_first.includes(:media, :album).page(params[:page])

    enqueue_news_marker
  end

  private

  def set_album
    @album = Album.find(params[:id])
  end

  # FIXME not dry with Album::PostingsController
  def enqueue_news_marker
    NewsMarker.perform_async({
      action: 'destroy' , user_ids: [current_user.id], album_ids: [@album.id], posting_ids: @postings.map(&:id)
    })
  end



end