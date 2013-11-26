class ChangeBodyFormatInPostings < ActiveRecord::Migration
  def up
  	change_column :postings, :body, :text
  end

  def down
  	change_column :postings, :body, :string
  end
end
