module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /the manage categories page/
        admin_categories_path
    
    when /the manage products page/
      admin_products_path
      
    when /the products page/
      products_path
      
    when /the page to enter my billing address/
      new_address_billing_path
      
    when /the page to edit my billing address/
      edit_address_billing_path
      
    when /the page to enter my shipping address/
      new_address_shipping_path
      
    when /the page to edit my shipping address/
      edit_address_shipping_path
      
    when /the review order page/
      new_order_path
      
    when /the shopping cart page/
      current_cart_path
      
    when /the order review page/
      new_order_path
      
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
