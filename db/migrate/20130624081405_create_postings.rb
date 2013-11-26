class CreatePostings < ActiveRecord::Migration
  def change
    create_table :postings, id: :uuid do |t|
      t.string :title
      t.string :body
      t.string :state, default: 'blank'
      t.uuid :album_id
      t.uuid :user_id
      t.uuid :media_id
      t.string :media_type

      t.timestamps
    end
  end
end
