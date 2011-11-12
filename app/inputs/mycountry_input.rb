class MycountryInput < SimpleForm::Inputs::Base
  def input
    @builder.country_select(attribute_name, ['CA', 'US'],
      {:include_blank => true}, {:prompt => "-- select a country --" }).html_safe
  end
end
