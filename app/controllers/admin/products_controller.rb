class Admin::ProductsController < ApplicationController

  layout "admin"

  # GET /products
  # GET /products.xml
  def index
    admin_store_url
    @product_search = ProductSearch.new
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
  end

  # GET /products/1
  # GET /products/1.xml
  def show
    admin_store_url
    if params[:id] == "search"
      # This happens when javascript is disabled and the user clicks
      # on the will_paginate links.
      redirect_to :action => "index"
     else
      @product = Product.find(params[:id])
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @product }
      end
    end
  end

  # GET /products/new
  # GET /products/new.xml
  def new
    @product = Product.new

    if params[:family_id]
      pfid = params[:family_id]
      if pfid
        @product_family = ProductFamily.find(pfid)
        @product.product_family = @product_family
      end
      admin_last_url
    else
      admin_store_url
    end

    @product_families = ProductFamily.all(:order => "name ASC")

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/1/edit
  def edit
    admin_store_url
    @product = Product.find(params[:id])
    @product_family = @product.product_family
    @product_attributes = @product_family.product_attributes
    @photo = Photo.new(:product_id => @product.id)
    @candidate_paths = @product.candidate_paths
  end

  # POST /products
  # POST /products.xml
  def create
    admin_store_url
    @product = Product.new(params[:product])

    pfid = params[:product][:product_family_id]
    if pfid
      @product_family = ProductFamily.find(pfid)
      @product.product_family = @product_family
    end

    respond_to do |format|

      if @product.save
        flash[:notice] = 'Product was successfully created.'
        format.html {redirect_to edit_admin_product_path(@product) }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        format.html do
          @product_families = ProductFamily.all(:order => "name ASC")
          render :action => "new"
        end
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
        format.html { redirect_to(:action => :edit) }
        format.xml  { head :ok }
      else
        flash.now[:notice] = 'Product updated failed.'
        format.html do
          admin_last_url
          @product_family = @product.product_family
          @product_attributes = @product_family.product_attributes
          @photo = Photo.new(:product_id => @product.id)
          @candidate_paths = @product.candidate_paths
          render :action => "edit"
        end
        # format.html { redirect_to(:action => :edit) }
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
      format.html { redirect_to(admin_products_url) }
      format.xml  { head :ok }
    end
  end

end
