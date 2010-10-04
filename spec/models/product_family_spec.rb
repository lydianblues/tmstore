require 'spec_helper'

describe ProductFamily do
  
  before(:each) do
    @root = Category.find(Category.root_id)
  end
  
  context "root has no children" do
    it "should allow associating a product family" do
      fam = ProductFamily.make!
      @root.add_family(fam.id)
      @root.errors.should be_empty
      @root.should have(1).product_families
    end
  end
  
  context "root has children" do
    
    before(:each) do
      @cat1 = Category.make!(:parent_id => @root.id )
      @cat2 = Category.make!(:parent_id => @root.id )
      @cat11 = Category.make!(:parent_id => @cat1.id )
      @cat12 = Category.make!(:parent_id => @cat1.id )
      @cat13 = Category.make!(:parent_id => @cat1.id )
      @cat121 = Category.make!(:parent_id => @cat12.id )
      @cat122 = Category.make!(:parent_id => @cat12.id )
      @cat123 = Category.make!(:parent_id => @cat12.id )
      @cat131 = Category.make!(:parent_id => @cat13.id )
      @cat1221 = Category.make!(:parent_id => @cat122.id )
      @cat1222 = Category.make!(:parent_id => @cat122.id )
    end
    
    it "should not be able to add product family to a non-leaf" do
      fam = ProductFamily.make!
      @cat122.add_family(fam.id)
      @cat122.should have(0).product_families
      @cat122.errors.should_not be_empty
    end
    
    it "should not be able to remove a product family from a non-leaf" do
      fam = ProductFamily.make!
      @cat131.add_family(fam.id)
      @cat13.should have(1).product_family
      @cat13.remove_family(fam.id)
      @cat13.should have(1).product_family
      @cat13.errors.should_not be_empty
    end
    
    it "should be able to add a product family to a leaf category" do
      fam = ProductFamily.make!
      @cat2.add_family(fam.id)
      @cat2.errors.should be_empty
      [@cat2, @root].each do |cat|
        cat.should have(1).product_family
      end
    end
    
    it "should be able to delete a product family from a leaf category" do
      fam = ProductFamily.make!
      @cat2.add_family(fam.id)
      @cat2.remove_family(fam.id)
      @cat2.errors.should be_empty
      @cat2.product_families.should be_empty
      @root.product_families.should be_empty
    end
 
    it "should propagate product families up from a leaf" do
      fam = ProductFamily.make!
      @cat1221.add_family(fam.id)
      [@cat1221, @cat122, @cat12, @cat1, @root].each do |cat|
       cat.should have(1).product_families
      end
    end
    
    it "should not let a product family be added to the same category twice" do
      fam = ProductFamily.make!
      @cat1221.add_family(fam.id)
      @cat1221.add_family(fam.id)
      CategoryFamily.find(:all, :conditions => {:category_id => @cat1221.id})
        .should have(1).product_family
      @cat1221.should have(1).product_family
      @cat1221.errors.should_not be_empty
    end
    
    it "give an error when trying to remove a non-existent product family" do
      fam = ProductFamily.make!
      @cat1221.remove_family(fam.id + 1)
      @cat1221.errors.should_not be_empty
    end
    
    it "should propagate product families up from two leaves, part I" do
      fam1 = ProductFamily.make!
      fam2 = ProductFamily.make!
      @cat121.add_family(fam1.id)
      @cat123.add_family(fam2.id)
      [@cat121, @cat123].each do |cat|
       cat.should have(1).product_families
      end
      [@cat12, @cat1, @root].each do |cat|
       cat.should have(2).product_families
      end
      [@cat122, @cat1221, @cat1222, @cat11, @cat13, @cat131, @cat2].each do |cat|
        cat.should have(0).product_families
      end
    end
    
    it "should propagate product families up from two leaves, part II" do
      fam1 = ProductFamily.make!
      @cat121.add_family(fam1.id)
      @cat123.add_family(fam1.id)
      [@cat121, @cat123].each do |cat|
       cat.should have(1).product_families
      end
      cfs = CategoryFamily.find(:all, :conditions => {:category_id => @cat12.id}) 
      [@cat12, @cat1, @root].each do |cat|
       cat.should have(1).product_families
      end
      [@cat122, @cat1221, @cat1222, @cat11, @cat13, @cat131, @cat2].each do |cat|
        cat.should have(0).product_families
      end
    end
 
    it "should propagate product families up from two leaves, one leaf with two families" do
      fam1 = ProductFamily.make!
      fam2 = ProductFamily.make!
      fam3 = ProductFamily.make!
      @cat1221.add_family(fam1.id)
      @cat1222.add_family(fam2.id)
      @cat1222.add_family(fam3.id)
      @cat1222.should have(2).product_families
      @cat1221.should have(1).product_families
      [@cat122, @cat12, @cat1, @root].each do |cat|
       cat.should have(3).product_families
      end
      [@cat11, @cat13, @cat131, @cat2].each do |cat|
        cat.should have(0).product_families
      end
    end
 
    it "should progagate families when removing a product family, part I" do
      fam1 = ProductFamily.make!
      fam2 = ProductFamily.make!
      fam3 = ProductFamily.make!
      @cat1221.add_family(fam1.id)
      @cat1222.add_family(fam2.id)
      @cat1222.add_family(fam3.id)

      @cat1222.remove_family(fam2.id)
      @cat1222.should have(1).product_families
      @cat1221.should have(1).product_families
      [@cat122, @cat12, @cat1, @root].each do |cat|
        cat.should have(2).product_families
      end
      [@cat11, @cat13, @cat131, @cat2].each do |cat|
        cat.should have(0).product_families
      end
    end
    
    it "should progagate families when removing a product family, part II" do
      fam1 = ProductFamily.make!
      fam2 = ProductFamily.make!
      @cat1221.add_family(fam1.id)
      @cat1222.add_family(fam1.id)
      @cat1222.add_family(fam2.id)

      @cat1221.remove_family(fam1.id) # now empty
      @cat1221.should have(0).product_families
      @cat1222.should have(2).product_families
      [@cat122, @cat12, @cat1, @root].each do |cat|
        cat.should have(2).product_families
      end
      [@cat11, @cat13, @cat131, @cat2].each do |cat|
        cat.should have(0).product_families
      end
    end
    
    it "should progagate families when removing a product family, part III" do
      fam1 = ProductFamily.make!
      fam2 = ProductFamily.make!
      @cat1221.add_family(fam1.id)
      @cat1222.add_family(fam1.id)
      @cat1222.add_family(fam2.id)

      @cat1222.remove_family(fam2.id)
      @cat1221.should have(1).product_families
      @cat1222.should have(1).product_families
      [@cat122, @cat12, @cat1, @root].each do |cat|
        cat.should have(1).product_families
      end
      [@cat11, @cat13, @cat131, @cat2].each do |cat|
        cat.should have(0).product_families
      end
    end

    it "should progagate families when removing an interior category" do
      fam1 = ProductFamily.make!
      fam2 = ProductFamily.make!
      fam3 = ProductFamily.make!
      @cat1221.add_family(fam1.id)
      @cat1222.add_family(fam2.id)
      @cat1222.add_family(fam3.id)
    
      @cat1.destroy

      [@cat122, @cat12, @root].each do |cat|
        cat.should have(3).product_families
      end
      [@cat11, @cat13, @cat131, @cat2].each do |cat|
        cat.should have(0).product_families
      end
    end
  end
end
