class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :recipient, class_name: 'User'

  scope :state_open, -> { where state: 'open' }
  scope :accepted, -> { where state: 'accepted' }
  scope :rejected, -> { where state: 'rejected' }

  default_scope { order('updated_at DESC') }

  validates_presence_of :album_ids

  before_save :ensure_token
  after_create :async_after_create

  def albums
    Album.where(id: self.album_ids)
  end

  def open?
    self.state == 'open'
  end

  private

  # Invitations need a token that is unknown to the issuing user
  # otherwise he could accept the invitation
  def ensure_token
    return if self.token.present?
    length = 10
    self.token  = (36**(length-1) + rand(36**length - 36**(length-1))).to_s(36)
  end

  def async_after_create
    UpdateInvitation.perform_async(id: self.id, action: 'created')
  end
  
end
