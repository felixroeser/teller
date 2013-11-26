class Admin::FeedbacksController < ApplicationController
  before_action :set_feedback, only: [:show]

  # GET /feedbacks
  def index
    @feedbacks = Feedback.all
  end

  # GET /feedbacks/1
  def show
  end

  # DELETE /feedbacks/1
  def destroy
    @feedback.destroy
    redirect_to admin_feedbacks_url, notice: 'Feedback was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feedback
      @feedback = Feedback.find(params[:id])
    end

end
