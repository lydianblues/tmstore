class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.belongs_to :product
      t.string :file_name
      t.string :full_path
      t.string :title 
      t.string :content_type
      t.string :usage_type # Called "type" in the view.
      t.boolean :hidden
      t.binary :data, :limit => 2.megabyte
      t.integer :display_order
      t.integer :full_photo_id
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end
