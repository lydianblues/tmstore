class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.timestamps
      t.paypal_user # for email column
      
      t.string :login, :default => nil, :null => true
#      t.string :crypted_password, :default => nil, :null => true
#      t.string :password_salt, :default => nil, :null => true
#      t.string :persistence_token, :null => false
      t.integer :login_count, :default => 0, :null => false
      t.datetime :last_request_at
#      t.datetime :last_login_at
#      t.datetime :current_login_at
#      t.string :last_login_ip
#      t.string :current_login_ip

      # fields added for password reset
#      t.string :perishable_token, :default => "", :null => false

      # Field added for for openID.
      t.string :openid_identifier
      
      t.integer :shipping_address_id
      t.integer :billing_address_id
      
      t.boolean :admin
      
      t.integer :subscription_id # TEMPORARY from RSpec book

      # Fields added for Devise.
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable

    end

    # Indexes added for Devise.
    add_index :users, :login, :unique => true
    add_index :users, :email # , :unique => true XXXXXXXXXXXXXXXXXXXXXXXXXXX TEMPORARY XXXXXXXXXXXXXXXXXXXXXXXXX
    add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true

    # Use the 'name' option to keep the index names short enough for Oracle.
#    add_index :users, :persistence_token, :name => 'persistence_token_index'
    add_index :users, :last_request_at, :name => 'last_request_at_index'
#    add_index :users, :perishable_token, :name => 'perishable_token_index'
    add_index :users, :openid_identifier, :name => 'openid_identifier'
  end

  def self.down
    drop_table :users
  end
end
