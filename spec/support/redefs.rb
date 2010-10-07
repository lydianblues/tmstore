# When we use make! as provided by machinist, the the objects so created in
# the database aren't rolled back at the end of each example.  At least this
# is the case with Oracle.  These redefinitions are a workaround.

[Category, ProductFamily, ProductAttribute, Product, ProductAttribute].each do |c|
  c.define_singleton_method(:make!) do |*args|
    o = make(*args)
    o.save
    o
  end
end


