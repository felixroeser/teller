class ChangeMessageFormatInComments < ActiveRecord::Migration
  def up
  	change_column :comments, :message, :text
  end

  def down
  	change_column :comments, :message, :string
  end
end
