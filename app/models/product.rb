class Product < ActiveRecord::Base

  include OracleInterface::AttributeMethods

  scope :in_category, lambda { |catid|
    if catid == Category.root_id
      Category.scoped
    else
      joins(:category_products).where("category_products.category_id = ?", catid)
    end
  }

  scope :attribute_filter, lambda { |attr_ranges|
    return scoped if attr_ranges.empty?
    joins = ""
    where_clause = ""
    conditions = []
    attr_ranges.each_with_index do |ar, i|
      attribute = ar[:attribute]
      range = ar[:range]

      joins << "INNER JOIN attribute_values av#{i} ON av#{i}.product_id = products.id "
      where_clause << "av#{i}.product_attribute_id = ? AND "
      conditions << [attribute.id]
      if attribute.atype == 'string'
        where_clause << "av#{i}.string_val = ?"
        conditions << range.string_val
      else
        if range.integer_val_low == nil
          where_clause << "av#{i}.integer_val < ?"
          conditions << range.integer_val_high
        elsif range.integer_val_high == nil
          where_clause << "av#{i}.integer_val >= ?"
          conditions << range.integer_val_low
        else
          where_clause << "av#{i}.integer_val >= ? AND " +
            "av#{i}.integer_val < ?"
            conditions << range.integer_val_low << range.integer_val_high
        end
      end
      where_clause << " AND "
    end

    where_clause.slice!(/ AND $/)
    conditions.unshift where_clause
    where(conditions).joins(joins)
  }

  # Note that "sort_type" already includes "ASC" or "DESC".
  scope :sort_on, lambda { |sort_type|
    order("products.#{sort_type}")
  }

  scope :product_family_id, lambda { |id|
    if id.blank?
      scoped
    else
      joins(:product_family).where("product_families.id = ?", id)
    end
  }

  scope :product_family_name, lambda {|name|
    if name.blank?
      scoped
    else
      joins(:product_family).where("REGEXP_LIKE(product_families.name, ? ,'i')", name)
    end
  }

  scope :key_words, lambda {|words|
    if words.blank?
      scoped
    else
      where(["REGEXP_LIKE(products.key_words, ? ,'i')", words.join('|')])
    end
  }

  scope :description, lambda {|desc|
    if desc.blank?
      scoped
    else
      where("REGEXP_LIKE(products.description, ? ,'i')", desc)
    end
  }

  scope :product_name, lambda {|name|
    if name.blank?
      scoped
    else
      where("REGEXP_LIKE(products.name, ? ,'i')", name)
    end
  }

  scope :product_id, lambda {|id|
    if id.blank?
      scoped
    else
      where("products.id = ?" , id)
    end
  }

  scope :search_all, lambda {|search|
    if search.blank?
      scoped
    else
      where("REGEXP_LIKE(products.description || ' ' || products.key_words " +
        "|| ' ' || products.name, ? ,'i')", search)
    end
  }

  scope :stock_level, lambda {|level|
    if level.blank?
      scoped
    elsif level == "low"
      where("products.qty_in_stock <= products.qty_low_threshold")
    elsif level == "out"
      where("products.qty_in_stock = ?", 0)
    end
  }

  # Restrict to the products that are not assigned to any category.
  scope :uncategorized,
    joins("LEFT OUTER JOIN category_products cp ON products.id = cp.product_id")
    .where("cp.category_id IS NULL")
  
  # Many to many relationship to Categories through the ProductCategories table.
  has_many :category_products
  has_many :categories, :through => :category_products
  has_many :photos, :dependent => :destroy
  has_many :attribute_values

  # The product family that this product belongs to.
  belongs_to :product_family

  validates_uniqueness_of :name
  validates_presence_of :name
  validate :valid_product_family

  validates_numericality_of :shipping_length, :shipping_width,
    :shipping_height, :shipping_weight, :only_integer => true

  validates_inclusion_of :shipping_units, :in => %w[Metric Imperial],
    :message => "should be Metric or Imperial"

  # Return the number of product attributes that this product has.
  def attribute_count
    product_family.product_attributes.size
  end

  # Setter method for the 'internal' price of a product.  This is
  # not an attribute, only a field of the product model itself.
  def price=(value)
    if value.instance_of?(String)
      cents = MoneyUtils.parse(value)
    else
      begin
        cents = Integer(value)
      rescue
        cents = nil
      end
    end
    if cents
      self.price_basis = cents
    else
      errors.add(:price_basis, "price can't be empty")
    end
  end

  # Getter method for the 'internal' price of a product. This is
  # not an attribute, only a field of the product model itself.
  def price
    MoneyUtils.format(self.price_basis)
  end

  #
  # Used as pseudo-attribute by the products controller.
  #
  # Add this product to the specified leaf categories.  The list
  # of leaf categories is assumed to be comprehensive:  the product
  # should be assigned to all these leaves and only these leaves.
  # For each leaf, propagate the product all the way up to the root.
  #
  def leaf_ids=(lids)

    # Development mode only.
    raise "Can't save leaf ids before product." if self.new_record?

    # Clear out all mention of the product from the entire tree.
    CategoryProduct.delete_all(["product_id = ?", self.id])

    lids.each do |lid|
      next if lid == "none"
      category = Category.find(lid)
      category.add_product(self.id)
     end
  end

  # Return an array of the leaf category ids for this product.
  def leaf_ids
    lids = []
    self.categories.leaves.each do |cat|
      lids << cat.id
    end
    lids
  end

  #
  # Merge an indicator into 'leaf_category_paths' that tells if
  # the current product is visible in that path.
  #
  def candidate_paths
    # All leaf categories for this product family.  This is an array
    # of hashes. Each hash has keys :catid and :path.
    candidates = self.product_family.leaf_category_paths

    # All leaf category ids that were previously selected for this
    # product.  This will be a subset of the candidates.
    current = self.leaf_ids

    candidates.each do |lcp|
      if current.include? lcp[:catid]
        lcp.merge! :selected => true
      else
        lcp.merge! :selected => false
      end
    end
    candidates
  end

   # Save the result of editing the photo set for this product.
   # The corresponding "get" method is just "product.photos".
   def photo_set=(photo_set)
     photo_set.each_pair do |photo_id, props|
       photo = Photo.find(photo_id)
       if props[:delete]
         self.photos.destroy(photo)
       else

         if props[:hidden] == "1"
           to_set = {:hidden => true}
         else
           to_set = {:hidden => false}
         end

         if props[:usage_type] =~ /Detail|Thumb|Gallery/
           to_set.merge!(:usage_type => props[:usage_type])
         end

         unless props[:display_order].blank?
           display_order = Integer(props[:display_order])
           if display_order >= Photo::MIN_DISPLAY_ORDER &&
             display_order <= Photo::MAX_DISPLAY_ORDER
             to_set.merge!(:display_order => display_order)
           end
         end

         photo.update_attributes(to_set)
       end
     end
   end

   # For bulk assignment from the products controller. The argument looks like:
   # {attribute_id => "red", attribute_id => 7, etc. }.
   def attribute_values=(attr_hash)
     attr_hash.each do |key, value|
       attribute = ProductAttribute.where(:id => key).first
       set_attribute_value(attribute, value) if attribute
     end
   end

   # Get the value of the the given attribute for this product.
   def get_attribute_value(attribute)
    values = read_attr_val(attribute.id)
    return nil unless values
    if attribute.atype == ProductAttribute::Atype_String
      return values[0]
    elsif attribute.atype == ProductAttribute::Atype_Currency
      MoneyUtils.format(values[1])
    else
      return Integer(values[1])
    end
  end

  # Set the value of this product for a given attribute.
  def set_attribute_value(attribute, value)

    # Development mode only.
    raise "Can't save attributes before product" unless self.id

    # If the product hasn't been saved yet we don't have a
    # product_id, so we can't write to the attribute values table.
    unless self.new_record?
      if attribute.atype == ProductAttribute::Atype_String
        str_val = value
        int_val = nil
      elsif attribute.atype == ProductAttribute::Atype_Currency
        str_val = nil
        int_val = MoneyUtils.parse(value)
      else
        # It is possible that the admin did not fill in a value for
        # a text field, so we get an empty string for "value". We
        # could implement a default value for the attribute (probably
        # stored in the attribute itself, but for now just store 0.)
        str_val = nil
        if value.blank?
          int_val = 0
        else
              int_val = Integer(value)
            end
      end
      write_attr_val(attribute.id, str_val, int_val)
    end
  end

  protected
  # An internal validation function.
  def valid_product_family
    begin
      ProductFamily.find(product_family_id)
    rescue
      errors.add :product_family, 'does not exist'
    end
  end

end
