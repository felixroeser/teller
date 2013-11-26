class SubscriptionsController < ApplicationController

  before_filter :authenticate_user!
  before_action :set_subscription, only: [:show, :destroy]

  def index
    @subscriptions = current_user.subscriptions.includes(:album)
  end

  def destroy
    @subscription.destroy
    redirect_to subscriptions_url, notice: 'Subscription was successfully destroyed.'
  end

  private 

  def set_subscription
    @subscription = current_user.subscriptions.where(id: params[:id]).first
  end


end