class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories, :force => true do |t|
      t.string :name
      t.integer :parent_id
      t.integer :depth # 'level' is reserved word in Oracle
      t.boolean :leaf
    end
    
    add_index :categories, :parent_id
  end

  def self.down
    drop_table :categories
  end
end
