class CreateAlbumOwnerships < ActiveRecord::Migration
  def change
    create_table :album_ownerships, id: false do |t|
      t.uuid :user_id
      t.uuid :album_id
      t.string :state

      t.timestamps
    end

    add_index :album_ownerships, :user_id
    add_index :album_ownerships, :album_id
  end
end
