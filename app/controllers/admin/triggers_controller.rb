class Admin::TriggersController < ApplicationController
  protect_from_forgery except: :create

  before_filter :ensure_auth_token

  # Cron this:
  # curl -F auth_token=12345 -F trigger=news_gatherer.daily http://localhost:3000/admin/triggers
  def create
    enqueue_job(params[:trigger])

    render text: 'okay', status: 202
  end

  private

  def enqueue_job(trigger = nil)
    case trigger.try(:downcase)
    when 'news_gatherer.daily'
      NewsGatherer.perform_async('daily')
    end
  end

  def ensure_auth_token
    raise ActionController::RoutingError.new('Not Found') unless params[:auth_token].present? && params[:auth_token] == CONFIG[:admin_token]
  end

end