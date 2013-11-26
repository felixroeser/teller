class Feedback < ActiveRecord::Base
  belongs_to :user

  validates :message, presence: true
  validate :require_user_id_or_email

  after_create :async_after_create

  def self.subjects
    %w(General Bug Featurerequest Whatever Account)
  end

  private

  def async_after_create
    UpdateFeedback.perform_async(id: self.id, action: 'created')
  end

  def require_user_id_or_email
    if user_id.blank? && email.blank?
      errors.add(:email, 'cant be blank')
    end
  end
  


end
