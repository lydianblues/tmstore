class CreateCategoryAttributes < ActiveRecord::Migration
  def self.up
    create_table :category_attributes, :force => true, :id => false do |t|
      t.belongs_to :category
      t.belongs_to :product_attribute
    end
    
    # The Oracle adapter needs a sequence, even if there is no 'id'.
    execute "CREATE SEQUENCE category_attributes_seq"
    execute "CREATE INDEX ca_cat ON " +
      "category_attributes(category_id) UNRECOVERABLE"
    execute "CREATE INDEX ca_attr ON " +
      "category_attributes(product_attribute_id) UNRECOVERABLE"
    execute "CREATE UNIQUE INDEX ca_cat_attr ON " +
      "category_attributes(category_id, product_attribute_id) UNRECOVERABLE"
  end

  def self.down
    drop_table :category_attributes
  end
end
