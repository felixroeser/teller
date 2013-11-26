class UpdateFeedback
  include Sidekiq::Worker

  def perform(opts)
    opts = opts.with_indifferent_access

    feedback = Feedback.find_by_id opts[:id]

    case opts[:action]
    when 'created'
      after_created(feedback)
    end
  end

  private

  def after_created(feedback=nil)
    return if feedback.blank?

    FeedbacksMailer.created(feedback).deliver
  end

end
