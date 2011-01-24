class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders, :force => true do |t|
   
      t.paypal_order
      
      # Fields for shipping.
      t.string :carrier
      t.string :service_name
      t.string :service_code
      t.string :tracking_number
      t.integer :shipping_cost
      t.datetime :estimated_shipping_date
      t.datetime :actual_shipping_date
      t.datetime :shipped_at

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
