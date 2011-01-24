class CreatePaypalNotifications < ActiveRecord::Migration
  def self.up
    create_table :paypal_notifications do |t|
      t.references  :order
      t.text     :params
      t.integer  :invoice
      t.string   :payment_status
      t.string   :txn_id
      t.string   :txn_type
      t.string   :payment_type
      t.string   :receiver_email
      t.boolean  :authenticated
      t.boolean :consistent
      t.timestamps
    end
  end

  def self.down
    drop_table :paypal_notifications
  end
end
