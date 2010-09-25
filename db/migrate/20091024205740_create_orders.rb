class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders, :force => true do |t|
      t.integer :user_id
      t.string  :email, :limit => 100 # used when the user_id is nil
      t.integer :invoice_number
      t.text :memo
      t.string :state, :default => 'shopping'

      # Shipped | Authorized | Purchased | Pending Review | Declined |
      # Canceled | Complete
      t.string :status 
      t.string :pending_reason
      t.boolean :ok_to_ship

      # Fields for billing.
      t.belongs_to :billing_address
      t.string :payment_method
      t.date :payment_date
      t.string :payment_status
      # gross_total includes shipping, handling, and sales tax.  The
      # (gross_total - transaction_fee) is amount the processor will
      # deposit to the merchant account.  All monetary values are in
      # cents (USD).
      t.string :currency_code
      t.integer :gross_total
      t.integer :sales_tax
      t.integer :transaction_fee
      t.integer :handling_cost
      t.integer :total_captured
      t.integer :amount_authorized

      # Fields for shipping.
      t.belongs_to :shipping_address
      t.string :carrier
      t.string :service_name
      t.string :service_code
      t.string :tracking_number
      t.integer :shipping_cost
      t.datetime :estimated_shipping_date
      t.datetime :actual_shipping_date

      t.datetime :purchased_at
      t.datetime :shipped_at

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
