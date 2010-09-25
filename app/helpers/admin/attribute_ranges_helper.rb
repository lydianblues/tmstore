module Admin::AttributeRangesHelper

  # :stopdoc:
  Conversion_Table = {
    "MB" => 
      {"GB" => lambda {|v| Float(v) /  1000},
       "TB" => lambda {|v| Float(v) / 1000000}},
    "GB" => 
      {"MB" => lambda {|v| Float(v) * 1000},
       "TB" => lambda {|v| Float(v) / 1000}}
  }
  # :startdoc:
  
  # Return a string representation of an AttributeRange.  This is
  # the representation used in left side-panel on the user products
  # page.
  def range_to_string(attribute, range)
    result = nil
    case attribute.atype
    when ProductAttribute::Atype_String
      result = range.string_val
    when ProductAttribute::Atype_Integer_Enum
      result, units = unnormalize_integer(attribute.units,
        range.units_low, range.integer_val_low)
      result << " " + units unless units.blank?
    when ProductAttribute::Atype_Integer
      low, units_low = unnormalize_integer(attribute.units,
        range.units_low, range.integer_val_low)
      high, units_high = unnormalize_integer(attribute.units,
        range.units_high, range.integer_val_high)
        
      if high.blank?
        result = low
        result << " " + units_low unless units_low.blank?
        result << " & up"
      elsif low.blank?
        result = "Up to " + high
        result << (" " + units_high) unless units_high.blank?
      else
        result = low
        result << " to " + high
        result << " " + units_high unless units_high.blank?
      end
    when ProductAttribute::Atype_Currency
      if range.integer_val_high == nil
        result = MoneyUtils.format(range.integer_val_low) + " & up"
      elsif range.integer_val_low == nil
        result = "Up to " + MoneyUtils.format(range.integer_val_high)
      else
       result = MoneyUtils.format(range.integer_val_low) + " to " +
         MoneyUtils.format(range.integer_val_high)
      end
    end
    result
  end
  
  # Helper for the form on the admin/product_attributes/edit page.  In this
  # form, the merchant/admin can enter values to define the attribute ranges.
  # The interpretation of the values depends on the attribute type as follows:
  # 
  # String:: enumerated string values
  # Integer Enum:: enumerated integer values
  # Integer:: the right-hand endpoints of half-open intervals. The last value is used as the left endpoint for one additional interval. For example, if the user enters 3, 8, and 9, then the intervals are [0, 3), [3, 8), [8, 9), and [9, nil). The final interval represents "9 & up".
  # Currency:: string values that can be parsed by MoneyUtils#parse.
  # 
  def attr_val_range(product_attribute, index)
    range = product_attribute.attribute_ranges[index]
    if range
      value = interval_separator(product_attribute, range)
    else
      value = nil
    end
    name = "product_attribute[attribute_ranges][][single]"
  	content_tag(:td) do
  	  content_tag(:span) do
  	    "#{index + 1}:"
  	  end
  	end +
  	content_tag(:td) do
  	  content_tag(:input, nil, :type => "text-field", :name => name, :value => value) 
  	end
  end

  # Convert all the attribute ranges for the given attribute into a
  # single string for use in a summary box.
  def single_string_ranges(attribute)
    result = ""
    case attribute.atype 
  
    when ProductAttribute::Atype_String
  	  attribute.strings.each do |v|
        result += "\"#{v}\" "
    	end
    	result.chop
  	
    when ProductAttribute::Atype_Integer_Enum
      result = attribute.integer_enums.join(" ")
    
    when ProductAttribute::Atype_Integer
  	  result = attribute.integers.join(" ")
		
  	when ProductAttribute::Atype_Currency
  		result = attribute.currency_ranges.join(" ")
  	end
  	result
  end

  private
  
  def unnormalize_integer(from, to, value)
    units = to.blank? ? from : to
    if (to.blank? || from.blank?)
      [String(value), units]
    elsif Conversion_Table[from] && Conversion_Table[from][to]
      v = Conversion_Table[from][to].call(value)
      [String(v).sub(/\.0*$/, ''), units]
    else
      raise "No conversion from #{from} to #{to}. Add to Conversion Table."
    end
  end

  def interval_separator(attribute, range)
    case attribute.atype 
    when ProductAttribute::Atype_Integer
      String(range.integer_val_high)
    when ProductAttribute::Atype_Integer_Enum
      String(range.integer_val_low)
    when ProductAttribute::Atype_String
      range.string_val
    when ProductAttribute::Atype_Currency
      result = MoneyUtils.format(range.integer_val_high)
    end
    
  end
end