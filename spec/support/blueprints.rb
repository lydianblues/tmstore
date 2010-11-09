require 'machinist/active_record'

CreditCard.blueprint do

end

CreditCard.blueprint(:braintree) do
  ccnumber { "4111111111111111" }
  cvv { "999" }
  ccexp { "1010" }
end

User.blueprint do
  login { "chaz#{sn}" }
  password { "rugrats" }
  password_confirmation { "#{object.password}" }
  email { "#{object.login}@thirdmode.com" }
  admin { false }
end

User.blueprint(:admin) do
  login { "admin" }
  email { "lydianblues@gmail.com"}
  password { "rugrats" }
  password_confirmation { "rugrats" }
  login { "admin" }
  admin { true }
end

User.blueprint(:admin2) do
  login { "admin2" }
  admin { true }
end

Address.blueprint do
  first_name { "Chaz" }
  last_name { "Finster" }
  street_1 { "Rugrats Lane" }
  city { "Saskatoon" }
  province { "Saskatchewan" }
  country { "Canada" }
  postal_code  { "S7K 0J5" }
  email { "chaz@rugrats.com" }
  phone_number { "(306) 975-3240" }
end

Message.blueprint do
  created_at { "2008-05-01".to_time }
  title { "foo" }
  text { "bar" }
  recipient
end

LineItem.blueprint do
  created_at { "2009-05-08".to_time }
  unit_price { 23.11 }
  quantity { 3 }
end

ProductFamily.blueprint do
  name { "Product Family #{sn}" }
end

def random_atype 
  case rand 4
    when 0 then "integer_enum"
    when 1 then "integer"
    when 2 then "string"
    when 3 then "currency"
  end
end

ProductAttribute.blueprint do
  name { "product attribute #{sn}" }
  gname { "Global #{object.name}" }
  atype { random_atype}
end

Product.blueprint do
  product_family
  name { "product_#{sn}" }
  price { "2044" }
  shipping_length { 15 }
  shipping_width { 12 }
  shipping_height { 6 }
  shipping_weight { 10 }
  shipping_units { "Imperial" }
end

Category.blueprint do
  name { "category_#{sn}" }
end

Category.blueprint(:root) do
  name { "root" }
  parent_id { nil }
  depth { 0 }
end

