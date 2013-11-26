class AddPseudoAndReviewedAndPseudoPasswordToUsers < ActiveRecord::Migration

  class User < ActiveRecord::Base
  end

  def change
    add_column :users, :reviewed, :boolean, default: true
    add_column :users, :pseudo, :boolean, default: false
    add_column :users, :pseudo_password, :string

    User.reset_column_information

    reversible do |dir|
      dir.up do
        invitations = Invitation.where(state: 'open').all
        say "Fixing #{invitations.size} invitations"
        invitations.each do |invitation|
          UpdateInvitation.new.send(:create_pseudo_user!, invitation)
        end
      end
    end


  end
end
