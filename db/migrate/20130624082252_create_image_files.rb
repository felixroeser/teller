class CreateImageFiles < ActiveRecord::Migration
  def change
    create_table :image_files, id: :uuid do |t|
      t.uuid    :user_id
      t.string  :original_name
      t.string  :extension
      t.string  :sha1
      t.integer :original_width
      t.integer :original_height
      t.integer :orientation
      t.float   :ratio
      t.string  :resolutions, array: true
      t.string  :state, default: 'blank'

      t.timestamps
    end
  end
end
