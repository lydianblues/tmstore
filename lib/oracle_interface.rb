# This module uses the OCI8 library and therefore only works with Oracle.
# Note that it does not refer to any ActiveRecord model classes.
module OracleInterface
  
  module AttributeMethods
    
    # Write the integer or string value for a (product, attribute) pair.  If 
    # this pair already exists in the attribute_values table, then it is updated.
    # This function allows the pair to have both a string value and an integer
    # value.  It is up to higher level code to choose the correct type.
    def write_attr_val(attr_id, str_val, int_val)
      ret = true
      setup unless @conn
      begin
        # Invoke a PL/SQL stored procedure.
        cursor = @conn.parse("BEGIN store2.write_attr_val( " +
          ":prod_id, :attr_id, :str_val, :int_val); END;")
        cursor.bind_param(':prod_id', self.id, Fixnum)
        cursor.bind_param(':attr_id', attr_id, Fixnum)
        cursor.bind_param(':str_val', str_val, String)
        cursor.bind_param(':int_val', int_val, Fixnum)
        cursor.exec
      rescue OCIException => e
        raise "OracleInterface::CategoryMethods#" +
          "write_attr_val: #{e}"
      end
      ret
    end
  
    # Read the value of an attribute for a given product.  The result is returned
    # as a pair, [string_val, integer_val].  Nil is returned if the lookup fails.
    def read_attr_val(attr_id)
      setup unless @conn
      ret = true
      begin
        query = "SELECT string_val, integer_val FROM attribute_values WHERE " +
          "product_id = :prod_id AND product_attribute_id = :attr_id"
        cursor = @conn.parse(query)
        cursor.bind_param(':prod_id', self.id, Fixnum)
        cursor.bind_param(':attr_id', attr_id, Fixnum)
        cursor.exec
        r = cursor.fetch
      rescue OCIException => e
        raise "OracleInterface::CategoryMethods#" +
          "read_attr_val: #{e}"
      else
        ret = r
      end
      ret
    end
  
    # Delete a (product, attribute) pair.  No error is returned if it doesn't exist.
    # Nil is returned if there is a failure, otherwise true is returned.
    def delete_attr_val(attr_id)
      setup unless @conn
      ret = true
      begin
        stmt = "DELETE FROM attribute_values WHERE " +
          "product_id = :prod_id AND product_attribute_id = :attr_id"
        cursor = @conn.parse(stmt)
        cursor.bind_param(':prod_id', self.id, Fixnum)
        cursor.bind_param(':attr_id', attr_id, Fixnum)
        cursor.exec
      rescue OCIException => e
        raise "OracleInterface::CategoryMethods#" +
          "delete_attr_val: #{e}"
      end
      ret
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
    
    def full_path
      path = ""
      ancestors = get_ancestors # calls setup
      ancestors.shift
      ancestors.each do |a|
        path += "/" + a[1] unless a[1].blank?
      end
      path = "/" if path.blank?
      path
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
      setup unless @conn
      query = "SELECT count(*) FROM categories parent " +
        "LEFT OUTER JOIN categories child ON parent.id = child.parent_id " +
        "WHERE child.id IS NULL AND parent.id = :id"
      begin
        cursor = @conn.parse(query)
        cursor.bind_param(':id', self.id)
        cursor.exec
        r = cursor.fetch
      rescue OCIException => e
        raise "OracleInterface#isleaf?: #{e}"
      end
      (Integer(r[0])  == 0) ? false : true
    end
    
    def remove_products_in_family(pfid)
      setup unless @conn
      begin
        cursor = @conn.parse(
          'BEGIN store2.remove_products_in_family(:catid, :pfid); END;')
          cursor.bind_param(":catid", self.id, Fixnum)
          cursor.bind_param(":pfid", pfid, Fixnum)
          cursor.exec
      rescue OCIException => e
        raise "OracleInterface::CategoryMethods#remove_products_in_family: #{e}"
      end
    end
  
    def merge_families
      setup unless @conn
      begin
        cursor = @conn.parse('BEGIN store2.merge_families(:catid); END;')
        cursor.bind_param(":catid", self.id, Fixnum)
        cursor.exec
      rescue OCIException => e
        raise "OracleInterface::CategoryMethods#merge_families: #{e}"
      end
    end
    
    def merge_products
     setup unless @conn
     begin
       cursor = @conn.parse('BEGIN store2.merge_products(:catid); END;')
       cursor.bind_param(":catid", self.id, Fixnum)
       cursor.exec
     rescue OCIException => e
       raise "OracleInterface::CategoryClassMethods#merge_products: #{e}"
     end
    end
     
    def merge_attributes
      setup unless @conn
      begin
        cursor = @conn.parse('BEGIN store2.merge_attributes(:catid); END;')
        cursor.bind_param(":catid", self.id, Fixnum)
        cursor.exec
      rescue OCIException => e
        raise "OracleInterface::CategoryClassMethods#merge_attributes: #{e}"
      end
    end
  
    def propagate_families_up
      setup unless @conn
      begin
        cursor = @conn.parse('BEGIN store2.propagate_families_up(:catid); END;')
        cursor.bind_param(":catid", self.id, Fixnum)
        cursor.exec
      rescue OCIException => e
        raise "OracleInterface::CategoryClassMethods#" +
          "propagate_families_up: #{e}"
       end
    end
    
    def propagate_products_up
      setup unless @conn
      begin
        cursor = @conn.parse('BEGIN store2.propagate_products_up(:catid); END;')
        cursor.bind_param(":catid", self.id, Fixnum)
        cursor.exec
      rescue OCIException => e
        raise "OracleInterface::CategoryClassMethods#" +
          "propagate_products_up: #{e}"
       end
    end
    
    def generate_attributes_up
      setup unless @conn
      begin
        cursor = @conn.parse('BEGIN store2.generate_attributes_up(:catid); END;')
        cursor.bind_param(":catid", self.id, Fixnum)
        cursor.exec
      rescue OCIException => e
        raise "OracleInterface::CategoryClassMethods#" +
          "generate_attributes_up: #{e}"
       end
    end
    
    def copy_associations(from)
      setup unless @conn
      begin
        cursor = @conn.parse(
          'BEGIN store2.copy_associations(:from_catid, :to_catid); END;')
        cursor.bind_param(":from_catid", from, Fixnum)
        cursor.bind_param(":to_catid", self.id, Fixnum)
        cursor.exec
      rescue OCIException => e
        raise "OracleInterface::CategoryClassMethods#" +
          "copy_associations: #{e}"
       end
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

      begin
        cursor = @conn.parse("SELECT name, id FROM categories " +
          "WHERE parent_id = :parent_id ORDER BY name")
        cursor.bind_param(":parent_id", parent_id, Fixnum)
        cursor.exec
        while cat = cursor.fetch
          s =  @cat_struct.new(cat[0], cat[1])
          c = get_children_maybe_recurse(cat[1], false) if recurse
          s[:children] = c if c && c.length > 0
          result << s
        end
      rescue OCIException => e
        raise "OracleInterface::CategoryMethods#" +
          "get_children_maybe_recurse: {e}"   
      ensure
        cursor.close if cursor
      end
      result
    end
      
    # Return an array of 2 element arrays describing the path from the root to
    # this category. (We can only be included by the category model.)
    def get_ancestors()
      setup unless @conn
      result = [[@root_id, Category.root_name]]
      query = "SELECT c4.name, c4.id, c3.name, c3.id, " +
        "c2.name, c2.id, c1.name, c1.id " +
        "FROM categories c4 " +
        "LEFT OUTER JOIN categories c3 ON (c4.parent_id = c3.id) " +
        "LEFT OUTER JOIN categories c2 ON (c3.parent_id = c2.id) " +
        "LEFT OUTER JOIN categories c1 ON (c2.parent_id = c1.id) " +
        "WHERE c4.id = :id"

      begin
        cursor = @conn.parse(query)
        cursor.bind_param(':id', self.id, Fixnum)
        cursor.exec
        r = cursor.fetch
      rescue OCIException => e
        raise "OracleInterface::CategoryMethods#" +
          "get_ancestors: #{e}"
      else
        if r
          result = result.push([r[7], r[6]]) if r[6] && r[6] != @root_name
          result = result.push([r[5], r[4]]) if r[4] && r[4] != @root_name
          result = result.push([r[3], r[2]]) if r[2] && r[2] != @root_name
          result = result.push([r[1], r[0]]) if r[0] && r[0] != @root_name
        end
      ensure
        cursor.close
      end
      result
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
      comps = path.split('/')
      
       # Get rid of blank strings.  These may be caused by leading or
      # extra '/' characters in the path.
      tmp_comps = []
      comps.each do |c|
        tmp_comps << c if !c.blank?
      end
      comps = tmp_comps
      
      comps.shift if comps[0] == 'root'
      return root_id if comps.empty?
      
      parent_id = root_id
      comps.each do |name|
        cursor = @conn.parse("SELECT id FROM categories " +
          "WHERE parent_id = :parent_id AND name = :name")
        cursor.bind_param(":parent_id", parent_id, Fixnum)
        cursor.bind_param(":name", name, String)
        cursor.exec
        result = cursor.fetch
        return nil if result.nil?
        parent_id = result[0]
     end
     parent_id
    end
    
    def propagate_families
      setup unless @conn
      begin
        # Invoke a PL/SQL stored procedure.
        cursor = @conn.parse('BEGIN store2.propagate_families; END;')
        cursor.exec
      rescue OCIException => e
        raise "OracleInterface::CategoryClassMethods#" +
          "propagate_families: #{e}"
       end
    end
      
    def propagate_products
      setup unless @conn
      begin
        # Invoke a PL/SQL stored procedure.
        cursor = @conn.parse('BEGIN store2.propagate_products; END;')
        cursor.exec
      rescue OCIException => e
        raise "OracleInterface::CategoryClassMethods#" +
          "propagate_products: #{e}"
       end
    end
    
    def generate_attributes
      setup unless @conn
      begin
        # Invoke a PL/SQL stored procedure.
        cursor = @conn.parse('BEGIN store2.generate_attributes; END;')
        cursor.exec
      rescue OCIException => e
        raise "OracleInterface::CategoryClassMethods#" +
          "generate_attributes: #{e}"
       end
    end
        
    # Obsolescent. Used only to compare performance with the
    # new implementation (generate_attributes).
    def generate_category_attributes
      setup unless @conn
      begin
        cursor = @conn.parse('BEGIN store.generate_category_attributes; END;')
        cursor.exec
       rescue OCIException => e
         raise "OracleInterface::CategoryClassMethods#" +
           "generate_category_attributes: #{e}"     
      end
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
      begin
        n = cursor.exec
      rescue OCIException => e
        raise "OracleInterface#reparent_children: {e}"
      end
      n
    end
    
    private
    
    def setup
      
      @conn = ActiveRecord::Base.connection.raw_connection
      begin
        cursor = @conn.parse("SELECT id from categories WHERE name = '#{Root}'")
        cursor.exec
        r = cursor.fetch
      rescue OCIException => e
        raise "OracleInterface::CategoryClassMethods#setup: " + 
          "could not fetch root category: #{e}"
      else
        @root_id = r[0] if r # else it is nil
      end
    end
    
  end # CategoryClassMethods
 
end



