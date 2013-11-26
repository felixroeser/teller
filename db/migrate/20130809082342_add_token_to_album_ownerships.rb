class AddTokenToAlbumOwnerships < ActiveRecord::Migration

  class AlbumOwnership < ActiveRecord::Base
  end

  def change
    add_column :album_ownerships, :token, :string

    AlbumOwnership.reset_column_information
    reversible do |dir|
      dir.up do
        say "Generating tokens for #{AlbumOwnership.where(token: nil).count} album_ownerships"

        AlbumOwnership.where(token: nil).each do |album_ownership|
          # See http://stackoverflow.com/questions/88311/how-best-to-generate-a-random-string-in-ruby
          length = 10
          token  = (36**(length-1) + rand(36**length - 36**(length-1))).to_s(36)

          AlbumOwnership.where(album_id: album_ownership.album_id, user_id: album_ownership.user_id).update_all({token: token}, )
        end

      end
    end

  end
end
