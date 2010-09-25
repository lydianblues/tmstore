module Admin::ProductsHelper

  # Convert the attribute type (atype) constant strings into
  # a more readable format.
  def humanize_atype(product_attribute)
    case product_attribute.atype
      when ProductAttribute::Atype_String then "String"
  		when ProductAttribute::Atype_Integer then "Integer"
  		when ProductAttribute::Atype_Integer_Enum then "Integer Enum"
  		when ProductAttribute::Atype_Currency then "Currency"
    end
  end

  def input_attr_val(product, product_attribute)
  
    av = AttributeValue.where("product_id = ? AND product_attribute_id = ?",
      product.id, product_attribute.id).first

    # Maybe this is overkill, but it avoids a conditional statement
    # in every branch of the case statement. (Don't have to always
    # check if "av" is nil.)    
    unless av
      avp = Struct.new("AttributeValueProxy", :string_val, :integer_val, :units_low)
      av = avp.new(nil, nil, nil)
    end
      
    case product_attribute.atype 
  	  when ProductAttribute::Atype_String then 
  			select_tag(
  			  "[product][attribute_values][#{product_attribute.id}]",
  			  options_for_select(product_attribute.strings,
  			  av.string_val))
  		when ProductAttribute::Atype_Integer
  			text_field_tag(
  			  "[product][attribute_values][#{product_attribute.id}]",
  			  av.integer_val)
  		when ProductAttribute::Atype_Integer_Enum
  			select_tag(
  			  "[product][attribute_values][#{product_attribute.id}]",
  			  options_for_select(product_attribute.integer_enums,
  			  String(av.integer_val)))
  		when ProductAttribute::Atype_Currency
  			val = av.integer_val
  			val = 0 unless val
  			text_field_tag(
  			  "[product][attribute_values][#{product_attribute.id}]",
  			  MoneyUtils.format(val))
    end
  
  end
end
