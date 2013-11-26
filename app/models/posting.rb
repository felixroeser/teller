class Posting < ActiveRecord::Base
  belongs_to :user
  belongs_to :album
  belongs_to :media, polymorphic: true, dependent: :destroy

  scope :blank, -> { where state: 'blank' }
  scope :unpublished, -> { where state: 'IS NOT published' }
  scope :published, -> { where state: 'published' }
  scope :latest_first, -> { order 'recorded_at DESC' }
  scope :oldest_first, -> { order 'recorded_at ASC' }

  attr_accessor :publish_in

  before_save :ensure_recorded_at_for_published

  paginates_per 10

  def blank?
    self.state == 'blank'
  end

  def scheduled?
    self.state == 'scheduled'
  end

  def published?
  	self.state == 'published'
  end

  def disc_usage!
    return self.disc_usage = 0 if self.media_id.blank?

    path = [
      'public',
      self.media_type == 'ImageFile' ? 'i' : 'v',
      self.media_id
    ].join('/')

    self.disc_usage = `du -s '#{path}'`.split("\t").first.to_i * 1024
  end

  def seen_by
    return [] if self.album_id.blank?

    Sidekiq.redis do |redis|

      user_ids = Subscription.where(album_id: self.album_id).pluck(:user_id).collect do |user_id|
        redis.sismember("news:u:#{user_id}:a:#{self.album_id}", self.id) ? nil : user_id
      end.compact

      return User.where(id: user_ids)
    end

    # posting_ids = redis.smembers("news:u:#{self.id}:a:#{album_id}")
  end

  private

  def ensure_recorded_at_for_published
  	return unless published?

  	self.recorded_at ||= (self.created_at || Time.now)
  end

end 
