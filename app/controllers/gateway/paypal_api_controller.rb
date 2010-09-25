class Gateway::PaypalApiController < ApplicationController

  def invoke

    respond_to do |format|
      format.js # invoke.js
    end

=begin
    # @order = Order.find(params[:id])
    respond_to do |format|
      if @order.update_attributes(params[:order])
        flash[:notice] = 'Order was successfully updated.'
        format.html { redirect_to(@order) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
=end

  end


end
