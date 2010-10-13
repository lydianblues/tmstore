class CategoryLoader
  
  def initialize
    myenv = ENV['RAILS_ENV']
    unless myenv =~ /test|development|production|cucumber/ 
      puts "Unknown Rails environment: #{myenv}"
      Process.exit
    end
    puts "Using #{myenv} environment."
    root = Category.find(Category.root_id)
    @catpath = [root]
  end

  def add_category(name)
    Category.create(:name => name, :parent_id => @catpath.last.id)
  end
  
  def add_product_family_to_category(category, family)
    category.add_family(family.id)
  end
  
  def make_product_families
    
    @basic_family = ProductFamily.create!(:name => "basic")
    @bedding_family = ProductFamily.create!(:name => "bedding")
    @towel_family = ProductFamily.create!(:name => "towels")
    
    @price_attribute = ProductAttribute.create!(
      :name => "Wholesale Price", 
      :gname => "Global Wholesale Price", 
      :atype => "currency", :any_choice => "Any Price", 
      :currency_ranges => 
        [{:low => nil, :high => 50, :priority => 1},
          {:low => 50, :high => 100, :priority => 2},
          {:low => 100, :high => 200, :priority => 3},
          {:low => 200, :high => nil, :priority => 4}])
      
    @color_attribute = ProductAttribute.create!(:name => "Color",
      :gname => "Global Colors", :sidebar_cols => 2,
      :atype => "string", :any_choice => "Any Color",
      :strings => [{:single => "White", :priority => 1},
                   {:single => "Blue", :priority => 2},
                   {:single => "Beige", :priority => 3}])
      
    @thread_count_attribute = ProductAttribute.create!(
      :name => "Thread Count", 
      :gname => "Global Thread Count",
      :atype => "integer",
      :any_choice => "Any Thread Count",
      :sidebar_cols => 2,
      :integers => 
        [{:low => nil, :high => 300, :priority => 1},
         {:low => 300, :high => 500, :priority => 2},
         {:low => 500, :high => 600, :priority => 3},
         {:low => 600, :high => 800, :priority => 4},
         {:low => 800, :high => 900, :priority => 5},
         {:low => 900, :high => nil, :priority => 6}])
      
    @sheet_size_attribute = ProductAttribute.create!(
      :name => "Sheet Size", :gname => "Global Sheet Size",
      :atype => "string", :any_choice => "Any Bedding Size",
      :strings => ["Twin", "Full", "Queen", "King", "California King"])
    
    @pattern_attribute = ProductAttribute.create!(
      :name => "Pattern", :gname => "Global Pattern", :sidebar_cols => 2,
      :atype => "string", :any_choice => "Any Pattern",
      :strings => ["Solid", "Striped", "Print", "Floral", "Plaid", 
        "Patchwork", "Paisley", "Polka Dot"])
        
    @thickness_attribute = ProductAttribute.create!(
      :name => "Thickness", 
      :gname => "Global Thickness",
      :atype => "integer", :any_choice => "Any Thickness",
      :trail_cue => "Thickness",
      :sidebar_cols => 2,
      :integers => 
        [{:low => nil, :high => 1, :priority => 1},
         {:low => 1, :high => 5, :priority => 2 },
         {:low => 5, :high => 7, :priority => 3},
         {:low => 7, :high => 9, :priority => 4},
         {:low => 9, :high => nil, :priority => 5}])
  
    @basic_family.add_attribute(@price_attribute)
    @basic_family.add_attribute(@color_attribute)
    
    @bedding_family.add_attribute(@price_attribute)
    @bedding_family.add_attribute(@color_attribute)
    @bedding_family.add_attribute(@thread_count_attribute)
    @bedding_family.add_attribute(@sheet_size_attribute)
    @bedding_family.add_attribute(@pattern_attribute)
    
    @towel_family.add_attribute(@thickness_attribute)
    @towel_family.add_attribute(@color_attribute)
    @towel_family.add_attribute(@pattern_attribute)
    
    1.upto(100) do |i|
      pf = ProductFamily.create!(:name => "Dummy_#{i}")
      pf.add_attribute(@pattern_attribute)
      pf.add_attribute(@thickness_attribute)
    end
    
  end
  
  def make_towels(catid1, catid2)
    
    start = Time.now
    count_secs = 0

    1.upto(1000) do |i|
     
      prod = Product.create(
        :name => "Towel#{i}",
        :price => rand(500),
        :shipping_length => 1,
        :shipping_width => 1,
        :shipping_height => 1,
        :shipping_weight => 1,
        :shipping_units => "Imperial",
        :product_family_id => @towel_family.id)
        
      color = %w[White Blue Beige][rand(3)]
      pattern = ["Solid", "Striped", "Print", "Floral", "Plaid", 
        "Patchwork", "Paisley", "Polka Dot"][rand(8)]
      thickness = rand(12)
      prod.attribute_values = {
        @thickness_attribute.id => thickness,
        @pattern_attribute.id => pattern,
        @color_attribute.id => color}
      prod.auto_prop = false
      inner_start = Time.now  
      prod.leaf_ids = [catid1, catid2]
      inner_elapsed =  Time.now - inner_start
      puts "per towel product category assign time: #{inner_elapsed}"
      count_secs += inner_elapsed
    end
    
    Category.find(catid1).propagate_products_up
    Category.find(catid2).propagate_products_up
    
    elapsed = Time.now - start
    puts "Total product category assign time = #{count_secs} seconds."
    puts "Total time = #{elapsed} seconds."
  end 

  def loadcats

    @catpath.push(add_category("Books"))
      add_category("Books")
      add_category("Kindle Books")
      add_category("Textbooks")
      add_category("Magazines")
    @catpath.pop

    @catpath.push(add_category("Movies, Music, & Games")) # 1st level
      add_category("Movies & TV")
      add_category("Blu-ray")
      add_category("Video On Demand")
      add_category("Music")
      add_category("MP3 Downloads")
      @catpath.push(add_category("Musical Instruments")) # 2nd level
        add_category("Accessories") # 3rd level
        add_category("Band & Orchestra") # 3rd level
        add_category("Bass Guitars") # 3rd level
        add_category("DJ, Electronic Music & Karaoke") # 3rd level
        add_category("Drums & Percussion") # 3rd level
        add_category("Folk & World Instruments") # 3rd level
        @catpath.push(add_category("Guitars")) # 3rd level
          add_category("Acoustic Guitars") # 4th level
          add_category("Electric Guitars")
          add_category("Acoustic-Electric Guitars")
          add_category("Classical & Nylon String Guitars")
          add_category("Bass Guitars")
          add_category("Electric Guitar Amplifiers")
          add_category("Acoustic Guitar Amplifiers")
          add_category("Guitar Effects")
          add_category("Guitar Accessories")
        @catpath.pop
        add_category("Keyboards") # 3rd level
        add_category("Live Sound & Stage") # 3rd level
        add_category("Recording Equipment") # 3rd level
        @catpath.pop

      add_category("Video Games")
      add_category("Game Downloads")
    @catpath.pop

    @catpath.push(add_category("Digital Downloads"))
    # Add 3rd and 4 levels
    @catpath.pop

    @catpath.push(add_category("Kindle"))
    # Add 3rd and 4 levels
    @catpath.pop

    @catpath.push(add_category("Computers & Office"))
    # Add 3rd and 4 levels
    @catpath.pop

    @catpath.push(add_category("Electronics"))
    # Add 3rd and 4 levels
    @catpath.pop

    @catpath.push(add_category("Home & Garden")) # 1st level
      add_category("Kitchen & Dining") # 2nd level
      add_category("Furniture & Decor") # 2nd level
      @catpath.push(add_category("Bedding & Bath")) # 2nd level
        @catpath.push(add_category("Bedding")) # 3rd level
          add_category("Bedding Ensembles") # 4th level
          add_category("Bed Pillows")
          add_category("Bedspreads & Coverlets")
          add_category("Blankets & Throws")
          add_category("Comforters")
          add_category("Decorative Pillows")
          add_category("Down Bedding")
          add_category("Duvet Covers")
          add_category("Feather Beds & Covers")
          add_category("Inflatable Beds")
          add_category("Kids\' Bedding")
          add_category("Quilts")
          add_category("Mattress Pads")
          add_category("Shams & Bed Skirts")
          @catpath.push(add_category("Sheets & Pillowcases"))
            add_product_family_to_category(@catpath.last, @basic_family)
            add_product_family_to_category(@catpath.last, @bedding_family)
          @catpath.pop
        @catpath.pop # now 2nd level on top of stack

        @catpath.push(add_category("Bath")) # 3rd level
          add_category("Bathroom Accessories")
          add_category("Bathroom Hardware")
          add_category("Bath Rugs")
          add_category("Bath Sheets")
          @catpath.push(add_category("Bath Towels"))
            add_product_family_to_category(@catpath.last, @towel_family)
            @towels_leaf_1 = @catpath.last.id
          @catpath.pop
          @catpath.push(add_category("Hand Towels"))
            add_product_family_to_category(@catpath.last, @towel_family)
            @towels_leaf_2 = @catpath.last.id
          @catpath.pop
          add_category("Shower Curtains & Accessories")
          add_category("Showerheads")
          add_category("Towel Warmers")
          add_category("Washcloths")
          add_category("Wastebaskets")
        @catpath.pop

        @catpath.push(add_category("Designers")) # 3rd level
          add_category("Barbara Barry")
          add_category("DKNY")
          add_category("Michael Kors")
          add_category("Natori")
          add_category("Nautica")
          add_category("Oscar de la Renta")
          add_category("Tommy Bahama")
          add_category("Tommy Hilfiger")
          add_category("Waterford")
        @catpath.pop

        @catpath.push(add_category("Brands")) # 3rd level
          add_category("AeroBed")
          add_category("Berkshire Blanket")
          add_category("Canon")
          add_category("Christy")
          add_category("Columbia")
          add_category("Crayola")
          add_category("Croscill")
          add_category("Freckles")
          add_category("Jane Seymour")
          add_category("Laura Ashley")
          add_category("Lenox")
          add_category("Martex")
          add_category("Olive Kids")
          add_category("Pinzon")
          add_category("Raymond Waites")
          add_category("Rose Tree")
          add_category("Royal Velvet")
          add_category("Serta")
          add_category("Simmons BeautyRest")
          add_category("Sleep Better by Carpenter")
          add_category("Sunbeam")
          add_category(":USE")
          add_category("Warmrails")
          add_category("Whisper Soft Mills")
        @catpath.pop

        @catpath.push(add_category("Related Categories")) # 3rd level
          add_category("Bath Scales") # 4th level
          add_category("Bedding & Bath Outlet") # 4th level
          add_category("Bedroom Furniture") # 4th level
          add_category("Lighting") # 4th level
          add_category("Storeage & Organization") # 4th level
          add_category("Window Treatments") # 4th level
        @catpath.pop

      @catpath.pop
      add_category("Home Appliances") # 3rd level
      add_category("Vacuums & Storage")
      add_category("Home Improvement")
      add_category("Patio, Lawn & Garden")
      add_category("Pet Supplies")
      add_category("Sewing, Craft & Hobby")
    @catpath.pop

    @catpath.push(add_category("Grocery, Health & Beauty"))
    # Add 3rd and 4 levels
    @catpath.pop

    @catpath.push(add_category("Toys, Kids & Baby"))
    # Add 3rd and 4 levels
    @catpath.pop

    @catpath.push(add_category("Apparel, Shoes & Jewelry"))
    # Add 3rd and 4 levels
    @catpath.pop

    @catpath.push(add_category("Sports & Outdoors"))
    # Add 3rd and 4 levels
    @catpath.pop

    @catpath.push(add_category("Tools, Auto & Industrial"))
    # Add 3rd and 4 levels
    @catpath.pop

    make_towels(@towels_leaf_1, @towels_leaf_2)
  end
  
  def print_summary
    puts "Categories: #{Category.all.size}"
    puts "Products: #{Product.all.size}"
    puts "Product Families: #{ProductFamily.all.size}"
    puts "Attributes: #{ProductAttribute.all.size}"
  end

end

cl = CategoryLoader.new
cl.make_product_families
cl.loadcats
Category.propagate_families
Category.generate_attributes
Category.propagate_products
cl.print_summary

