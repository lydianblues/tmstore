# N.B. There is another 'product_attributes_helper' in the parent directory.

module Admin::ProductAttributesHelper
  #	
  # Path arg looks like:
  #
	# path_to_make_choice(catid, choices, attribute, range, search, 'flt')
	#
	def column_choices(attribute, path, format)
  	content_tag(:div, :style => "float:left;width:50%;text-align:center;") do
  	  puts "1"
  	  content_tag(:ul,
  	    :style => "list-style-type:none;list-style-position:outside;padding:0px;margin:0px;") do
  	      puts "2"
  	    attribute.attribute_ranges.each_with_index do |range, j|
  	      puts "3"
	        if (((format == 'left') && (j % 2 == 0)) ||
	            ((format == 'right') && (j % 2 == 1)) ||
	            (format == 'both'))
	            puts "4"
	          content_tag(:li, link_to(range_to_string(attribute, range), path))
	        end    
  	    end
  	  end
	  end
  end
	
end