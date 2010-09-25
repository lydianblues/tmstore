(function($) {
    $("#ajax-indicator").hide();
    <% if @category.errors.empty? %>
        <% if flash[:error] %>
            $("#message_box").html('<div id="flash_error">' +
	        '<%= escape_javascript(flash.delete(:error)) %></div>');
        <% else %>
            <% if flash[:notice] %>
                $("#message_box").html('<div id="flash_notice">' +
                    '<%= escape_javascript(flash.delete(:notice)) %></div>');
            <% end %>

            $("#families-content").html('<%= escape_javascript(render :partial => "families",
                :locals => {:families => @families, :category => @category}) %>');
            $("#attributes-content").html('<%= escape_javascript(render :partial => "attributes",
                :locals => {:attributes => @attributes}) %>');
            $("#product-family-count").text("Product Families: <%= @families.size %>");
            $("#attribute-count").text("Attributes: <%= @attributes.size %>");

        <% end %>
    <% else %>
        $("#message_box").html('<%= escape_javascript(error_messages_for(:category,
            :header_message => "Could not remove product family:")) %>');
        <% flash.discard(:notice) %>
        <% flash.discard(:warning) %>
    <% end %>
})(jQuery);
