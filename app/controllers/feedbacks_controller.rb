class FeedbacksController < ApplicationController

  def index
    redirect_to new_feedback_path
  end

  # GET /feedbacks/new
  def new
    @feedback = Feedback.new
  end

  # POST /feedbacks
  def create
    @feedback = Feedback.new(feedback_params)

    if current_user
      @feedback.user = current_user
      @feedback.email = nil
    end

    if @feedback.save
      redirect_to current_user ? me_path : '/', notice: "Thank you for your message. We'll get back to you."
    else
      render action: 'new'
    end
  end

  private
    # Only allow a trusted parameter "white list" through.
    def feedback_params
      params.require(:feedback).permit(:email, :message, :subject)
    end
end
