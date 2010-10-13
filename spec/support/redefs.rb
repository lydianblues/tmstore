[Category, ProductFamily, ProductAttribute, Product, ProductAttribute].each do |c|

  # When we use make! as provided by machinist, the the objects so created in
  # the database aren't rolled back at the end of each example.  At least this
  # is the case with Oracle.  These redefinitions are a workaround.
  c.define_singleton_method(:make!) do |*args|
    o = make(*args)
    o.save
    o
  end

  # Reload an Active Record model from disk, if it is possible.
  c.class_eval do
    def refresh
      if self.new_record?
        self
      else
        self.class.find(self.id)
      end
    end
  end

end
