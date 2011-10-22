class Admin::ProductSearchesController < ApplicationController
  
  before_filter :require_admin
  
  # This method is called when the form containing the search parameters is submitted.  It
   # saves the search parameters in a cookie for use in paging.
   def create
     admin_last_url
     cookies[:product_search] = {:value => YAML::dump(params[:product_search]),
         :path => admin_product_search_path}
     logger.info "Admin::ProductSearchesController#create params=#{params[:product_search]}"
     do_search params[:product_search]
   end

   # This method is called only through "will_paginate" to
   # get the indicated page of search results.
   def show
     admin_last_url
     search_params = YAML::load(cookies[:product_search])
     search_params[:page] = params[:page]
     do_search search_params
   end

   private

   def do_search(params)
     @product_search = ProductSearch.new(params)
     @products = @product_search.search
     respond_to do |format|
       format.html do
         render :template => 'admin/products/index', :layout => 'admin'
       end
       format.js do 
         render :partial => 'admin/products/products_table',
           :locals => {:products => @products}
       end
       format.xml { render :xml => @products }
     end
   end
end
