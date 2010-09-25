#
# This table describes the *possible values* of an attribute.
#
class CreateAttributeRanges< ActiveRecord::Migration
  def self.up
    create_table :attribute_ranges do |t|
      t.belongs_to :product_attribute
      
      # For atype "integer_enum" only the "low" columns are used.
      t.integer :integer_val_low
      t.integer :integer_val_high

      #
      # The ProductAttribute for this attribute range contains the "units"
      # to use for the normalized values. For display purposes we may want
      # to use different units, for example "1.5 TB" (terabytes) instead of
      # "15000000 MB" (megabytes).
      #
      t.string :units_low
      t.string :units_high
      
      t.string :string_val
      
      #
      # The order in which the attribute ranges should be displayed.
      #
      t.integer :priority, :null => false

    end
  end

  def self.down
    drop_table :attribute_ranges
  end
end
