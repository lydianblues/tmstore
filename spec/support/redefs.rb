# When we use make! as provided by machinist, the the objects so created in
# the database aren't rolled back at the end of each example.  At least this
# is the case with Oracle.  These redefinitions are a workaround.

class Category
  def self.make!(*args)
    c = make(*args)
    c.save
    c
  end
end

class ProductFamily
  def self.make!(*args)
    f = make(*args)
    f.save
    f
  end
end

class ProductAttribute
  def self.make!(*args)
    a = make(*args)
    a.save
    a
  end
end

class Product
  def self.make!(*args)
    p = make(*args)
    p.save
    p
  end
end

class ProductAttribute
  def self.make!(*args)
    a = make(*args)
    a.save
    a
  end
end

