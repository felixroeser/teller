class PublishPosting
  include Sidekiq::Worker

  def perform(payload={})
    payload = payload.with_indifferent_access

    posting = Posting.where(id: payload[:posting_id]).first

    ap ['PublishPosting', posting, posting.state, posting.state == 'blank', posting && posting.state == 'blank']

    return unless posting && %w(blank scheduled).include?(posting.state)

    posting.update(state: 'published')

    NewsMarker.perform_async({
      action: 'create',
      user_ids: posting.album.subscriptions.pluck(:user_id),
      album_ids: [posting.album_id],
      posting_ids: [posting.id] 
    })

    # Touch the album to update album sort order
    posting.album.touch

    coowners = (posting.album.users - [posting.user])
    if coowners.present?
      PostingMailer.published_notify_coowners(posting, coowners).deliver
    end

  end
end