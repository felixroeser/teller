class FeedbacksMailer < ActionMailer::Base
  default from: Teller::GLOBALS[:mailer][:default_from]

  def created(feedback)
    @feedback = feedback

    mail({
      to: Teller::GLOBALS[:mailer][:default_from],
      reply_to: @feedback.user ? @feedback.user.email : @feedback.email,
      subject: "New user feedback"
    })
  end
end
