class AddMailTokenToUser < ActiveRecord::Migration

	class User < ActiveRecord::Base
	end
	
  def change
    add_column :users, :mail_token, :string

    User.reset_column_information
    reversible do |dir|
      dir.up do
        say "Generating mail_token for #{User.where(mail_token: nil).count} users"

        User.where(mail_token: nil).each do |user|
          # See http://stackoverflow.com/questions/88311/how-best-to-generate-a-random-string-in-ruby
          length = 10
          user.mail_token  = (36**(length-1) + rand(36**length - 36**(length-1))).to_s(36)
          user.save
        end

      end
    end    

  end
end
