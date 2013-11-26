class UpdatePosting
  include Sidekiq::Worker

  def perform(opts)
    opts = opts.with_indifferent_access

    logger.info "Updating posting #{opts[:id]}... with #{opts[:action]}"

    posting = Posting.find_by_id(opts[:id])

    if posting.nil?
      logger.info "... posting #{opts[:id]} not found!"
      return
    end

    case opts[:action]
    when 'created'
      after_created(posting)
    end
  end

  private

  def after_created(posting)

    # Send a sms or email to the poster if state == blank
    if posting.state == 'blank'
      notify_poster(posting)
    end

  end

  def notify_poster(posting)
    if posting.user.phone.present?
      ap ['...sending sms to', posting.user, posting.user.phone]
      notify_via_sms(posting)
    else
      PostingMailer.created_notify_poster(posting).deliver
    end    
  end

  def notify_via_sms(posting)
    return unless CONFIG[:twilio][:enabled]
    
    twilio_client.account.sms.messages.create({
      from: CONFIG[:twilio][:sender],
      to: posting.user.phone,
      body: "new posting: #{CONFIG[:public_host]}/postings/#{posting.id}/edit?auth_token=#{posting.user.authentication_token}"
    })
  end

  def twilio_client
    Twilio::REST::Client.new *[
      CONFIG[:twilio][:account],
      CONFIG[:twilio][:token]
    ]
  end



end
