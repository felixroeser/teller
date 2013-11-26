class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums, id: :uuid, force: true do |t|
      t.string :title
      t.string :state

      t.timestamps
    end
  end
end
