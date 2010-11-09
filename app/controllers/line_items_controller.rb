class LineItemsController < ApplicationController

#  ssl_required :update, :destroy

  # Add Line Item to cart.  N.B. The id that is passed in is actually the product id.
  def update
    @order = current_order
    amt = params[:quantity].to_i
    if amt <= 0
      flash[:notice] = "Quantity must be greater than 0."
    else
      product = Product.find(params[:id])
      @line_item = LineItem.where(
        "product_id = #{params[:id]} AND order_id = #{@order.id}").first

      if (@line_item)
        @line_item.update_attributes(:quantity => amt)
      else
        @line_item = LineItem.create(:product => product, :quantity => amt,
                                    :unit_price => product.price_basis)
        @order.line_items << @line_item if @line_item.errors.empty?
      end
      if @line_item.errors.empty?
        flash[:notice] = "Updated quantities in cart."
      else
        # The line_item object contains error messages, but these will be lost in
        # the redirect (HTML case). Put an error message in the flash instead.
        flash[:error] = "Server Error: #{@line_item.errors.full_messages}"
      end
    end

    respond_to do |format|
      format.html { redirect_to current_cart_url }
      format.js # update.js.erb
    end

  end

  # The id that is passed in is the id of the Line Item to delete.
  def destroy
    @order = current_order
    @line_item = LineItem.find(params[:id])
    @line_item.destroy
    flash[:notice] = "Removed items from cart."

    respond_to do |format|
      format.html { redirect_to current_cart_url }
      format.js { render :action => 'update' }
    end

  end
end
