class Comment < ActiveRecord::Base
  validates :message, presence: true
  validates :user_id, presence: true
  validates :posting_id, presence: true

  belongs_to :posting
  belongs_to :user

  after_create :async_after_create

  private

  def async_after_create
    UpdateComment.perform_async(id: self.id, action: 'created')
  end


end
