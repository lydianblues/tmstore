class PhotosController < ApplicationController
   
  # All a non-admin can do is view photos.
  def show
    @photo = Photo.find(params[:id])
    send_data(@photo.data,
      :filename => @photo.file_name,
      :type => @photo.content_type,
      :disposition => "inline" )
  end
  
end
