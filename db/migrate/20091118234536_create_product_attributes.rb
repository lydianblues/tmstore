class CreateProductAttributes < ActiveRecord::Migration
  def self.up
    create_table :product_attributes do |t|
      t.string :name
      t.string :gname
      
      # "atype" is one of "integer_enum", "integer", 
      # "boolean", or "string", or "currency".  See  the ProductAttribute
      # model for the constant definitions.
      t.string :atype
      
      # RPM, MB, TB, lbs, etc. See the conversion table and explanation in
      # the ProductAttribute model.
      t.string :units
      
      t.string :any_choice
      t.string :trail_cue # used in breadcrumb trail
      
      # Number of columns to use in the sidebar display.  The default is 1.
      t.integer :sidebar_cols
      
      t.text :description
    end
  end

  def self.down
    drop_table :product_attributes
  end
end
