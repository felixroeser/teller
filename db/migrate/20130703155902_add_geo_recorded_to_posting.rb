class AddGeoRecordedToPosting < ActiveRecord::Migration
  def change
    add_column :postings, :geo_lat, :float
    add_column :postings, :geo_long, :float
    add_column :postings, :geo_loc, :string
    add_column :postings, :recorded_at, :datetime
  end
end
