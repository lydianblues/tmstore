class ProvinceInput < SimpleForm::Inputs::Base
  def input
    @builder.state_select(attribute_name, 'CA', :prompt => "-- select a province --").html_safe
  end
end
