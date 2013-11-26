class Subscription < ActiveRecord::Base
  belongs_to :album
  belongs_to :user

  after_create :async_after_create
  after_destroy :async_after_destroy

  scope :newest_first, -> { order 'updated_at DESC' }

  def async_after_create
    UpdateSubscription.perform_async(id: self.id, action: 'created')
  end

  def async_after_destroy
    UpdateSubscription.perform_async(id: self.id, action: 'destroyed', stale: self.as_json)
  end

end