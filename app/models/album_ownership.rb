class AlbumOwnership < ActiveRecord::Base
  belongs_to :user
  belongs_to :album

  before_save :ensure_token
  after_create :async_after_create

  def magic_email_address
    [ [CONFIG[:in_mail_prefix], self.token].join(''), CONFIG[:in_mail_domain]].join('@')
  end

  private

  def ensure_token
  	return if self.token.present?

  	length = 10
    self.token  = (36**(length-1) + rand(36**length - 36**(length-1))).to_s(36)
  end

  def async_after_create
    UpdateAlbumOwnership.perform_async(album_id: self.album_id, user_id: self.user_id, action: 'created')
  end

end
