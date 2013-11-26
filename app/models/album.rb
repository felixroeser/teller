class Album < ActiveRecord::Base
  has_many :album_ownerships
  has_many :users, through: :album_ownerships
  has_many :postings
  has_many :subscriptions, dependent: :destroy # FIXME should become delete
  has_many :subscribers, through: :subscriptions, source: :user
  has_many :album_ownerships, dependent: :delete_all

  default_scope { order('albums.updated_at DESC') }

  validates_presence_of :title

  def readable_by(user)
  	self.subscribers.include?(user) || user.admin? || self.editable_by(user)
  end

  def editable_by(user)
  	self.users.include?(user)
  end

  def owned_by(user)
    user.album_ownerships.where(album_id: self.id, role: 'owner').exists?
  end

  def open_invitations
    Invitation.state_open.where("'#{self.id}' = ANY (album_ids)")
  end

  def view_rate(user)
    return nil if self.postings.count == 0

    Sidekiq.redis do |redis|
      return (self.postings.count - redis.scard("news:u:#{user.id}:a:#{self.id}")) / self.postings.count
    end
  end
end
