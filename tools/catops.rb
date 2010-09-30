
# Compute the product families for a category, omitting all those
# that would have been contributed by a specific child.

def foo(parent_id, omitted_child_id)
  query = <<-QUERY
select cf.product_family_id from category_families cf
    join categories cc on cc.id = cf.category_id
    join categories cp on cc.parent_id = cp.id
    where cc.id != :omitted_child_id
    and cp.id = :parent_id
  QUERY

end

