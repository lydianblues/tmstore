module BuildCategoryTree

  def build_all
    build_categories
    build_product_families
    build_family_attributes
  end

  def build_categories
    @root = Category.find(Category.root_id)
    @cat1 = Category.make!(:name => "cat1", :parent_id => @root.id )
    @cat2 = Category.make!(:name => "cat2", :parent_id => @root.id )
    @cat11 = Category.make!(:name => "cat11", :parent_id => @cat1.id )
    @cat12 = Category.make!(:name => "cat12", :parent_id => @cat1.id )
    @cat13 = Category.make!(:name => "cat13", :parent_id => @cat1.id )
    @cat121 = Category.make!(:name => "cat121", :parent_id => @cat12.id )
    @cat122 = Category.make!(:name => "cat122", :parent_id => @cat12.id )
    @cat123 = Category.make!(:name => "cat123", :parent_id => @cat12.id )
    @cat131 = Category.make!(:name => "cat131", :parent_id => @cat13.id )
    @cat1221 = Category.make!(:name => "cat1221", :parent_id => @cat122.id )
    @cat1222 = Category.make!(:name => "cat1222", :parent_id => @cat122.id )
  end

  def build_product_families
    category_families.keys.each do |cfk|
      cat = instance_variable_get(cfk)
      if cat
        category_families[cfk].each do |i|
          fam = ProductFamily.make!(:name => "fam#{i}")
          instance_variable_set("@fam#{i}", fam)
          cat.add_family(fam.id)
        end
      end
    end
  end

  def build_family_attributes
    family_attributes.each_with_index do |row, i|
      name = "@fam#{i + 1}"
      fam = instance_variable_get(name)
      row.each_with_index.each do |flag, j|
        next unless flag == 1
        attr = find_or_create_attribute(j + 1)
        fam.add_attribute(attr.id)
      end
    end
  end

  private

  # Mapping of categories to their product families.
  def category_families
    { 
      :@cat11 => [7],
      :@cat121 => [],
      :@cat1221 => [1,2,3],
      :@cat1222 => [2,3,4],
      :@cat123 => [2,5,6],
      :@cat131 => [2,6],
      :@cat13 => [2,6],
      :@cat2 => [8,2]
    }
  end

  # Mapping of product families to their attributes.
  # There are eight product families (the rows), and
  # fifteen attributes (the columns).
  def family_attributes
    [
      [1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0],
      [1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1],
      [1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1],
      [1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1],
      [1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1],
      [1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1],
      [1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1],
      [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1]
    ]
  end

  def find_or_create_attribute(j)
    name = "attr#{j}"
    iname = "@" + name
    attr = instance_variable_get(iname)
    unless attr
      attr = ProductAttribute.make!(:name => name)
      instance_variable_set(iname, attr)
    end
    attr   
  end

end
