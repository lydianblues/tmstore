class Admin::ProductAttributesController < ApplicationController
  
  layout "admin"
  before_filter :require_admin
  
  def index
    admin_store_url
    @product_families = ProductFamily.all
    do_search(nil, nil)
  end
  
  def paginate
    c = cookies[:attribute_search]
    if c 
      search_params = YAML::load(c)
    else
      search_params = nil
    end
    do_search(search_params, params[:page])
  end
  
  def search
    search_params = params[:attribute_search]
    cookies[:attribute_search] = {:value => YAML::dump(search_params)}
    do_search(search_params, nil)
  end

  # GET /admin_product_attributes/1
  # GET /admin_product_attributes/1.xml
  def show
    admin_store_url
    @product_attribute = ProductAttribute.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product_attribute }
    end
  end

  # GET /admin_product_attributes/new
  # GET /admin_product_attributes/new.xml
  def new
    admin_store_url
    @product_attribute = ProductAttribute.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product_attribute }
    end
  end

  # GET /admin_product_attributes/1/edit
  def edit
    admin_store_url
    @product_attribute = ProductAttribute.find(params[:id])
    @product_families = @product_attribute.product_families
  end

  # POST /admin_product_attributes
  # POST /admin_product_attributes.xml
  def create
    @product_attribute = ProductAttribute.new(params[:product_attribute])
    if @product_attribute.save
      flash[:notice] = 'Product Attribute was successfully created.'
      respond_to do |format|
        format.html { redirect_to(admin_product_attributes_path)}
        format.xml  { render :xml => @product_attribute, :status => :created, 
          :location => @product_attribute }
      end
    else
      admin_last_url
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @product_attribute.errors,
          :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_product_attributes/1
  # PUT /admin_product_attributes/1.xml
  def update
    admin_last_url
    @product_attribute = ProductAttribute.find(params[:id])
    @product_families = @product_attribute.product_families
    case params[:commit]
      when "Clear Values"
        @product_attribute.attribute_ranges.clear
        flash[:notice] = "Attribute Ranges successfully cleared."
      when "Delete Attribute"
        begin
          @product_attribute.transaction do
            AttributeRange.delete_all(["product_attribute_id = ?", @product_attribute.id])
            FamilyAttribute.delete_all(["product_attribute_id = ?", @product_attribute.id])
            CategoryAttribute.delete_all(["product_attribute_id = ?", @product_attribute.id])
            AttributeValue.delete_all(["product_attribute_id = ?", @product_attribute.id])
            ProductAttribute.delete(@product_attribute.id)
          end
        rescue
          flash[:error] = "Attribute deletion failed."
        else
          flash[:notice] = "Attribute was successfully deleted."
        end
      
      when "Submit Changes"
        @product_attribute.update_attributes(params[:product_attribute])
        if @product_attribute.save
           flash.now[:notice] = 'Attribute was successfully updated.'
        end
        # If the save fails, the Product Attribute model fields contain the error.
    end
    respond_to do |format|
      format.html { render :action => "edit" }
    end

  end

  # DELETE /admin_product_attributes/1
  # DELETE /admin_product_attributes/1.xml
  def destroy
    @product_attribute = ProductAttribute.find(params[:id])
    @product_attribute.destroy

    respond_to do |format|
      format.html { redirect_to(admin_product_attributes_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def do_search(params, page)
    params = {} unless params
    params.merge!(:page => page)
    @attribute_search = AttributeSearch.new(params)
    @product_attributes = @attribute_search.search
    
    xhr = request.headers["X-Requested-With"] == "XMLHttpRequest"
    unless xhr
      @product_families = ProductFamily.all
    end
    
     respond_to do |format|
       format.html do
         if xhr
           render :partial => '/admin/products/products_table',
             :layout => false, :locals => {:products => @product_attributes}
         else
           render :action => 'index'
         end 
       end
       format.xml { render :xml => @product_atributes }
       format.js { render :layout => false }
     end
  end
  
end


