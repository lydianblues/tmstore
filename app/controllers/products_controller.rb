class ProductsController < ApplicationController
  # 
  # Searching with Paging without Ajax: (TODO add Ajax)
  #
  # Searching and pagination uses two controller actions: 'index' and 'paginate'.
  # 
  # The only difference between these two actions is that 'index' will load
  # new search parameters into a cookie and start a new search, and 'paginate'
  # will retrieve the parameters from a cookie to continue a search.
  #
  # There is a ProductSearch model that encapsulates the search parameters and
  # drives the search.  However, this form is not directly exposed to the view
  # because search parameters are scattered in several links and forms on the
  # index page.  In a different view design, we could place the ProductSearch
  # instance in an instance variable and use it in a form_for construct.
  # 
  # The search parameters are some combination of:
  # 
  #  (a) a category ID, optional will default to the root category.  It may
  #      be a category at any level.  Its ancestors can be deduced from the
  #      category table.
  #  (b) a set of pairs of attributes and values
  #  (c) a search string to search the product description and keywords
  #  (d) a sort type (price ascending, price descending, etc.), also optional
  #
  # Every field that can be 'searched' corresponds to a named scope defined in
  # the product model class. The search is performed by chaining these named
  # scopes.
  #
  # The control flow is:
  #
  # (1)  The products/index action is invoked. The search parameters are saved
  #      in a cookie, the search is performed to populate the @products
  #      instance variable for the first page of results.  Several other
  #      instance variables are set for use in the search form or to set up
  #      links in the view that reflect the current search.
  #
  # (2)  The view creates a form and/or other controls that represents the
  #      current search and current page.
  # 
  # (3a) If the user submits the form or clicks on a control, the 'index'
  #      action of the controller will be invoked.  (Since this is an HTTP GET
  #      request, the search parameters will be visible in the URL.  This
  #      allows the user to bookmark the search.) Control returns to step (1).
  #
  # (3b) Alternatively, the user can click a pagination link in the products
  #      display.  This causes the products/paginate action action to be
  #      invoked.  The only parameter that needs to be passed in the page number.
  #      The current search parameters are retrieved from the cookie.  The 
  #      search function is invoked to populate the @products instance variable
  #      for the specifed page of results.  Continue with step (2).
  # 
   
  def index
    user_store_url
    @user = current_user
    cookies[:product_search] = {:value => YAML::dump(params)}
    do_search(params)
  end
  
  def paginate
    user_store_url
    search_params = {}
    if cookies[:product_search]
      search_params = YAML::load(cookies[:product_search])
    end
    do_search(search_params.merge(params.symbolize_keys))
  end
  
  # GET /products/1
  # GET /products/1.xml
  def show
    user_store_url
    @user = current_user
    @product = Product.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/new
  # GET /products/new.xml
  def new
    @product = Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
  end

  # POST /products
  # POST /products.xml
  def create
    @product = Product.new(params[:product])

    respond_to do |format|
      if @product.save
        flash[:notice] = 'Product was successfully created.'
        format.html { redirect_to(products_url) }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.xml
  def update
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update_attributes(params[:product])
        flash[:notice] = 'Product was successfully updated.'
        format.html { redirect_to(products_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.xml
  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to(products_url) }
      format.xml  { head :ok }
    end
  end
 
  private
 
  def do_search(params)
    product_search = ProductSearch.new(params)
    @products = product_search.search
    @choices = product_search.choices
    
    unless request.xhr?
      @category = Category.find_by_id(product_search.catid)
      @menu = @category.get_menu
      @attributes = @category.product_attributes
      @sort_by = product_search.sort_by
      @search_string = product_search.search_string
      @view_type = params[:view]
      if @category.id == Category.root_id
        @parent = nil
      else
        @parent = Category.find(@category.parent_id)
      end
    end
    
    respond_to do |format|
      format.html do
        if request.xhr?
          # This the case where we're requesting HTML content via Ajax.
          # Return an HTML fragment to fill in the Products table.
          # Do we ever get here?
          raise "Why are you here..."
          render :partial => 'products/products_table',
            :locals => {:products => @products}
        else
          render :action => 'index'
        end 
      end
      format.js do 
         render :partial => 'products/products_table',
           :locals => {:products => @products}
      end
      format.xml do
        render :xml => @products
      end
    end
  end
    
end
