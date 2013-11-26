class UpdateSubscription
  include Sidekiq::Worker

  def perform(opts)
    opts = opts.with_indifferent_access

    subscription = Subscription.find_by_id opts[:id]

    case opts[:action]
    when 'created'
      after_created(subscription)
    when 'destoyed'
      after_updated(opts[:id], opts[:stale])
    end
  end

  private

  def after_created(subscription=nil)
    return if subscription.blank?

    # Fill the news markers
    posting_ids = subscription.album.postings.pluck(:id)
    return if posting_ids.blank?

    NewsMarker.perform_async({
      action: 'create', user_ids: [subscription.user.id], album_ids: [subscription.album.id], posting_ids: posting_ids
    })
  end

  def after_destroyed(subscription_id, stale)
    # Remove all news markers
    NewsMarker.perform_async({
      action: 'destroy', user_ids: [stale[:user_id]], album_ids: [stale[:album_id]]
    })
  end

end
