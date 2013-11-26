class CreateSubscription < ActiveRecord::Migration
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.uuid    :album_id
      t.uuid    :user_id
      t.string  :state
      t.timestamps
    end
    add_index :subscriptions, :user_id
    add_index :subscriptions, :album_id
  end
end
