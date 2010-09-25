Factory.define :braintree_credit_card do |c|
  c.ccnumber "4111111111111111"
  c.cvv "999"
  c.ccexp "1010"
end

Factory.define :user do |u|
  u.sequence(:login) { |n| "chaz#{n}" }
  u.password "rugrats"
  u.password_confirmation { |u| u.password }
  u.sequence(:email) { |n| "chaz#{n}@thirdmode.com" }
  u.admin false
end

Factory.define :admin, :parent => :user do |a|
  a.admin true
  a.login "admin"
  a.password "rugrats"
end

Factory.define :admin2, :parent => :user do |a|
  a.admin true
  a.login "admin2"
  a.password "rugrats"
end
    
Factory.define :address do |f|
  f.first_name "Chaz"
  f.last_name "Finster"
  f.street_1 "Rugrats Lane"
  f.city "Saskatoon"
  f.province "Saskatchewan"
  f.country "Canada"
  f.postal_code  "S7K 0J5"
  f.email "chaz@rugrats.com"
  f.phone_number "(306) 975-3240"
end

Factory.define :message do |m|
  m.created_at "2008-05-01".to_time
  m.title "foo"
  m.text "bar"
  m.association :recipient, :factory => :user
end

Factory.define :line_item do |l|
    l.created_at "2009-05-08".to_time
    l.unit_price 23.11
    l.quantity 3
end

def random_atype 
  case rand 4
    when 0 then "integer_enum"
    when 1 then "integer"
    when 2 then "string"
    when 3 then "currency"
  end
end

Factory.sequence :product_family_name do |n|
  "Product Family #{n}"
end

Factory.define :product_family do |pf|
  pf.name {Factory.next(:product_family_name)}
end

Factory.sequence :product_attribute_name do |n|
  "Product Attribute #{n}"
end

Factory.define :product_attribute do |pa|
  pa.name {Factory.next(:product_attribute_name)}
  pa.gname {|a| "Global #{a.name}"}
  pa.atype {random_atype}
end

Factory.sequence :product_name do |n|
  "product_#{n}"
end

Factory.define :product do |p|
  p.name {Factory.next(:product_name)}
  p.price "2044"
  p.shipping_length 15
  p.shipping_width 12
  p.shipping_height 6
  p.shipping_weight 10
  p.shipping_units "Imperial"
  p.association :product_family
end

Factory.sequence :category_name do |n|
  "Category #{n}"
end

Factory.define :category do |c|
  c.name {Factory.next(:category_name)}
end
