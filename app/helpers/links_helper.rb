module LinksHelper

  def create_links
    content_tag(:div, :id => "user_nav") do
      # controller.controller_name + "#" + controller.action_name + " | " +

      raw(unless controller.controller_name == "home" && controller.action_name == "show"
        link_to("Home", root_path) + " | "
      else
        ""
      end +

      unless controller.controller_name == "products" && controller.action_name == "index"
        link_to("Products", products_path) + " | " 
      else
        ""
      end +

      unless controller.controller_name == "cart" && controller.action_name == "show"
        link_to("Cart", current_cart_path) + " | "
      else
        ""
      end +

      unless controller.controller_name == "users" && controller.action_name == "show"
        link_to("Account", account_path) + " | "
      else
        ""
      end +

      if current_user
        link_to("Logout", destroy_user_session_path)
      else
        link_to("Register", new_user_registration_path) + " | " +
        link_to("Login", new_user_session_path)
      end +
      if current_user && current_user.admin?
        raw(" | " + link_to("Admin", '/admin/home'))
      else
        ""
      end)
    end
  end
end


