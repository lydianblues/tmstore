module ProductsHelper
  
  # Generate an array that is in the correct format for the 
  # 'options_for_select' helper.
  def get_search_selections(parent_category, menu)    
    parent_category.name = "All Products" if parent_category.name == 'root'
    result = [ [parent_category.name, parent_category.id] ] 
    menu.each do |m|
      result << [m[:name], m[:id]]
    end
    result
  end
  
  def choice_made_for_attribute?(choices, attribute)
    choices.each do |c|
     return true if c[0] == attribute.id
    end
    false
  end
  
  def path_to_make_choice(catid, choices, attribute, 
    attribute_range, search_string, view_type)
    choices2 = choices.clone
    choices2 << [attribute.id, attribute_range.id]
    make_path(catid, search_string, choices2, view_type)
  end
  
  def path_to_rescind_choice(catid, choices, attribute,
    search_string, view_type)
    choices2 = choices.clone
    choices2.each_with_index do |c, j|
      if c[0] == attribute.id
        choices2.slice!(j)
        break
      end
    end
    make_path(catid, search_string, choices2, view_type)
  end
  
  # Get the choice that was made for the given attribute.
  def get_choice(choices, attribute)
    choices.each do |c|
      if c[0] == attribute.id
        return range_to_string(attribute, AttributeRange.find(c[1]))
      end
    end
    nil
  end
    
  #
  # Return an array of two-element arrays where the first element is
  # the name to display in the breadcrumb trail, and the second is the URL.
  # This function may be called for the 'admin_category_path' generator or
  # 'products_path' generater. 
  #
  def make_trail(category, choices, search_string, root_label,
    path_generator, view_type = nil)
    trail = category.get_trail(root_label)
    result = []
    
    trail.each do |t|
      if path_generator == :products_path
        result << [ t[1], send(path_generator,
          :catid => String(t[0]), :view => view_type) ]
      else
        result << [ t[1], send(path_generator, String(t[0])) ]
      end
    end
    
    myhash = {:catid => category.id}
    if view_type
      myhash.merge!({:view => view_type})
    end 
    
    # admin_category_path passes nil for 'search_string'.
    if search_string && !search_string.blank?
      myhash.merge!({:search => search_string})
      result << ["\"#{search_string}\"", send(path_generator, myhash)]
    end
    
    # admin_category_path passes nil for 'choices'.
    if choices
      choices.each_with_index do |c, i|
        attribute = ProductAttribute.find(c[0])
        range = AttributeRange.find(c[1])
        component = String(attribute.trail_cue) # to convert nil to empty string
        component << " " unless component.blank?
        component << range_to_string(attribute, range)
        myhash.merge!({
          "aid#{i + 1}".to_sym => String(c[0]),
          "arid#{i + 1}".to_sym => String(c[1])})
        result << [component, send(path_generator, myhash)]
      end
    end
    result
  end
  
  def url_to_filter_view(url)
    if url =~ /&amp;view=cat/
      url.gsub(/&amp;view=cat/, "&amp;view=flt")
    elsif url =~ /&amp;view=flt/
      url
    else
      url + "&amp;view=flt"
    end
  end
  
  def url_to_navigation_view(url)
    if url =~ /&amp;view=flt/
      url.gsub(/&amp;view=flt/, "&amp;view=cat")
    elsif url =~ /&amp;view=cat/
      url
    else
      url + "&amp;view=cat"
    end
  end
  
  # Return the photo id of the thumbnail to use for this product.
  def thumb_id(product) 
    thumbs = product.photos.active.usage("Thumb").sort_by_display_order
    if thumbs.size == 0
      return nil
    else
      return thumbs[0].id
    end
  end
 
  private
  
  def make_path(catid, search_string, choices, view_type)
    myhash = url_hash(catid, search_string, choices, view_type)
    products_path(myhash)
  end
  
  def url_hash(catid, search_string, choices, view_type)
    myhash = {}
    if catid
      myhash.merge!({:catid => String(catid)})
    end
    if !search_string.blank?
      myhash.merge!({:search => search_string})
    end
    if choices
      choices.each_with_index do |c, i|
        myhash.merge!({
          "aid#{i + 1}".to_sym => String(c[0]),
          "arid#{i + 1}".to_sym => String(c[1])})
      end
    end
    if view_type
      myhash.merge!({:view => view_type})
    end
    myhash
  end
  
=begin
  Key:
    GF = goto filter view
    GC = goto category view
    GP = if current category is not "root" 
      show goto parent category button (retain current view type)
    F = display "featured" products for current category context
    C = display category navigation
    A = display attributes (filters)
    CC = banner displaying current category context

    CC and GP are ALWAYS shown.

    |---------------------------------------------------------|
    | @view_type | @attributes.empty? | @menu.empty? |        | 
    |------------|--------------------|--------------|--------|
    |    -       |      true          |    true      | F      | 
    |------------|--------------------|--------------|--------|
    |    -       |      true          |    false     | C      |
    |------------|--------------------|--------------|--------|
    |    -       |      false         |    true      | A      |
    |------------|--------------------|--------------|--------|
    |   flt      |      false         |    false     | A, GC  |
    |------------|--------------------|--------------|--------|
    |   cat      |      false         |    false     | C, GA  |
    |---------------------------------------------------------|
    
=end

  def view_params(view_type, attributes, menu)
    @show_filters = false
    @show_navigation = false
    @show_goto_navigation = false
    @show_goto_filters = false
    @show_featured = false
		
    if attributes.empty?
      if menu.empty?
        @show_featured = true
      else
        @show_navigation = true
      end
    else
      if menu.empty?
        @show_filters = true
      else
        if view_type == "flt"
          @show_filters = true
          @show_goto_navigation = true
        else
          @show_goto_filters = true
          @show_navigation = true
        end
      end
    end
    @nav_class = "hidden" unless @show_navigation
    @flt_class = "hidden" unless @show_filters
    @nav_goto_class = "hidden" unless @show_goto_navigation
    @flt_goto_class = "hidden" unless @show_goto_filters
  end
	
  def full_photo_title(gallery_photo)
    full_photo = Photo.find(gallery_photo.full_photo_id)
    full_photo.title
  end
  
  
end
