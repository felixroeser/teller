class AddMaxAlbumsToUser < ActiveRecord::Migration
  def change
    add_column :users, :max_albums, :integer, default: 0
  end
end
