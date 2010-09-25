class CreateBraintreeTransactions < ActiveRecord::Migration
  def self.up
    create_table "braintree_transactions", :force => true do |t|
      t.belongs_to :order
      t.boolean :success
      t.integer :reference # BT uses the transactionid as the reference
      t.string :notes
      t.string :message
      t.string :transactionid
      t.string :username
      t.integer :amount
      t.string :responsetext
      t.string :action
      t.text :params
      t.integer :authcode
      t.integer :response_code
      t.integer :response
      t.string :trans_type
      t.integer :authorization
      t.boolean :test
    
      t.timestamps
    end
  end

  def self.down
    drop_table :braintree_transactions
  end
end