=begin rdoc

A ProductAttribute represents a feature or characteristic of a Product.
(It could have been called simply 'Attribute' but that seems to cause
a naming conflict in Rails).  A product attribute has a one-to-many
association with instances of AttributeRange.  The attribute ranges
define the legal values for the attribute (like defining the "range"
of a function in Mathematics.) 

A product attribute can be created as an independent entity.  It can be
added later to ProductFamily instances.  One of the roles of
a product family is to function as a container for a set of (product)
attributes.  When a product is added to a product family, the actual
<em>value</em> for each attribute (for that product in the given product
family) may be defined.

=end
class ProductAttribute < ActiveRecord::Base
  
  validates_presence_of :gname
  validates_uniqueness_of :gname
  validates_presence_of :name
  
  has_many :category_attributes
  has_many :categories, :through => :category_attributes
  
  has_many :family_attributes
  has_many :product_families, :through => :family_attributes
  
  has_many :attribute_ranges, :dependent => :delete_all,
    :order => "priority ASC"
    
  before_save :default_choice
  def default_choice()
    if any_choice.blank?
      self.any_choice = "Any " + name
    end
  end

  #--
  # Constant values for the atype field.
  #++
  Atype_Integer_Enum = "integer_enum"
  Atype_Integer = "integer"
  Atype_String = "string"
  Atype_Currency = "currency"

  scope :attr_type, lambda {|atype| 
    if atype.blank?
      scoped
    else
      where(:atype => atype)
    end
  }
 
  scope :attr_name, lambda {|name| 
    if name.blank?
      scoped
    else
      where("REGEXP_LIKE(product_attributes.name, ? ,'i')", name)
    end
  }
          
  scope :gname, lambda {|gname|
    if gname.blank?
      scoped
    else
      where("REGEXP_LIKE(product_attributes.gname, ? ,'i')", gname)
    end
  }
      
  scope :description, lambda {|desc| 
    if desc.blank?
      scoped
    else
      where("REGEXP_LIKE(product_attributes.description, ? ,'i')",desc)
    end
  }

  # Narrows the search to all attributes in the given product family
  scope :in_product_family, lambda {|pfid|
    if pfid
      joins(:family_attributes)
      .where("family_attributes.product_family_id = ?", pfid)
    else 
      scoped
    end
  }
   
  # Narrows the search to the attributes in common to ALL the product families
  # associated with the given category.
  scope :in_category, lambda {|catid|
    if catid 
      joins(:category_attributes)
      .where("category_attributes.category_id = ?", catid)
    else
      scoped
    end
  }
    
  scope :default_sort, order("name ASC, gname ASC")
    
  # Next two lines for the "will_paginate" pagination.
  cattr_reader :per_page
  @@per_page = 2
  
  def attribute_ranges=(ranges)
    case atype
    when Atype_Integer_Enum
      self.integer_enums = ranges
    when Atype_String
      self.strings = ranges
    when Atype_Integer
      self.integers = ranges
    when Atype_Currency
      self.currency_ranges = ranges
    end
    
  end
  
  #
  # For bulk assignent of attribute ranges of an "Atype_String" attribute.
  # 
  # The argument is either an array of hashes with a single key :single, 
  # or it is simply an array of strings.  In both cases,
  # the priority is assigned from the array index.
  #
  def strings=(ranges)
    if self.atype == Atype_String
      attribute_ranges.clear
      ranges.each_with_index do |ar, ix|
        if ar.is_a? String
          value = ar
          priority = ix + 1
        elsif ar.is_a? Hash
          value = ar[:single]
          priority = ix + 1
        else
          next
        end
        next if value.blank?
        attribute_ranges << 
          AttributeRange.new(:string_val => value, :priority => priority)
      end
    end
  end
  
  #
  # Return the enum choices for an "Atype_String" attribute.  I.e. these
  # are the string values contained in the range objects associated with
  # this product attribute.
  #
  def strings
    values = []
    if self.atype == Atype_String
      attribute_ranges.each do |v|
        values[v.priority - 1] = v.string_val
      end
    end
    values
  end
  
  #
  # For bulk assignent of attribute ranges of an "Atype_Integer" attribute.
  # The argument is an array of hashes.  Two kinds of hashes are supported:
  # {:single => <interval separator>} or {:low => <left endpoint>,
  # {:right => <right endpoint>}.  In both cases, the priority is derived
  # from the array index.
  #
  def integers=(intervals)
    if self.atype == Atype_Integer
      attribute_ranges.clear
      intervals.each_with_index do |ar, ix|
        
        if ar[:single]
          if ix == 0
            ar_low = nil
            ar_high = ar[:single]
          elsif ix == intervals.size - 1
            ar_low = ar[:single]
            ar_high = nil
          else
            ar_low = intervals[ix - 1][:single]
            ar_high = ar[:high] = ar[:single]
          end
        else
          ar_low = ar[:low]
          ar_high = ar[:high]
        end
        
        priority = ar[:priority] 
        priority = ix + 1 if priority.blank?
        
        ar_low = nil if ar_low.blank?
        ar_high = nil if ar_high.blank?
        
        next unless ar_low || ar_high
        
        begin
          ar_low = Integer(ar_low) if ar_low
          ar_high = Integer(ar_high) if ar_high
        rescue
          next
        end
        
        attribute_ranges << 
          AttributeRange.new(:integer_val_low => ar_low,
            :integer_val_high => ar_high, :units_low => ar[:units_low],
            :units_high => ar[:units_high], :priority => priority)
      end
    end
  end
  
  def integers
    ranges = []
    if self.atype == Atype_Integer
      attribute_ranges.each do |ar|
        left = ar.integer_val_low
        left = 0 unless left
        right = ar.integer_val_high
        right = "& up" unless right
        left = String(left)
        right = String(right)
        ranges << "[" + left + ", " + right + ")"
      end
    end
    ranges
  end
  
  #
  # For bulk assignent of attribute ranges of an "Atype_Integer_Enum" attribute.
  #
  def integer_enums=(enums)
    if self.atype == Atype_Integer_Enum
      attribute_ranges.clear
      enums.each_with_index do |ar, ix|
        priority = nil
        if ar[:single]
          ar_low = ar[:single]
        else
          ar_low = ar[:low]
          priority = ar[:priority]
        end
        priority = ix + 1 if priority.blank?
        begin
          ar_low = Integer(ar_low)
        rescue
          next
        end
        attribute_ranges << 
         AttributeRange.new(:integer_val_low => ar_low,
           :units_low => ar[:units_low], :priority => priority)
      end
    end
  end
   
  def integer_enums
    ranges = []
    if self.atype == Atype_Integer_Enum
       attribute_ranges.each do |ar|
         ranges << String(ar.integer_val_low)
      end
    end
    ranges
  end
   
  #
  # For bulk assignment of attribute ranges of an "Atype_Currency" attribute.
  #
  def currency_ranges=(ranges)
    if self.atype == Atype_Currency
      attribute_ranges.clear
      
      ranges.each_with_index do |ar, ix|
        if ar[:single]
          if ix == 0
            ar_low = nil
            ar_high = ar[:single]
          elsif ix == ranges.size - 1
            ar_low = ar[:single]
            ar_high = nil
          else
            ar_low = ranges[ix - 1][:single]
            ar_high = ar[:high] = ar[:single]
          end
        else
          ar_low = ar[:low]
          ar_high = ar[:high]
        end
        
        priority = ar[:priority] 
        priority = ix + 1 if priority.blank?
        
        ar_low = nil if ar_low.blank?
        ar_high = nil if ar_high.blank?
       
        next unless ar_low || ar_high
        
        begin
          ar_low = MoneyUtils.parse(String(ar_low)) if ar_low
          ar_high = MoneyUtils.parse(String(ar_high)) if ar_high
        rescue
          next
        end

        attribute_ranges << 
          AttributeRange.new(:integer_val_low => ar_low,
            :integer_val_high => ar_high, :units_low => ar[:units_low],
            :units_high => ar[:units_high], :priority => priority)
      end
    end
  end
  
  def currency_ranges
    ranges = []
    if self.atype == Atype_Currency
      attribute_ranges.each do |ar|
        left = ar.integer_val_low
        if left == nil
          left = 0
        end
        left = MoneyUtils.format(left)
           
        right = ar.integer_val_high
        if right == nil
          right = "& up"
        else
          right = MoneyUtils.format(right)
        end
        ranges << "[" + left + ", " + right + ")"
      end
    end
    ranges
  end
   
end
