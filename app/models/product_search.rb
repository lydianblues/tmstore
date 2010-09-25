#
# Get here from the Sort Bar on the products/index page, or from
# the product search facility on the admin/products/index page.
#
class ProductSearch
  
  # The maximum number of <aid, arid> pairs the user can specify in the URL.
  MAX_FILTERS = 8
  
  attr_accessor :keywords, :description, :sort_by, :stock_level, :page,
    :pf_name_or_id, :cat_path_or_id, :prod_name_or_id, :in_stock,
    :search_string, :catid
    
  attr_reader :menu, :choices
      
  def initialize(params = {})
    
    @cat_path_or_id = params[:cat_path_or_id]
    @catid = params[:catid]
    @prod_name_or_id = params[:prod_name_or_id]
    @pf_name_or_id = params[:pf_name_or_id]
    @prod_name_or_id = params[:prod_name_or_id]
    @description = params[:description] 
    @page = params[:page]
    @keywords = params[:keywords]
    @stock_level = params[:stock_level]
    @sort_by = params[:sort_by]
    
    # 'search_string' is used in form submission, and 'search' is used in
    # the encoded URL.  We normalize on 'search_string'.
    @search_string = params[:search_string]
    @search_string = params[:search] if search_string.blank?

    if @sort_by.blank?
      @sort_type = "name"
      @sort_by = "1"
    else
      # This should match the table in "products/_search_bar.html.rb".
      @sort_type = case sort_by
        when "1" then "name ASC"
        when "2" then "sales_rank DESC"
        when "3" then "price_basis ASC"
        when "4" then "price_basis DESC"
        when "5" then "review_rank DESC"
        else "name ASC"
      end
    end
    
    @per_page = 12 # XXX
    
    if @cat_path_or_id.blank?
      if @catid.blank?
        @catid = Category.root_id
      else
        @catid = Integer(@catid)
      end
    else
      if @cat_path_or_id =~ /^[\d]+$/
        @catid = Integer(@cat_path_or_id)
      else
        @catid = Category.path_to_id(@cat_path_or_id)
      end
    end
    
    unless @pf_name_or_id.blank?
      if @pf_name_or_id =~ /^[\d]+$/
        @pf_id = Integer(@pf_name_or_id)
      else
        @pf_name = @pf_name_or_id
      end
    end
    
    unless @prod_name_or_id.blank?
      if @prod_name_or_id =~ /^[\d]+$/
        @prod_id = Integer(@prod_name_or_id)
      else
        @prod_name = @prod_name_or_id
      end
    end
    
    unless @keywords.blank?
      @keywords_array = @keywords.split(' ')
    end
    
    # If a search string is given, we're already searching
    # the keywords and description.
    if @search_string
      @keywords_array = nil
      @description = nil
    end
    
    # Sets @choices and  @attr_ranges
    parse_attribute_choices(params)
  end
  
  def search
    Product.in_category(@catid)
     .product_name(@prod_name)
     .product_id(@prod_id)
     .key_words(@keywords_array)
     .description(@description)
     .search_all(@search_string)
     .stock_level(@stock_level)
     .product_family_name(@pf_name)
     .product_family_id(@pf_id)
     .attribute_filter(@attr_ranges)
     .sort_on(@sort_type)
     .paginate(:page => page, :per_page => @per_page)
  end
  
  private
  
  #
  # Let "aid" stand for an attribute_id, and "arid" stand for an attribute
  # range id.  Then URLs we use to keep track of the attribute range choices
  # that have been made look like:
  #
  # URL = ...?aid1=<aid>&arid1=<arid>&aid2=<aid>&arid2=<arid>?...
  #
  # The operations we want to do an a URL are (1) Removing all the (aid, arid)
  # pairs from a certain index onwards, (2) Removing a (aid, arid) pair from
  # the middle and adjusting the indices so that they remain consecutive, and
  # (3) adding a new (aid, arid) pair to the end.  Load the URL components into
  # an array for easier support of these operations. 
  #
  # The view helper class for the products controller has methods that use
  # the choices array. 
  #
  def parse_attribute_choices(params)
    @choices = []
    @attr_ranges = []
    for j in 1 .. MAX_FILTERS
      aid_key= "aid#{j}".to_sym
      arid_key = "arid#{j}".to_sym
      begin
        aid_key = Integer(params[aid_key])
        arid_key = Integer(params[arid_key])
        attribute = ProductAttribute.find(aid_key)
        range = AttributeRange.find(arid_key)
      rescue
        next
      else
        @choices << [aid_key, arid_key]
        @attr_ranges << {:attribute => attribute, :range => range}
      end
    end
  end
 
end
