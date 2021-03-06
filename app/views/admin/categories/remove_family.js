(function($) {
  <% if @category.errors.empty? %>
    <% unless flash[:error].blank? %>
      $("#message_box").html("<%=j flash_error %>");
    <% else %>
      <% unless flash[:notice].blank? %>
        $("#message_box").html("<%=j flash_notice %>");
      <% end %>
      $("#families-content").html('<%= escape_javascript(render :partial => "families",
        :locals => {:families => @families, :category => @category}) %>');
      $("#attributes-content").html('<%= escape_javascript(render :partial => "attributes",
        :locals => {:attributes => @attributes}) %>');
      $("#product-family-count").text("Product Families: <%= @families.size %>");
      $("#attribute-count").text("Attributes: <%= @attributes.size %>");
    <% end %>
  <% else %>
    $("#message_box").html("<%=j error_messages_for(:category,
     :header_message => 'Could not remove product family:') %>");
    <% flash.discard(:notice) %>
    <% flash.discard(:warning) %>
  <% end %>
})(jQuery);
