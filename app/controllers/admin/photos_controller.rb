class Admin::PhotosController < ApplicationController
  
  layout "admin"
  
  self.allow_forgery_protection = false # Temporary during debugging TODO XXX.
  
  def edit
    admin_store_url
    @photo = Photo.find(params[:id])
    @product = Product.find(@photo.product_id)
    if @photo.usage_type == "Gallery"
      @full_photos = @product.photos.usage("Detail")
    end
  end
  
  def create
    @photo = Photo.new(params[:photo])
    if @photo.save
      flash[:notice] = 'Photo was successfully uploaded.'
    else
      flash[:error] = 'Photo upload failed. Did you supply a path name?'
    end
    redirect_to(:action => 'edit', :controller => '/admin/products' , :id => @photo.product_id)
  end
  
  def update
    
    admin_last_url
    @photo = Photo.find(params[:id])
    photo_params = params[:photo]
    @product = Product.find(@photo.product_id)    
    if @photo.usage_type == "Gallery"
      @full_photos = @product.photos.usage("Detail")
    end
    if photo_params[:hidden] == nil
      photo_params.merge! :hidden => false
    end
      
    if @photo.update_attributes(params[:photo])
      flash.now[:notice] = "Successfully updated photo params."
      
    else
      # @photo object has the errors.
    end
    # redirect_to(:action => 'edit', :controller => '/admin/photos' , :id => @photo.id)
    render :template => 'admin/photos/edit'
  end
  
  def show
    @photo = Photo.find(params[:id])
    send_data(@photo.data,
      :filename => @photo.file_name,
      :type => @photo.content_type,
      :disposition => "inline" )
  end
  
  def destroy
    photo = Photo.find(params[:id])
    if Photo.delete(params[:id])
      flash[:notice] = 'Photo was successfully deleted.'
    else
      flash[:error] = 'Photo could not be found.'
    end
    redirect_to(:action => 'edit', :controller => '/admin/products' , :id => photo.product_id)
  end
  
end
