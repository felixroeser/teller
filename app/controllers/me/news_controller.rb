class Me::NewsController < ApplicationController
  before_filter :authenticate_user!

  def show
    @albums_with_news = current_user.albums_with_news

    redirect_to me_news_album_path(@albums_with_news.first.id) if @albums_with_news.size == 1
  end

end