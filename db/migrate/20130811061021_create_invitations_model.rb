class CreateInvitationsModel < ActiveRecord::Migration
  def change
    create_table :invitations, id: :uuid do |t|
      t.uuid :user_id
      t.string :message
      t.string :recipient_email
      t.uuid :recipient_id
      t.string :album_ids, array: true
      t.string :state, default: 'open'
      t.string :token

      t.datetime :accepted_at
      t.datetime :rejected_at

      t.timestamps
    end
  end
end
