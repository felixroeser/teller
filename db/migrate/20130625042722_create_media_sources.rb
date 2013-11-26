class CreateMediaSources < ActiveRecord::Migration
  def change
    create_table :media_sources, id: :uuid, force: true do |t|
      t.uuid   :user_id
      t.string :provider, null: false
      t.hstore :meta

      t.timestamps
    end
  end
end
