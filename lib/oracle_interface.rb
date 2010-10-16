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

    def get_depth
      setup unless @conn
      query = <<-QUERY
        SELECT LEVEL from categories
        WHERE id = :catid
        START WITH name = 'root'
        CONNECT BY PRIOR id = parent_id
      QUERY
      cursor = @conn.parse(query)
      cursor.bind_param(':catid', self.id, Fixnum)
      cursor.exec
      r = cursor.fetch
      Integer(r[0]) - 1
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#get_depth: #{e}"
    ensure
      cursor.close if cursor
    end

    def full_path
      setup unless @conn
      query = <<-QUERY
        SELECT SYS_CONNECT_BY_PATH(name, '/') FROM categories
        WHERE id = :catid
        START WITH name = 'root'
        CONNECT BY PRIOR id = parent_id
      QUERY
      cursor = @conn.parse(query)
      cursor.bind_param(':catid', self.id, Fixnum)
      cursor.exec
      r = cursor.fetch
      path = String(r[0]).gsub(/^\/root/, '')
      path = "/" if path.blank?
      path
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#full_path: #{e}"
    ensure
      cursor.close if cursor
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

    # Return an array containing the category ids of this category
    # as well as all its descendents.
    def get_descendents()
      setup unless @conn
      result = []
      query = <<-QUERY
        SELECT id
        FROM categories
        START WITH id = :catid
        CONNECT BY PRIOR id = parent_id
      QUERY
      cursor = @conn.parse(query)
      cursor.bind_param(':catid', self.id, Fixnum)
      cursor.exec
      while r = cursor.fetch
        result.push(r[0])
      end
      result
    rescue OCIException => e
      raise "OracleInterface::CategoryMethods#get_descendents: #{e}"
    ensure
      cursor.close if cursor
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

    #
    # Given a category, move all of its children to a new parent. The
    # category itself will become a leaf category.  It will keep all its
    # product families, products, and attributes.  Return the number of
    # children that were reparented.
    #
    def reparent_children(new_parent_id)
      setup unless @conn
      stmt = <<-STMT
        UPDATE categories SET parent_id = :new_parent_id
          WHERE parent_id = :old_parent_id
      STMT
      @conn.exec(stmt, new_parent_id, self.id)
    rescue OCIException => e
      raise "OracleInterface#reparent_children: {e}"
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

    def get_ancestors()
      setup unless @conn
      result = []
      query =<<-QUERY
        SELECT id, name from categories
        START WITH id = :catid
        CONNECT BY PRIOR parent_id = id
      QUERY
      cursor = @conn.parse(query)
      cursor.bind_param(':catid', self.id, Fixnum)
      cursor.exec
      while r = cursor.fetch
        result.unshift(r)
      end
      result
    rescue OCIException => e
      raise "OracleInterface::CategoryMethods#get_ancestors: #{e}"
    ensure
      cursor.close if cursor
    end

  end

  module CategoryClassMethods

    Root = 'root' # name of the root node.  It must be a unique category name.

    def root_id
      setup unless @conn
      @root_id
    end

    def root_name
      Root
    end

    # This is sort of a 'namei' for categories.  Given a full
    # category path, find the database id of the category identified
    # by the path.
    def path_to_id(path)
      setup unless @conn
      query = "select store2.path_to_id(:mystart, :mypath) from dual"
      cursor = @conn.parse(query)
      cursor.bind_param(':mystart', root_id, Fixnum)
      cursor.bind_param(':mypath', path)
      cursor.exec
      r = cursor.fetch
      r[0] ? Integer(r[0]) : nil
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#path_to_id: #{e}"
    ensure
      cursor.close if cursor
    end

    def propagate_families
      setup unless @conn
      @conn.exec('BEGIN store2.propagate_families; END;')
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#propagate_families: #{e}"
    end

    def propagate_products
      setup unless @conn
      @conn.exec('BEGIN store2.propagate_products; END;')
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#propagate_products: #{e}"
    end

    def generate_attributes
      setup unless @conn
      @conn.exec('BEGIN store2.generate_attributes; END;')
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#generate_attributes: #{e}"
    end

    # Obsolescent. Used only to compare performance with the
    # new implementation (generate_attributes).
    def generate_category_attributes
      setup unless @conn
      @conn.exec('BEGIN store.generate_category_attributes; END;')
    rescue OCIException => e
      raise "OracleInterface::CategoryClassMethods#generate_category_attributes: #{e}"
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



