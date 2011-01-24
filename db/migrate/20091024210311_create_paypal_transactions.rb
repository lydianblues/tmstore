class CreatePaypalTransactions < ActiveRecord::Migration
  def self.up
    create_table "paypal_transactions", :force => true do |t|
      t.references :order
      t.references :paypal_notification
      t.string :ip_address
      t.text :details_params
      t.string :token
      t.string :txn_id
      t.integer :error_code
      t.string :correlation_id
      t.string :payer_status
      # One of "PaymentActionNotInitiated", "PaymmentActionFailed", 
      # "PaymentActionInProgress", and "PaymentCompleted".
      t.string :checkout_status
      t.string :status # ACK field from PayPal
      t.string :message
      # In the case of a refund, reversal, full or partial capture, or canceled
      # reversal, this variable contains the txn_id of the original transaction,
      # while txn_id contains a new ID for the new transaction.
      t.string :parent_txn_id
      t.string :txn_type
      t.string :auth_id
      t.string :payer_id
      t.integer :amount
      t.integer :sales_tax
      t.integer :transaction_fee
      t.string :currency_code
      t.boolean :test
      # action is "authorization" | "sale" | "final capture" | 
      # "partial capture" | "void"
      t.string :action
      t.date :timestamp
      t.date :payment_date
      t.string :payment_status # Pending, when authorization
      t.string :pending_reason
      t.string :payment_type # instant
    end
  end

  def self.down
    drop_table :paypal_transactions
  end
end

