class CreateCategoryFamilies < ActiveRecord::Migration
 def self.up
    create_table :category_families, :force => true, :id => false do |t|
      t.belongs_to :category
      t.belongs_to :product_family
      t.integer :ref_count
    end
    # The Oracle adapter needs a sequence, even if there is no 'id'.
    execute "CREATE SEQUENCE category_families_seq"
    execute "CREATE INDEX cf_cat ON " +
      "category_families(category_id) UNRECOVERABLE"
    execute "CREATE INDEX cf_fam ON " +
      "category_families(product_family_id) UNRECOVERABLE"
    execute "CREATE UNIQUE INDEX cf_cat_fam ON " +
      "category_families(product_family_id, category_id) UNRECOVERABLE"
  end

  def self.down
    drop_table :category_families
    # Oracle will drop the indexes when it drops the table. 
    # Rails will remove the sequence.
  end
end
