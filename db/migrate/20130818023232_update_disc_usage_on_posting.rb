class UpdateDiscUsageOnPosting < ActiveRecord::Migration

  class Posting < ActiveRecord::Base
  	belongs_to :media, polymorphic: true, dependent: :destroy

   def disc_usage!
      return self.disc_usage = 0 if self.media_id.blank?

      path = [
        'public',
        self.media_type == 'ImageFile' ? 'i' : 'v',
        self.media_id
      ].join('/')

      self.disc_usage = `du -s '#{path}'`.split("\t").first.to_i * 1024
    end    
  end

  def change
  	Posting.reset_column_information

    reversible do |dir|
      dir.up do
      	say "Updating disc usage on #{Posting.count} postings"

      	Posting.all.each do |posting|
          posting.disc_usage!
      		posting.save
      	end
      end
     end
  end
end
