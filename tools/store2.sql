CREATE OR REPLACE PACKAGE store2
  AUTHID CURRENT_USER
IS	
  PROCEDURE merge_families(p_catid IN categories.id % TYPE);
  PROCEDURE propagate_families;
  PROCEDURE propagate_families_up(p_catid IN categories.id % TYPE);
	
  PROCEDURE merge_products(p_catid IN categories.id % TYPE);
  PROCEDURE propagate_products;
  PROCEDURE propagate_products_up(p_catid IN categories.id % TYPE);
  PROCEDURE remove_products_in_family(p_catid IN categories.id % TYPE,
    p_pfid IN product_families.id % TYPE);
	
  PROCEDURE generate_attributes;
  PROCEDURE generate_attributes_up(p_catid IN categories.id % TYPE);
  PROCEDURE merge_attributes(p_catid IN categories.id %TYPE);
	
  PROCEDURE copy_associations(p_from_catid IN categories.id % TYPE,
    p_to_catid IN categories.id % TYPE);
	
  PROCEDURE write_attr_val(p_prod_id IN attribute_values.product_id%TYPE, 
    p_attr_id IN attribute_values.product_attribute_id%TYPE,
    p_str_val IN attribute_values.string_val%TYPE,
    p_int_val IN attribute_values.integer_val%TYPE);

  FUNCTION path_to_id(p_start IN categories.id % TYPE, p_path IN VARCHAR2)
    RETURN categories.id % TYPE;
END;
/

CREATE OR REPLACE PACKAGE BODY store2
IS

  PROCEDURE merge_families(p_catid IN categories.id % TYPE)
  IS
    l_stmt VARCHAR2(500);
  BEGIN
    l_stmt := 'DELETE FROM category_families WHERE category_id = :catid';
      EXECUTE IMMEDIATE l_stmt USING p_catid;
			
    l_stmt := 'INSERT INTO category_families ' ||
      '(category_id, product_family_id, ref_count) ' ||
      'SELECT :catid, product_family_id, SUM(ref_count) ' ||
      'FROM category_families WHERE category_id IN ' ||
      '(SELECT id FROM categories WHERE parent_id = :catid) ' ||
      'GROUP BY product_family_id';
		
    EXECUTE IMMEDIATE l_stmt USING p_catid, p_catid;
    -- DBMS_OUTPUT.PUT_LINE('family merge inserted ' || SQL%ROWCOUNT || 
    --   ' rows for category ' || p_catid);
  END merge_families;

  PROCEDURE propagate_families(p_catid IN categories.id %TYPE)
  IS
    CURSOR children_cursor(p_catid IN categories.id %TYPE) IS
      SELECT id FROM categories WHERE p_catid = parent_id;
	l_catid categories.id%TYPE;
  BEGIN
    OPEN children_cursor(p_catid);
    LOOP
      FETCH children_cursor INTO l_catid;
      EXIT WHEN children_cursor%NOTFOUND;
      propagate_families(l_catid);
    END LOOP;
    IF children_cursor%ROWCOUNT > 0 THEN
      merge_families(p_catid);
    END IF;
    CLOSE children_cursor;
  END propagate_families;
	
  PROCEDURE propagate_families
  IS
    l_root_id categories.id%TYPE;
  BEGIN
    SELECT id INTO l_root_id FROM categories WHERE name = 'root';
    propagate_families(l_root_id);
  END propagate_families;

  PROCEDURE propagate_families_up(p_catid IN categories.id % TYPE)
  IS
    l_catid categories.parent_id%TYPE;
  BEGIN
    l_catid := p_catid;
    LOOP
      SELECT parent_id INTO l_catid FROM categories WHERE id = l_catid;
      EXIT WHEN l_catid IS NULL;
      merge_families(l_catid);
    END LOOP;
  END propagate_families_up;
	
  -- Does not require a UNIQUE index on (category_id, product_id)
  PROCEDURE merge_products(p_catid IN categories.id % TYPE)
  IS
    l_stmt VARCHAR2(500);
  BEGIN
    l_stmt := 'DELETE FROM category_products WHERE category_id = :catid';
    EXECUTE IMMEDIATE l_stmt USING p_catid;
	
    l_stmt := 'INSERT INTO category_products ' ||
      '(category_id, product_id, ref_count) ' ||
      'SELECT :catid, product_id, SUM(ref_count) ' ||
      'FROM category_products WHERE category_id IN ' ||
      '(SELECT id FROM categories WHERE parent_id = :catid) ' ||
      'GROUP BY product_id';
    EXECUTE IMMEDIATE l_stmt USING p_catid, p_catid;
    DBMS_OUTPUT.PUT_LINE('product merge inserted ' || SQL%ROWCOUNT || 
      ' rows for category ' || p_catid);
  END merge_products;
        
  -- Requires a UNIQUE index in (category_id, product_id).  This is a lot
  -- slower than the alternative implementation 'merge_products'.
  PROCEDURE merge_products_2(p_catid IN categories.id % TYPE)
  IS
    CURSOR children_cursor(p_catid IN categories.id %TYPE) IS
      SELECT id FROM categories WHERE p_catid = parent_id;
                        
    CURSOR catprod_cursor(p_catid IN category_products.category_id %TYPE) IS
      SELECT product_id, ref_count
      FROM category_products WHERE p_catid = category_id;
    l_stmt VARCHAR2(500);
  BEGIN
    l_stmt := 'DELETE FROM category_products WHERE category_id = :catid';
    EXECUTE IMMEDIATE l_stmt USING p_catid;
                
    FOR catid IN children_cursor(p_catid)
    LOOP
      FOR cp IN catprod_cursor(catid.id)
      LOOP
        BEGIN
          INSERT INTO category_products
          (category_id, product_id, ref_count)
          VALUES(p_catid, cp.product_id, cp.ref_count);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            UPDATE category_products SET
              ref_count = ref_count + cp.ref_count
            WHERE
              category_id = p_catid
            AND product_id = cp.product_id;
        END;
      END LOOP;
    END LOOP;
  END merge_products_2;
        
  PROCEDURE propagate_products(p_catid IN categories.id %TYPE)
  IS
    CURSOR children_cursor(p_catid IN categories.id %TYPE) IS
      SELECT id FROM categories WHERE p_catid = parent_id;
    l_catid categories.id%TYPE;
  BEGIN
    OPEN children_cursor(p_catid);
    LOOP
      FETCH children_cursor INTO l_catid;
      EXIT WHEN children_cursor%NOTFOUND;
      propagate_products(l_catid);
    END LOOP;
    IF children_cursor%ROWCOUNT > 0 THEN
      merge_products(p_catid);
    END IF;
    CLOSE children_cursor;
  END propagate_products;
        
  PROCEDURE propagate_products
  IS
    l_root_id categories.id%TYPE;
  BEGIN
    SELECT id INTO l_root_id FROM categories WHERE name = 'root';
    propagate_products(l_root_id);
  END propagate_products;
  
  PROCEDURE propagate_products_up(p_catid IN categories.id % TYPE)
  IS
    l_catid categories.parent_id%TYPE;
  BEGIN
    l_catid := p_catid;
    LOOP
      SELECT parent_id INTO l_catid FROM categories WHERE id = l_catid;
      EXIT WHEN l_catid IS NULL;
      merge_products(l_catid);
    END LOOP;
  END propagate_products_up;
        
  -- Remove all products from leaf category that belong to a specific
  -- product family.  This is called when the family itself is being
  -- removed from the leaf category.
  PROCEDURE remove_products_in_family(p_catid IN categories.id % TYPE,
    p_pfid IN product_families.id % TYPE)
  IS
    l_stmt VARCHAR2(2000);
  BEGIN
    l_stmt := 'DELETE FROM category_products ' ||
      'WHERE category_id = :catid AND ' ||
      'product_id IN (SELECT id FROM products ' ||
      'WHERE product_family_id = :famid)';
    EXECUTE IMMEDIATE l_stmt USING p_catid, p_pfid;
  END remove_products_in_family;
        
  PROCEDURE merge_attributes(p_catid IN categories.id %TYPE)
  IS
    l_stmt VARCHAR2(2000);
  BEGIN
    l_stmt := 'DELETE FROM category_attributes WHERE category_id = :catid';
    EXECUTE IMMEDIATE l_stmt USING p_catid;
                  
    --
    -- This is a case where a single SQL statement needs a design document of its
    -- own.  The problem is this: Given a category.  The category has a number of 
    -- associated product families via the category_families join table. Each 
    -- product family has a number of product attributes via the families_attributes
    -- join table. Find the attributes in common to all these product familes.
    -- This gives the attributes to associate with the category using the 
    -- categories_attributes join table. The logic is:
    --
    -- Step 1. Create an inline view that only includes the product families that 
    -- are associated with this particular category.  This view is created on 
    -- line 5.
    --
    -- Step 2. Create another inline view (using the first inline view as its
    -- data source) that groups the rows by product_attribute_id together with
    -- the count of the number of times that the attribute occurred.  This view
    -- is created on line 4.
    --
    -- Step 3. Create another SELECT statment that generates the rows to insert,
    -- but only choose rows that have a count equal to the total number of product
    -- families that the category has.  
    -- 
    -- Step 4. Insert the rows generated by the SELECT in Step 3.
    --
    l_stmt := 'INSERT INTO category_attributes ' ||
      '(category_id, product_attribute_id) ' ||
        'SELECT :catid, product_attribute_id FROM ' ||
          '(SELECT product_attribute_id, COUNT(*) AS count FROM ' ||
            '(SELECT fa.product_family_id, fa.product_attribute_id ' ||
                      'FROM family_attributes fa ' ||
            'INNER JOIN category_families cf ' ||
            'ON cf.product_family_id = fa.product_family_id ' ||
            'WHERE cf.category_id = :catid) ' ||
          'GROUP BY product_attribute_id) ' ||
        'WHERE count = (select count(*) FROM ' ||
              '(SELECT distinct product_family_id ' ||
           'FROM category_families WHERE category_id = :catid))';
    EXECUTE IMMEDIATE l_stmt USING p_catid, p_catid, p_catid;
    -- DBMS_OUTPUT.PUT_LINE('attribute merge inserted ' || SQL%ROWCOUNT || 
    --   ' rows for category ' || p_catid);
  END merge_attributes;
        
  PROCEDURE generate_attributes(p_catid IN categories.id %TYPE)
  IS
    CURSOR children_cursor(p_catid IN categories.id %TYPE) IS
      SELECT id FROM categories WHERE p_catid = parent_id;
    l_catid categories.id%TYPE;
  BEGIN
    OPEN children_cursor(p_catid);
    LOOP
      FETCH children_cursor INTO l_catid;
      EXIT WHEN children_cursor%NOTFOUND;
      generate_attributes(l_catid);
    END LOOP;
    CLOSE children_cursor;
    -- We still must populate the category_attributes table
    -- for a leaf category. Always call 'merge_attributes'.
    merge_attributes(p_catid);
  END generate_attributes;
        
  PROCEDURE generate_attributes
  IS
    l_root_id categories.id%TYPE;
  BEGIN
    SELECT id INTO l_root_id FROM categories WHERE name = 'root';
    generate_attributes(l_root_id);
  END generate_attributes;
        
  PROCEDURE generate_attributes_up(p_catid IN categories.id % TYPE)
  IS
    l_catid categories.parent_id%TYPE;
  BEGIN
    l_catid := p_catid;
    LOOP
      merge_attributes(l_catid);
      SELECT parent_id INTO l_catid FROM categories WHERE id = l_catid;
      EXIT WHEN l_catid IS NULL;
   END LOOP;
  END generate_attributes_up;
        
  -- Copy all the associations from one category to another.
  PROCEDURE copy_associations(p_from_catid IN categories.id % TYPE,
    p_to_catid IN categories.id % TYPE)
  IS
    l_stmt VARCHAR2(500);
  BEGIN
    l_stmt := 'INSERT INTO category_families ' ||
      '(category_id, product_family_id) ' ||
      'SELECT :to_catid, product_family_id ' ||
      'FROM category_families WHERE :from_catid = category_id';
    EXECUTE IMMEDIATE l_stmt USING p_to_catid, p_from_catid;
    l_stmt := 'INSERT INTO category_products ' ||
      '(category_id, product_id) ' ||
      'SELECT :to_catid, product_id ' ||
      'FROM category_products WHERE :from_catid = category_id';
    EXECUTE IMMEDIATE l_stmt USING p_to_catid, p_from_catid;
    l_stmt := 'INSERT INTO category_attributes ' ||
      '(category_id, product_attribute_id) ' ||
      'SELECT :to_catid, product_attribute_id ' ||
      'FROM category_attributes WHERE :from_catid = category_id';
    EXECUTE IMMEDIATE l_stmt USING p_to_catid, p_from_catid;
  END copy_associations;
        
  -- The attribute_values table uses a composite primary key.  The ActiveRecord
  -- migration creates an index for this key.
  PROCEDURE write_attr_val(
    p_prod_id IN attribute_values.product_id%TYPE, 
    p_attr_id IN attribute_values.product_attribute_id%TYPE,
    p_str_val IN attribute_values.string_val%TYPE,
    p_int_val IN attribute_values.integer_val%TYPE)
  IS
  BEGIN
    -- TODO would a MERGE DML statement be faster?  What about checking via
    -- a SELECT to decide whether to to an INSERT or UPDATE?
    INSERT INTO attribute_values VALUES(p_attr_id, p_prod_id,
      p_int_val, p_str_val, '');
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      UPDATE attribute_values SET
        integer_val = p_int_val,
        string_val = p_str_val
      WHERE
        product_attribute_id = p_attr_id
      AND product_id = p_prod_id;
  END write_attr_val;
        
  FUNCTION path_to_id(p_start IN categories.id % TYPE, p_path IN VARCHAR2)
    RETURN categories.id % TYPE
  IS
    p1 PLS_INTEGER;
    p2 PLS_INTEGER := 1;
    n PLS_INTEGER := 2;
    stmt VARCHAR2(256);

    l_comp VARCHAR2(100);
    l_path VARCHAR2(4000) := '/' || p_path || '/';
    l_parent categories.id%TYPE;
    l_child categories.id%TYPE;
  BEGIN
    -- Special case if p_path is composed only of slashes. 
    IF REGEXP_INSTR(p_path, '^\/+$') = 1 THEN
      RETURN p_start;
    END IF;

    stmt := 'SELECT id FROM categories ' ||
      'WHERE parent_id = :parent and name = :comp';
    l_parent := p_start;
    LOOP
      p1 := p2;
      p2 := INSTR(l_path, '/', 1, n);
      EXIT WHEN p2 = 0;
      n := n + 1;
      -- skip consecutive slashes
      IF p1 + 1 != p2  THEN
        l_comp := SUBSTR(l_path, p1 + 1, p2 - p1 - 1);
        EXECUTE IMMEDIATE stmt INTO l_child USING l_parent, l_comp;
        l_parent := l_child;
      END IF;
    END LOOP;
    RETURN l_child;
  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN 
      RETURN NULL;
  END path_to_id;

BEGIN
    NULL; -- session initialization
END store2;
/
SHOW ERRORS

exit
