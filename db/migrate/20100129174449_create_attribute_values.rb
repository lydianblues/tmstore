class CreateAttributeValues < ActiveRecord::Migration
  def self.up
    
    create_table :attribute_values, :force => true, :id => false do |t|
        t.belongs_to :product_attribute
        t.belongs_to :product
        t.integer :integer_val
        t.string :string_val
        t.string :units # MB, GB, TB (for megabyte, gigbyte, terabyte, etc.)
    end
    # N.B. This is not a "join" table.
    execute "CREATE SEQUENCE attribute_values_seq"
    execute "CREATE INDEX av_attr ON " +
      "attribute_values(product_attribute_id) UNRECOVERABLE"
    execute "CREATE INDEX av_prod ON " +
      "attribute_values(product_id) UNRECOVERABLE"
    execute "CREATE UNIQUE INDEX av_prod_attr ON " +
      "attribute_values(product_id, product_attribute_id) UNRECOVERABLE"
  end

  def self.down
    drop_table :attribute_values
    # Oracle will drop the indexes when it drops the table. 
    # Rails will remove the sequence.
  end
end
