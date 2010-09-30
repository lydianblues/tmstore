# This module uses the OCI8 library and therefore only works with Oracle.
# Note that it does not refer to any ActiveRecord model classes.
module OracleInterface
  
  module AttributeMethods
    
    # Write the integer or string value for a (product, attribute) pair.  If 
    # this pair already exists in the attribute_values table, then it is updated.
    # This function allows the pair to have both a string value and an integer
    # value.  It is up to higher level code to choose the correct type.
    def write_attr_val(attr_id, str_val, int_val)
      setup unless @conn
      stmt = <<-STMT
        BEGIN
          store2.write_attr_val(:prod_id, :attr_id, :str_val, :int_val); 
        END;
      STMT
      # Invoke a PL/SQL stored procedure.
      cursor = @conn.parse(stmt)
      cursor.bind_param(':prod_id', self.id, Fixnum)
      cursor.bind_param(':attr_id', attr_id, Fixnum)
      cursor.bind_param(':str_val', str_val, String)
      cursor.bind_param(':int_val', int_val, Fixnum)
      cursor.exec
    rescue OCIException => e
      raise "OracleInterface::AttributeMethods#write_attr_val: #{e}"
    ensure
      cursor.close if cursor
    end
  
    # Read the value of an attribute for a given product.  The result is returned
    # as a pair, [string_val, integer_val].  Nil is returned if the lookup fails.
    def read_attr_val(attr_id)
      setup unless @conn
      query = <<-QUERY
        SELECT string_val, integer_val FROM attribute_values WHERE
        product_id = :prod_id AND product_attribute_id = :attr_id
      QUERY
      cursor = @conn.parse(query)
      cursor.bind_param(':prod_id', self.id, Fixnum)
      cursor.bind_param(':attr_id', attr_id, Fixnum)
      cursor.exec
      ret = cursor.fetch
    rescue OCIException => e
      raise "OracleInterface::AttributeMethods#read_attr_val: #{e}"
    ensure
      cursor.close if cursor
    end
  
    # Delete a (product, attribute) pair.  No error is returned if it doesn't exist.
    # Nil is returned if there is a failure, otherwise true is returned.
    def delete_attr_val(attr_id)
      setup unless @conn
      stmt = <<-STMT
        DELETE FROM attribute_values WHERE
        product_id = :prod_id AND product_attribute_id = :attr_id
      STMT
      cursor = @conn.parse(stmt)
      cursor.bind_param(':prod_id', self.id, Fixnum)
      cursor.bind_param(':attr_id', attr_id, Fixnum)
      cursor.exec
    rescue OCIException => e
      raise "OracleInterface::AttributeMethods#delete_attr_val: #{e}"
    ensure          
      cursor.close if cursor
    end
    
    private
    def setup
      @conn = ActiveRecord::Base.connection.raw_connection
    end
    
  end # end of AttributeMethods module
  
  module CategoryMethods
    
    def self.included(base)
      base.extend CategoryClassMethods
    end

    def foo(omitted_child_id)
      setup unless @conn
      query = <<-QUERY
        select cf.product_family_id, 
        (select name from product_families 
          where id = cf.product_family_id)
        from category_families cf
        join categories cc on cc.id = cf.category_id
        join categories cp on cc.parent_id = cp.id
        where cc.id != :omitted_child_id
        and cp.id = :parent_id
      QUERY
      cursor = @conn.parse(query)
      cursor.bind_param(':omitted_child_id', omitted_child_id)
      cursor.bind_param(':parent_id', self.id)
      cursor.exec
       while r = cursor.fetch
        puts "#{r[0]} #{r[1]}"
      end
    rescue OCIException => e
      raise "OracleInterface#foo: #{e}"
    ensure
      cursor.close if cursor
    end
    
    def old_full_path
      path = ""
      ancestors = get_ancestors # calls setup
      ancestors.shift
      ancestors.each do |a|
        path += "/" + a[1] unless a[1].blank?
      end
      path = "/" if path.blank?
      path
    end

    def full_path
      setup unless @conn
      query = <<-QUERY
        select SYS_CONNECT_BY_PATH(name, '/')
        from categories
        where id = #{Category.root_id}
        start with id = :catid
        connect by prior parent_id = id
      QUERY
      cursor = @conn.parse(query)
      cursor.bind_param(':catid', self.id)
      cursor.exec
      r = cursor.fetch
    rescue OCIException => e
      raise "OracleInterface#fullpath: #{e}"
    else
      path = r[0]
      # Path is returned from the above query in reverse order with 
      # "/root" as the last component.  
      "/" + path.split('/').delete_if {|c| c.blank? || c == "root"}.reverse.join('/')
    ensure
      cursor.close if cursor
    end

    def get_depth
      get_ancestors.size - 1 # calls setup
    end

    # Get the navigation menu for display on sidebar.
    def get_menu
      setup unless @conn
      get_children_maybe_recurse(self.id)
    end

    def get_children
      setup unless @conn
      get_children_maybe_recurse(self.id, false)
    end

    def get_child_id_from_name(name)
      s = get_children.select {|e| e[:name] == name} # calls setup
      if s.empty?
        nil
      else
        (s.shift)[:id]
      end
    end
    
    # Get the 'breadcrumb' trail.
    def get_trail(root_label)
      setup unless @conn
      result = get_ancestors
      # Display 'All Products', or "All Categories", etc. instead
      # of 'root' in the breadcrumb trail.
      result[0][1] = root_label
      result
    end
    
    def leaf?
      ret = nil
      setup unless @conn
      query = <<-QUERY
        SELECT count(*) FROM categories parent
        LEFT OUTER JOIN categories child ON parent.id = child.parent_id
        WHERE child.id IS NULL AND parent.id = :id
      QUERY
      cursor = @conn.parse(query)
      cursor.bind_param(':id', self.id)
      cursor.exec
      r = cursor.fetch
      ret = Integer(r[0]) != 0
    rescue OCIException => e
      raise "OracleInterface#isleaf?: #{e}"
    ensure
      cursor.close if cursor
      ret
    end
    
    def remove_products_in_family(pfid)
      setup unless @conn
      cursor = @conn.parse(
        'BEGIN store2.remove_products_in_family(:catid, :pfid); END;')
      cursor.bind_param(":catid", self.id, Fixnum)
      cursor.bind_param(":pfid", pfid, Fixnum)
      cursor.exec
    rescue OCIException => e
      raise "OracleInterface::CategoryMethods#remove_products_in_family: #{e}"
    ensure
      cursor.close if cursor
    end
  
    def merge_families
      setup unless @conn
      cursor = @conn.parse('BEGIN store2.merge_families(:catid); END;')
      cursor.bind_param(":catid", self.id, Fixnum)
      cursor.exec
    rescue OCIException => e
      raise "OracleInterface::CategoryMethods#merge_families: #{e}"
    ensure
      cursor.close if cursor
    end
    
    def merge_products
      setup unless @conn
      cursor = @conn.parse('BEGIN store2.merge_products(:catid); END;')
      cursor.bind_param(":catid", self.id, Fixnum)
      cursor.exec
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#merge_products: #{e}"
    ensure
      cursor.close if cursor
    end
     
    def merge_attributes
      setup unless @conn
      cursor = @conn.parse('BEGIN store2.merge_attributes(:catid); END;')
      cursor.bind_param(":catid", self.id, Fixnum)
      cursor.exec
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#merge_attributes: #{e}"
    ensure
      cursor.close if cursor
    end
  
    def propagate_families_up
      setup unless @conn
      cursor = @conn.parse('BEGIN store2.propagate_families_up(:catid); END;')
      cursor.bind_param(":catid", self.id, Fixnum)
      cursor.exec
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#propagate_families_up: #{e}"
    ensure
      cursor.close if cursor
    end
    
    def propagate_products_up
      setup unless @conn
      cursor = @conn.parse('BEGIN store2.propagate_products_up(:catid); END;')
      cursor.bind_param(":catid", self.id, Fixnum)
      cursor.exec
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#propagate_products_up: #{e}"
    ensure
      cursor.close if cursor
    end
    
    def generate_attributes_up
      setup unless @conn
      cursor = @conn.parse('BEGIN store2.generate_attributes_up(:catid); END;')
      cursor.bind_param(":catid", self.id, Fixnum)
      cursor.exec
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#generate_attributes_up: #{e}"
    ensure
      cursor.close if cursor
    end
    
    def copy_associations(from)
      setup unless @conn
      cursor = @conn.parse(
        'BEGIN store2.copy_associations(:from_catid, :to_catid); END;')
      cursor.bind_param(":from_catid", from, Fixnum)
      cursor.bind_param(":to_catid", self.id, Fixnum)
      cursor.exec
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#copy_associations: #{e}"
    ensure
      cursor.close if cursor
    end
    
    private
    
    def setup
      @conn = ActiveRecord::Base.connection.raw_connection
      @root_id = Category.root_id
      @root_name = Category.root_name
      @cat_struct = Struct.new(:name, :id, :children)
    end
     
    # For the given parent, find all the immediate children.  If recurse is true,
    # go down one more level to find the children of those children.
    def get_children_maybe_recurse(parent_id, recurse = true)
      result = []
      query = <<-QUERY
        SELECT name, id FROM categories
        WHERE parent_id = :parent_id ORDER BY name
      QUERY
      cursor = @conn.parse(query)
      cursor.bind_param(":parent_id", parent_id, Fixnum)
      cursor.exec
      while cat = cursor.fetch
        s =  @cat_struct.new(cat[0], cat[1])
        c = get_children_maybe_recurse(cat[1], false) if recurse
        s[:children] = c if c && c.length > 0
        result << s
      end
      result
    rescue OCIException => e
      raise "OracleInterface::CategoryMethods#get_children_maybe_recurse: {e}" 
    ensure          
      cursor.close if cursor
    end
      
    # Return an array of 2 element arrays describing the path from the root to
    # this category. (We can only be included by the category model.)
    def get_ancestors()
      setup unless @conn
      result = [[@root_id, Category.root_name]]
      query = <<-QUERY
        SELECT c4.name, c4.id, c3.name, c3.id, c2.name, c2.id, c1.name, c1.id
        FROM categories c4
        LEFT OUTER JOIN categories c3 ON (c4.parent_id = c3.id)
        LEFT OUTER JOIN categories c2 ON (c3.parent_id = c2.id)
        LEFT OUTER JOIN categories c1 ON (c2.parent_id = c1.id) 
        WHERE c4.id = :id
      QUERY
      cursor = @conn.parse(query)
      cursor.bind_param(':id', self.id, Fixnum)
      cursor.exec
      r = cursor.fetch
    rescue OCIException => e
      raise "OracleInterface::CategoryMethods#get_ancestors: #{e}"
    else
      if r
        result = result.push([r[7], r[6]]) if r[6] && r[6] != @root_name
        result = result.push([r[5], r[4]]) if r[4] && r[4] != @root_name
        result = result.push([r[3], r[2]]) if r[2] && r[2] != @root_name
        result = result.push([r[1], r[0]]) if r[0] && r[0] != @root_name
      end
      result
    ensure
      cursor.close if cursor
    end

  end # end of CategoryMethods
  
  module CategoryClassMethods

    MAX_DEPTH = 4    
    Root = 'root' # name of the root node.  It must be a unique category name.
    
    def root_id
      setup unless @conn
      @root_id
    end
    
    def root_name
      Root
    end

    def max_depth
      MAX_DEPTH
    end

    # This is sort of a 'namei' for categories.  Given a full 
    # category path, find the database id of the category identified
    # by the path.
    def path_to_id(path)
      setup unless @conn
      # Invoke a PL/SQL stored procedure.
      cursor = @conn.parse("select store2.path_to_id(#{root_id}, #{path}) from dual")
      cursor.exec
      r = cursor.fetch
      r[0]
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#path_to_id: #{e}"
    ensure
      cursor.close if cursor
    end
    
    def propagate_families
      setup unless @conn
      # Invoke a PL/SQL stored procedure.
      cursor = @conn.parse('BEGIN store2.propagate_families; END;')
      cursor.exec
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#propagate_families: #{e}"
    ensure
      cursor.close if cursor
    end
      
    def propagate_products
      setup unless @conn
      # Invoke a PL/SQL stored procedure.
      cursor = @conn.parse('BEGIN store2.propagate_products; END;')
      cursor.exec
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#propagate_products: #{e}"
    ensure
      cursor.close if cursor
    end
    
    def generate_attributes
      setup unless @conn
      # Invoke a PL/SQL stored procedure.
      cursor = @conn.parse('BEGIN store2.generate_attributes; END;')
      cursor.exec
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#generate_attributes: #{e}"
    ensure
      cursor.close if cursor
    end
        
    # Obsolescent. Used only to compare performance with the
    # new implementation (generate_attributes).
    def generate_category_attributes
      setup unless @conn
      cursor = @conn.parse('BEGIN store.generate_category_attributes; END;')
      cursor.exec
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#generate_category_attributes: #{e}"     
    ensure
      cursor.close if cursor
    end
    
    # Given a category, move all of its children to a new parent. The
    # category itself will become a leaf category.
    def reparent_children(old_parent_id, new_parent_id)
      setup unless @conn
      n = 0
      setup unless @conn
      query = "UPDATE categories SET parent_id = :new_parent_id where " +
        "parent_id = :old_parent_id"
      cursor = @conn.parse(query)
      cursor.bind_param(':new_parent_id', new_parent_id)
      cursor.bind_param(':old_parent_id', old_parent_id)
      n = cursor.exec
    rescue OCIException => e
      raise "OracleInterface#reparent_children: {e}"
    ensure
      cursor.close if cursor
      n
    end
    
    private
    
    def setup
      @conn = ActiveRecord::Base.connection.raw_connection
      cursor = @conn.parse("SELECT id from categories WHERE name = '#{Root}'")
      cursor.exec
      r = cursor.fetch
      @root_id = r[0] if r # else it is nil
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#setup:could not fetch root category: #{e}"
    ensure
      cursor.close if cursor
    end
    
  end # CategoryClassMethods
 
end



