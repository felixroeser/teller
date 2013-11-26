class AddLocaleToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :locale, :string, default: 'en'
  end
end
