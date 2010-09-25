class CreateCategoryProducts < ActiveRecord::Migration
  def self.up
    create_table :category_products, :force => true, :id => false do |t|
      t.belongs_to :category
      t.belongs_to :product
      t.integer :ref_count
    end

    # The Oracle adapter needs a sequence, even if there is no 'id'.
     execute "CREATE SEQUENCE category_products_seq"
     execute "CREATE INDEX cp_cat ON " +
       "category_products(category_id) UNRECOVERABLE"
     execute "CREATE INDEX cp_prod ON " +
       "category_products(product_id) UNRECOVERABLE"
     execute "CREATE UNIQUE INDEX cp_cat_prod ON " +
       "category_products(category_id, product_id) UNRECOVERABLE"
  end

  def self.down
    drop_table :category_products
    # Oracle will drop the indexes when it drops the table. 
    # Rails will remove the sequence.
  end

end
