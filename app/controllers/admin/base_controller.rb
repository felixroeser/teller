class Admin::BaseController < ApplicationController

  before_filter :authenticate_user!
  before_filter :ensure_admin

  private

  def ensure_admin
    raise ActionController::RoutingError.new('Not Found') unless current_user.admin?
  end

end