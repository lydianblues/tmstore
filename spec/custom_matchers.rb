module CustomMatchers
  RSpec::Matchers.define :contain_address do |address|
    match do |page|
      page.find("#address_first_name")['value'].should == address.first_name
      page.find("#address_last_name")['value'].should == address.last_name
      page.find("#address_email")['value'].should == address.email
      page.find("#address_street_1")['value'].should == address.street_1
      page.find("#address_city")['value'].should == address.city
      if address.country == "United States"
        # Note that the find on a 'select' tag with an attribute of 'value' returns
        # the value of the nested option tag that has selected='selected'.
        page.find("#address_state")['value'].should == address.state
      elsif address.country == "Canada"
        puts "Wanted: #{address.province}"
        puts "Found: #{page.find("#address_province")['value']}"
        page.find("#address_province")['value'].should == address.province
      else      
        page.find("#address_region")['value'].should == address.region
      end
    end
  end

  RSpec::Matchers.define :have_row_for_product_in_family do |name, family|
    match do |table|
      table_has_row_for_product_in_family?(table, name, family)
    end    
  end

  private

  def table_has_row_for_product_in_family?(table, name, family)
    found = false
    table.all("tr").each do |r|
      begin 
        a = r.find("td a")
        f = r.find("td:nth-child(2)")
      rescue Capybara::ElementNotFound
        next
      end
      return true if (a.text == name and f.text == family)
    end
    return false
  end

end


