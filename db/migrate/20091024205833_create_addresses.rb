class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses, :force => true do |t|
      t.paypal_address 
      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
