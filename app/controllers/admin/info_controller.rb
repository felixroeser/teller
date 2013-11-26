class Admin::InfoController < Admin::BaseController

  def news_gatherer
    @data = NewsGatherer.new.perform('daily', debug: true)
  end


end