class MystateInput < SimpleForm::Inputs::Base
  def input
    @builder.state_select(attribute_name, 'US', :include_blank => true, :prompt => "-- select a state --").html_safe
  end
end


