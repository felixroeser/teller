class AddRoleToAlbumOwnerships < ActiveRecord::Migration

  class AlbumOwnership < ActiveRecord::Base
  end

  def change
    add_column :album_ownerships, :role, :string, default: 'owner'

    AlbumOwnership.reset_column_information
    reversible do |dir|
      dir.up do
        say "Adding role for #{AlbumOwnership.where(token: nil).count} album_ownerships"

        AlbumOwnership.update_all("role = 'owner'")
      end
    end

  end
end
