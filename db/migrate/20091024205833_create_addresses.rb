class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses, :force => true do |t|
      t.string :account_name
      t.string :first_name              # PayPal IPN, Return first_name
      t.string :middle_initial
      t.string :last_name               # PayPal IPN, Return last_name
      t.string :business_name           # PayPal IPN payer_business_name
      t.string :email                   # PayPal IPN, Return payer_email
      t.string :street_1                # PayPal IPN, Return address_street
      t.string :street_2
      t.string :city                    # PayPal IPN, Return address_city
      t.string :state                   # PayPal IPN, Return address_state
      t.string :province # Canada only
      t.string :region # All others
      t.string :postal_code             # PayPal IPN, Return address_zip
      t.string :country                 # PayPal IPN, Return address_country
      t.string :country_code            # PayPal IPN, Return address_country_code
      t.string :address_name            # PayPal IPN, Return address_name (Gift Address)
      t.string :phone_number            # PayPal IPN contact_phone
      t.string :address_type
      t.string :address_status          # PayPal IPN, Return address_status
      
      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
