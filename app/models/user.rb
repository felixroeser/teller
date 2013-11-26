class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :async, :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :album_ownerships, dependent: :destroy
  has_many :albums, through: :album_ownerships
  has_many :postings
  has_many :media_sources, dependent: :destroy
  has_many :image_files, dependent: :destroy
  has_many :video_files, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscribed_albums, through: :subscriptions, source: :album
  has_many :invitations, dependent: :destroy
  has_many :received_invitations, foreign_key: :recipient_id, class_name: 'Invitation', dependent: :destroy

  before_save :ensure_authentication_token
  before_save :ensure_mail_token

  validates_presence_of :name

  def locale
    self.attributes['locale'] || 'en'
  end

  def admin?
    self.role == 'admin'
  end

  def can_create_album?
    self.admin? || self.max_albums.to_i > 0
  end

  def has_albums?
    self.album_ownerships.exists?
  end

  def albums_left?
    self.admin? || (self.max_albums.to_i - self.album_ownerships.count) > 0
  end

  def unpublished_postings_waiting
    return false unless has_albums?

    self.postings.where(state: 'blank').exists?.present?
  end

  def albums_with_news
    Sidekiq.redis do |redis|
      album_ids = self.subscriptions.pluck(:album_id).collect do |album_id|
        redis.scard("news:u:#{self.id}:a:#{album_id}").to_i > 0 ? album_id : nil
      end.compact
      return Album.where(id: album_ids)
    end
  end

  def markers_by_album
    out = nil
    Sidekiq.redis do |redis|
      out = self.subscriptions.pluck(:album_id).inject({}) do |memo, album_id|
        posting_ids = redis.smembers("news:u:#{self.id}:a:#{album_id}")
        memo[album_id] = posting_ids if posting_ids.size > 0
        memo
      end
    end
    out
  end

  def all_postings
    Posting.where(album_id: self.album_ownerships.pluck(:album_id))
  end

  # FIXME too expensive
  def albums_by_latest_post
    return self.albums if self.albums.size < 2

    album_ids = self.postings.order('created_at DESC').pluck(:album_id).compact.concat(self.albums.pluck(:id)).uniq

    album_ids.map {|id| self.albums.detect {|a| a.id == id}}
  end

  def markers_count
    self.markers_by_album.values.flatten.size
  end

  # FIXME move to a decorator
  # PHOTO;MEDIATYPE=image/gif:http://www.example.com/dir_photos/my_photo.gif
  def vcard
    return <<-eos
BEGIN:VCARD
VERSION:3.0
N:Teller Album;;;;
FN:Post to your Teller Album
ORG:Teller
EMAIL:#{self.magic_mail_address}
URL:#{CONFIG[:public_host]}/me?auth_token=#{self.authentication_token}
END:VCARD
    eos
  end

  def magic_mail_address
    "#{CONFIG[:in_mail_prefix]}#{self.mail_token}@#{CONFIG[:in_mail_domain]}"
  end
  
  private

  def ensure_mail_token
    return if self.mail_token.present?
    length = 10
    self.mail_token  = (36**(length-1) + rand(36**length - 36**(length-1))).to_s(36)
  end


end
