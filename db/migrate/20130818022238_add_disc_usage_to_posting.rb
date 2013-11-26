class AddDiscUsageToPosting < ActiveRecord::Migration
  def change
    add_column :postings, :disc_usage, :integer
  end
end
