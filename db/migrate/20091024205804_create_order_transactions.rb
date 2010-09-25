class CreateOrderTransactions < ActiveRecord::Migration
  # We have braintree_transactions, paypal_transactions, and the
  # current order_transactions.  This might be better
  # as a view on top of the other two. XXX-PayPal.
  def self.up
    create_table :order_transactions do |t|
      t.belongs_to :order
      t.string :express_token
      t.string :express_payer_id
      t.string :status
      t.string :transaction_id
      t.string :transaction_type
      t.string :payer_id
      t.string :gateway
      t.integer :amount
      t.boolean :success
      t.string :reference
      t.string :message
      t.string :action
      t.text :params
      t.boolean :test
      t.string :ip_address
      t.string :first_name
      t.string :last_name
      t.string :card_type
      t.date :card_expires_on

      t.timestamps
    end
  end

  def self.down
    drop_table :order_transactions
  end
end
