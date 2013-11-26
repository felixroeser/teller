class CreateVideoFiles < ActiveRecord::Migration
  def change
    create_table :video_files, id: :uuid do |t|
      t.uuid    :user_id
      t.string  :original_name
      t.string  :extension
      t.string  :sha1
      t.integer :original_width
      t.integer :original_height
      t.integer :duration
      t.integer :orientation
      t.float   :ratio
      t.string  :state, state: 'blank'
      t.hstore  :meta

      t.timestamps
    end
  end
end
