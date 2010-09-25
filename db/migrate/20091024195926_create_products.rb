class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products, :force => true do |t|
      t.string :name
      t.string :subtext
      t.string :manufacturer
      t.string :vendor
      t.belongs_to :product_family
      t.integer :price_basis
      t.string :currency
      t.integer :qty_in_stock
      t.integer :qty_on_order
      t.integer :qty_low_threshold
      t.text :description
      t.text :key_words
      t.integer :sales_rank
      t.integer :review_rank # 1..10, 1 = 1/2 star, 2 = 1 star, 3 = 1 1/2 stars, etc.
      t.integer :display_priority
      t.decimal :shipping_length # centimeters or inches
      t.decimal :shipping_width # or diameter, if a cylinder
      t.decimal :shipping_height
      t.decimal :shipping_weight # grams or ounces
      t.boolean :shipping_cylinder
      t.string :shipping_units # "Metric" -- centimeters and grams, or "Imperial" -- inches and ounces
      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
