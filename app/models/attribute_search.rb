class AttributeSearch
  
  # These are needed by 'form_for'.
  attr_accessor :id, :category_path, :product_family, :name, :gname,
    :description, :requestor, :operations, :atype

  def initialize(params)
    
    return if params.blank?
    
    @name = params[:name]
    @gname = params[:gname]
    @description = params[:description]
    @atype = params[:atype]
   
    @category_path = params[:category_path]
    @product_family = params[:product_family]
    @operations = params[:operations]
    @requestor = params[:requestor]
    
    @page = params[:page]
    @per_page = 6 # XXX for testing.
    
    if @category_path.blank?
      @catid = nil
    else
      @catid = Category.path_to_id(params[:category_path])
    end
    
    pf = ProductFamily.find_by_name(@product_family)
    if pf
      @pfid = pf.id
    else
      @pfid = nil
    end
  end

  def search
    ProductAttribute.in_category(@catid).in_product_family(@pfid).attr_type(@atype).attr_name(@name).gname(@gname).description(@description).default_sort.paginate(:page => @page, :per_page => @per_page)
  end
  
end
