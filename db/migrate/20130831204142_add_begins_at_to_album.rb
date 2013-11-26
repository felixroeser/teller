class AddBeginsAtToAlbum < ActiveRecord::Migration

	class Posting < ActiveRecord::Base
	end

  class Album < ActiveRecord::Base
  	has_many :postings
  end


  def change
    add_column :albums, :begins_at, :date
    add_column :albums, :display_age, :boolean, default: true

    Album.reset_column_information
    reversible do |dir|
      dir.up do
        say "begins_at and display_age to albums"

        Album.all.each do |album|
        	first_posting = album.postings.order('recorded_at ASC').first
        	album.begins_at = first_posting.recorded_at || first_posting.created_at if first_posting
        	album.display_age = true
        	album.save
        end
      end
    end

  end
end