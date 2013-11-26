class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.uuid :user_id
      t.string :email
      t.text :message
      t.string :subject

      t.timestamps
    end
  end
end
