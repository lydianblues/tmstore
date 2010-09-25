class Admin::ProductFamiliesController < ApplicationController
  
  layout "admin"
  before_filter :require_admin
    
  # GET /admin_product_families
  # GET /admin_product_families.xml
  def index
    admin_store_url
    @product_families = ProductFamily.order("name ASC")
    respond_to do |format|
      # This is the default for HTML anyway, if you don't specify 
      # the template.
      format.html
      format.xml  { render :xml => @product_families }
      format.js {render :template => '/admin/product_families/index'}
    end
  end

  # GET /admin_product_families/1
  # GET /admin_product_families/1.xml
  def show
    admin_store_url
    @product_family = ProductFamily.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product_family }
    end
  end

  # GET /admin_product_families/new
  # GET /admin_product_families/new.xml
  def new
    leaf_ids = params[:leaves]
    @product_family = ProductFamily.new
    
    if params[:commit] == "Submit Selected"
      unless leaf_ids.blank?
        leaf_ids.each do |lid|
          begin
            cat = Category.find(lid)
          rescue ActiveRecord::RecordNotFound
          else
            @product_family.categories << cat
          end
        end 
      end
      admin_last_url
    elsif params[:commit] == "Clear All"
      admin_last_url
    else
      admin_store_url
    end
    
    @leaf_categories = Category.leaves
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product_family }
    end
  end

  # POST /admin_product_families
  # POST /admin_product_families.xml
  def create
    admin_store_url
    
    @product_family = ProductFamily.create(params[:product_family])
    leaf_ids = params[:leaf_ids]
    
    unless leaf_ids.blank?
      leaf_ids.each do |lid|
        cat = Category.find(lid)
        cat.add_family(@product_family.id)
      end
    end
    
    respond_to do |format|
      if @product_family.save
        flash[:notice] = 'Product Family was successfully created.'
        format.html { redirect_to(admin_product_families_path)}
        format.xml  { render :xml => @product_family, :status => :created,
          :location => @product_family }
      else
        format.html do
          @leaf_categories = Category.get_available_leaves
          render :action => "new"
        end
        format.xml  { render :xml => @product_family.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_product_families/1
  # PUT /admin_product_families/1.xml
  def update
    admin_store_url
    message = nil
    @product_family = ProductFamily.find(params[:id])
    if params[:commit] == "Update Product Family"
      
      if @product_family.update_attributes(params[:product_family])
        message = "Successfully updated product family"
      end
      
    elsif params[:commit] == "Add" or params[:commit] == "Add Attribute"
      pa = ProductAttribute.find(params[:attribute])
      @product_family.add_attribute(pa)
      
      if @product_family.errors.empty?
        message = "Successfully added attribute to product family"
      end
      
    elsif params[:commit] == "Remove Checked Attributes"
      params[:attrs_to_delete].each do |attr|
        @product_family.remove_attribute(Integer(attr))
      end
      
      if @product_family.errors.empty?
        message = "Sucessfully deleted attribute(s) from product family."
      end
      
    elsif params[:commit] == "Remove Attribute"
      @product_family.remove_attribute(Integer(params[:attribute]))
      
      if @product_family.errors.empty?
        message = "Sucessfully removed attribute from product family."
      end
    end
    
    search_params = get_search_params
    configure_search(search_params, params[:page], nil)
    
    flash.now[:notice] = message if message
    render_edit
  end

  # DELETE /admin_product_families/1
  # DELETE /admin_product_families/1.xml
  def destroy
    admin_store_url
    @product_family = ProductFamily.find(params[:id])
    @product_family.destroy

    respond_to do |format|
      format.html { redirect_to(admin_product_families_url) }
      format.xml  { head :ok }
    end
  end
  
  # GET /admin_product_families/1/edit
   def edit
     admin_store_url
     # Reuse the search params, in case the user hit "Go Back"
     # from the edit attribute page.  This will prevent the Edit
     # page from being reset.
     search_params = get_search_params
     configure_search(search_params, nil, params[:id])
   end
  
  # Goes with the 'edit' action.
  def paginate
    search_params = get_search_params
    configure_search(search_params, params[:page], params[:pfid])
    render_edit
  end
  
  # Goes with the 'edit' action.
  def search
    search_params = params[:attribute_search]
    cookies[:attribute_search] = {:value => YAML::dump(search_params)}
    configure_search(search_params, nil, params[:pfid])
    render_edit
  end
  
  private
  
  def get_search_params
    c = cookies[:attribute_search]
     if c 
       search_params = YAML::load(c)
     else
       search_params = nil
     end
  end
  
  def configure_search(params, page, pfid)
    params = {} unless params
    params.merge!(:page => page)
    @attribute_search = AttributeSearch.new(params)
    @product_attributes = @attribute_search.search
    @product_family = ProductFamily.find(pfid) if pfid
    @product_families = ProductFamily.all unless request.xhr?
  end
  
  def render_edit
    respond_to do |format|
      if @product_family.errors.empty?
        format.html do
          if request.xhr?
            # TODO render the attribute list including pagination links.
          else 
            render :action => "edit"
          end
        end
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product_family.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end

