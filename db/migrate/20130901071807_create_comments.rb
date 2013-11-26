class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.uuid :posting_id
      t.uuid :user_id
      t.string :message
      t.string :state, default: 'published'
      t.boolean :public, default: true

      t.timestamps
    end
  end
end
