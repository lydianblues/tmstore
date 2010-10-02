require 'spec_helper'

class Category
  def refresh
    cat = Category.find(self.id)
    self.parent_id = cat.parent_id
    self.name = cat.name
  end
end

def make_category(args)
  c = Category.make(args)
  c.save
  c
end

describe Category do
  
  before(:each) do
    @root = Category.find(Category.root_id)
  end
  
  context "root has no children" do
    it "should be a leaf with correct pathname" do
      @root.should be_a_leaf
      @root.full_path.should == "/"
    end
    
    it "should allow associating a product family" do
      fam = ProductFamily.make
      fam.save
      @root.add_family(fam.id)
      @root.should have(1).product_families
    end
    
    it "should create a category given valid attributes" do
      cat = make_category(:parent_id => @root.id)
      Category.find(:all).should have(2).categories
      cat.full_path.should == "/#{cat.name}"
    end
  end
  
  context "root has children" do
    before(:each) do
      @root = Category.find(Category.root_id)
      @cat1 = make_category(:parent_id => @root.id )
      @cat2 = make_category(:parent_id => @root.id )
      @cat11 = make_category(:parent_id => @cat1.id )
      @cat12 = make_category(:parent_id => @cat1.id )
      @cat13 = make_category(:parent_id => @cat1.id )
      @cat121 = make_category(:parent_id => @cat12.id )
      @cat122 = make_category(:parent_id => @cat12.id )
      @cat123 = make_category(:parent_id => @cat12.id )
      @cat131 = make_category(:parent_id => @cat13.id )
      @cat1221 = make_category(:parent_id => @cat122.id )
      @cat1222 = make_category(:parent_id => @cat122.id )
    end
  
    it "should identify leaf and non-leaf categories" do
      @root.should_not be_a_leaf
      @cat1.should_not be_a_leaf
      @cat2.should be_a_leaf
      @cat11.should be_a_leaf
      @cat12.should_not be_a_leaf
      @cat13.should_not be_a_leaf
      @cat121.should be_a_leaf
      @cat122.should_not be_a_leaf
      @cat123.should be_a_leaf
      @cat131.should be_a_leaf
      @cat1221.should be_a_leaf
      @cat1222.should be_a_leaf
    end
    
   it "should generate correct pathnames" do
      @cat1.full_path.should == "/#{@cat1.name}"
      @cat2.full_path.should == "/#{@cat2.name}"
      @cat11.full_path.should == "/#{@cat1.name}/#{@cat11.name}"
      @cat12.full_path.should == "/#{@cat1.name}/#{@cat12.name}"
      @cat13.full_path.should == "/#{@cat1.name}/#{@cat13.name}"
      @cat121.full_path.should == 
        "/#{@cat1.name}/#{@cat12.name}/#{@cat121.name}"
      @cat122.full_path.should ==
        "/#{@cat1.name}/#{@cat12.name}/#{@cat122.name}"
      @cat123.full_path.should == 
        "/#{@cat1.name}/#{@cat12.name}/#{@cat123.name}"
      @cat131.full_path.should == 
        "/#{@cat1.name}/#{@cat13.name}/#{@cat131.name}"
      @cat1221.full_path.should ==
        "/#{@cat1.name}/#{@cat12.name}/#{@cat122.name}/#{@cat1221.name}"
      @cat1222.full_path.should ==
        "/#{@cat1.name}/#{@cat12.name}/#{@cat122.name}/#{@cat1222.name}"
    end
    
    it "should correctly delete interior category" do 
      @cat12.destroy
      Category.find(:all).should have(11).categories
      @cat121.refresh
      @cat121.parent_id.should == @cat1.id
      @cat122.refresh
      @cat122.parent_id.should == @cat1.id
      @cat123.refresh
      @cat123.parent_id.should == @cat1.id
    end
    
    it "should correctly delete leaf category" do
      @cat131.destroy
      Category.find(:all).should have(11).categories
      @cat13.get_children.should be_empty
    end
    
    it "should correctly reparent an interior node" do
      @cat12.reparent(@cat2.id)
      @cat12.parent_id.should == @cat2.id
      @cat1.get_children.should have(2).subcategories
    end

    it "should not be able to add product family to root category" do
      fam = ProductFamily.make
      fam.save
      @root.add_family(fam.id)
      @root.should have(0).product_families
      @root.errors.should_not be_empty
    end
    
  end 
end
