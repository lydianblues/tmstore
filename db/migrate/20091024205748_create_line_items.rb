class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items do |t|
      t.integer :unit_price
      t.belongs_to :product
      t.belongs_to :order
      t.integer :quantity

      t.timestamps
    end
  end

  def self.down
    drop_table :line_items
  end
end
