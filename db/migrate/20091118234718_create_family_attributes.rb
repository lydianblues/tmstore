class CreateFamilyAttributes < ActiveRecord::Migration
  def self.up
    create_table :family_attributes, :id => false, :force => true do |t|
      t.belongs_to :product_family
      t.belongs_to :product_attribute
    end
      
    # The Oracle adapter needs a sequence, even if there is no 'id'.
    execute "CREATE SEQUENCE family_attributes_seq"
    execute "CREATE INDEX fa_fam ON " +
      "family_attributes(product_family_id) UNRECOVERABLE"
    execute "CREATE INDEX fa_attr ON " +
      "family_attributes(product_attribute_id) UNRECOVERABLE"
    execute "CREATE UNIQUE INDEX fa_fam_attr ON " +
      "family_attributes(product_family_id, product_attribute_id) UNRECOVERABLE"
  end

  def self.down
    drop_table :family_attributes
    # Oracle will drop the indexes when it drops the table. 
    # Rails will remove the sequence.
  end
end
