--
-- The category_attributes table is a cache.  It is constructed from the
-- product_families table and the family_attributes table. Each category has a
-- set of product families.
--
-- Categories internal to the tree have their product families completely
-- determined by their descendants. I.e. once the product families of a
-- category's immediate children are known, then the product families of the
-- category are the union of the product families of the children.
--
-- Each product family is associated with a set of product attributes.
-- The set of product attributes for a category is defined to be the intersection of
-- all these sets of product attributes.
--
-- Note how we avoid nested loops by doing BULK COLLECT.
--
CREATE OR REPLACE PACKAGE store
    AUTHID CURRENT_USER
IS
	PROCEDURE complete_category_families(p_catid IN categories.id % TYPE);
	PROCEDURE complete_category_families;
	PROCEDURE generate_category_products;
	PROCEDURE generate_category_attributes;
	PROCEDURE write_attr_val(p_prod_id IN attribute_values.product_id%TYPE, 
		p_attr_id IN attribute_values.product_attribute_id%TYPE,
		p_str_val IN attribute_values.string_val%TYPE,
		p_int_val IN attribute_values.integer_val%TYPE);

	-- Arbitrary, the Rails code has no maximum.  Note that
	-- the code below constructs a query where the constant '20'
	-- is hard coded.  Changing the constant here won't work.
	max_families_per_leaf_category CONSTANT number := 20;

	-- Arbitrary.  The Rails code may enforce a maximum branching
	-- factor as well.
	max_subcategories_per_category CONSTANT number := 30;

	-- Arbitrary, the Rails code has no maximum. However the Rails code has
	-- a maximum value (the number of columns in the products table available
	-- for to store attribute values.)  Oracle has a limit on the number of
	-- columns: ORA-01792 maximum number of columns in a table or view is 1000.
	-- some columns in the products table are used for other purposes, so we
	-- reduce the value, just to be safe.
	max_attrs_per_product_family CONSTANT number := 800;
END;
/

CREATE OR REPLACE PACKAGE BODY store
IS
 
	PROCEDURE generate_leaf_attributes(p_catid IN categories.id %TYPE)
    IS

		CURSOR pf_cursor(p_catid IN category_families.category_id % TYPE) IS
		SELECT product_family_id FROM category_families
		WHERE p_catid = category_id;

	   -- max_families_per_leaf_category CONSTANT number = 20
	   TYPE pf_varray IS VARRAY(20) OF product_families.id % TYPE;
	   l_pf_ids pf_varray;

	   -- max_attrs_per_product_family CONSTANT number := 800
	   TYPE attribute_varray IS VARRAY(800) OF product_attributes.id % TYPE;
	   l_attr_ids attribute_varray;

	   l_count PLS_INTEGER;
	   l_query VARCHAR2(1600);
	   l_index PLS_INTEGER;

   BEGIN
        OPEN pf_cursor(p_catid);
        FETCH pf_cursor BULK COLLECT INTO l_pf_ids;
        CLOSE pf_cursor;

        l_count := l_pf_ids.COUNT;
        IF l_count > 0 THEN
           -- Construct the query string.  It depends only on l_count. It would
            -- be better to cache these query strings somewhere else, rather than
            -- construct one of the appropriate length each time through the
            -- the outer loop.
            l_query := 'SELECT product_attribute_id from family_attributes '
              || 'where product_family_id = :product_family_id_1';
            FOR i IN 2 .. l_count
            LOOP
                l_query := l_query || ' INTERSECT ' ||
                  'SELECT product_attribute_id from family_attributes '
                  || 'where product_family_id = :product_family_id_' || i;
            END LOOP;

            -- There must be a better way...
            CASE l_count
            WHEN 1 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1);
            WHEN 2 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2);
            WHEN 3 THEN
                 EXECUTE IMMEDIATE l_query
                   BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                   l_pf_ids(3);
            WHEN 4 THEN
                 EXECUTE IMMEDIATE l_query
                   BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                   l_pf_ids(3), l_pf_ids(4);
            WHEN 5 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5);
            WHEN 6 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5), l_pf_ids(6);
            WHEN 7 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5), l_pf_ids(6),
                  l_pf_ids(7);
            WHEN 8 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5), l_pf_ids(6),
                  l_pf_ids(7), l_pf_ids(8);
            WHEN 9 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5), l_pf_ids(6),
                  l_pf_ids(7), l_pf_ids(8), l_pf_ids(9);
            WHEN 10 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5), l_pf_ids(6),
                  l_pf_ids(7), l_pf_ids(8), l_pf_ids(9), l_pf_ids(10);
            WHEN 11 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5), l_pf_ids(6),
                  l_pf_ids(7), l_pf_ids(8), l_pf_ids(9), l_pf_ids(10),
                  l_pf_ids(11);
            WHEN 12 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5), l_pf_ids(6),
                  l_pf_ids(7), l_pf_ids(8), l_pf_ids(9), l_pf_ids(10),
                  l_pf_ids(11), l_pf_ids(12);
            WHEN 13 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5), l_pf_ids(6),
                  l_pf_ids(7), l_pf_ids(8), l_pf_ids(9), l_pf_ids(10),
                  l_pf_ids(11), l_pf_ids(12), l_pf_ids(13);
            WHEN 14 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5), l_pf_ids(6),
                  l_pf_ids(7), l_pf_ids(8), l_pf_ids(9), l_pf_ids(10),
                  l_pf_ids(11), l_pf_ids(12), l_pf_ids(13), l_pf_ids(14);
            WHEN 15 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5), l_pf_ids(6),
                  l_pf_ids(7), l_pf_ids(8), l_pf_ids(9), l_pf_ids(10),
                  l_pf_ids(11), l_pf_ids(12), l_pf_ids(13), l_pf_ids(14),
                  l_pf_ids(15);
            WHEN 16 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5), l_pf_ids(6),
                  l_pf_ids(7), l_pf_ids(8), l_pf_ids(9), l_pf_ids(10),
                  l_pf_ids(11), l_pf_ids(12), l_pf_ids(13), l_pf_ids(14),
                  l_pf_ids(15), l_pf_ids(16);
            WHEN 17 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5), l_pf_ids(6),
                  l_pf_ids(7), l_pf_ids(8), l_pf_ids(9), l_pf_ids(10),
                  l_pf_ids(11), l_pf_ids(12), l_pf_ids(13), l_pf_ids(14),
                  l_pf_ids(15), l_pf_ids(16), l_pf_ids(17);
            WHEN 18 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5), l_pf_ids(6),
                  l_pf_ids(7), l_pf_ids(8), l_pf_ids(9), l_pf_ids(10),
                  l_pf_ids(11), l_pf_ids(12), l_pf_ids(13), l_pf_ids(14),
                  l_pf_ids(15), l_pf_ids(16), l_pf_ids(17), l_pf_ids(18);
            WHEN 19 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5), l_pf_ids(6),
                  l_pf_ids(7), l_pf_ids(8), l_pf_ids(9), l_pf_ids(10),
                  l_pf_ids(11), l_pf_ids(12), l_pf_ids(13), l_pf_ids(14),
                  l_pf_ids(15), l_pf_ids(16), l_pf_ids(17), l_pf_ids(18),
                  l_pf_ids(19);
            WHEN 20 THEN
                EXECUTE IMMEDIATE l_query
                  BULK COLLECT INTO l_attr_ids USING l_pf_ids(1), l_pf_ids(2),
                  l_pf_ids(3), l_pf_ids(4), l_pf_ids(5), l_pf_ids(6),
                  l_pf_ids(7), l_pf_ids(8), l_pf_ids(9), l_pf_ids(10),
                  l_pf_ids(11), l_pf_ids(12), l_pf_ids(13), l_pf_ids(14),
                  l_pf_ids(15), l_pf_ids(16), l_pf_ids(17), l_pf_ids(18),
                  l_pf_ids(19), l_pf_ids(20);
            END CASE;

            -- populate the categories_attributes table.
            l_index := l_attr_ids.FIRST;
            WHILE (l_index IS NOT NULL)
            LOOP
                EXECUTE IMMEDIATE
                  'INSERT INTO category_attributes ' ||
                  'VALUES(category_attributes_seq.nextval, :catid, :attrid)'
                   USING p_catid, l_attr_ids(l_index);
                l_index := l_attr_ids.NEXT(l_index);
            END LOOP;        
		END IF;
    END generate_leaf_attributes;

    --
    -- Here we do something different than at the leaves. Namely we assume that
    -- the category attributes for the children have already been populated.
    -- Therefore we query the category attributes table for each of the children
    -- and take the intersection.  The reason that we can't go through the
    -- category_families table, as in the leaf case, is that product families
    -- accumulate as we go up the tree -- the product families of a node are the
    -- union of all the product families of its children.  We don't want to
    -- intersect the attributes of possibly thousands of product families as we
    -- get near to the root of the tree.  Instead we take advantage of the fact
    -- that we can simply intersect the attributes of the children directly (using
    -- the category attributes table.)  The number of terms in this intersection
    -- is never more than the 'max_subcategories_per_category' constant.
    --
    PROCEDURE generate_non_leaf_attributes(p_catid IN categories.id %TYPE)
    IS
    	CURSOR children_cursor(p_catid IN categories.id %TYPE) IS
        SELECT id FROM categories WHERE p_catid = parent_id;

        -- max_subcategories_per_category = 30 --
        TYPE cat_varray IS VARRAY(30) OF categories.id % TYPE;
    	l_cat_ids cat_varray;

        TYPE attribute_varray IS VARRAY(1000) OF product_attributes.id % TYPE;
    	l_attr_ids attribute_varray;

        l_query VARCHAR2(5000);
        l_count PLS_INTEGER;
        l_index PLS_INTEGER;

    BEGIN
    	OPEN children_cursor(p_catid);
        FETCH children_cursor BULK COLLECT INTO l_cat_ids;
        CLOSE children_cursor;

        l_count := l_cat_ids.COUNT;

        l_query := 'SELECT product_attribute_id from category_attributes '
            || 'where category_id = :category_id_1';

	    FOR i IN 2 .. l_count
	    LOOP
	        l_query := l_query || ' INTERSECT ' ||
	          'SELECT product_attribute_id from category_attributes '
	          || 'where category_id = :category_id_' || i;
	    END LOOP;

	    -- There must be a better way...
	    CASE l_count
	    WHEN 1 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1);
	    WHEN 2 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2);
	    WHEN 3 THEN
	    	EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	         	l_cat_ids(3);
	    WHEN 4 THEN
	         EXECUTE IMMEDIATE l_query
	         BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	           l_cat_ids(3), l_cat_ids(4);
	    WHEN 5 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5);
	    WHEN 6 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6);
	    WHEN 7 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7);
	    WHEN 8 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8);
	    WHEN 9 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9);
	    WHEN 10 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10);
	    WHEN 11 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11);
	    WHEN 12 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12);
	    WHEN 13 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13);
	    WHEN 14 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14);
	    WHEN 15 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15);
	    WHEN 16 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15), l_cat_ids(16);
		WHEN 17 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15), l_cat_ids(16), l_cat_ids(17);
	    WHEN 18 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15), l_cat_ids(16), l_cat_ids(17), l_cat_ids(18);
		WHEN 19 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15), l_cat_ids(16), l_cat_ids(17), l_cat_ids(18),
	          l_cat_ids(19);
	    WHEN 20 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15), l_cat_ids(16), l_cat_ids(17), l_cat_ids(18),
	          l_cat_ids(19), l_cat_ids(20);
	    WHEN 21 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15), l_cat_ids(16), l_cat_ids(17), l_cat_ids(18),
	          l_cat_ids(19), l_cat_ids(20), l_cat_ids(21);
	    WHEN 22 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15), l_cat_ids(16), l_cat_ids(17), l_cat_ids(18),
	          l_cat_ids(19), l_cat_ids(20), l_cat_ids(21), l_cat_ids(22);
	    WHEN 23 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15), l_cat_ids(16), l_cat_ids(17), l_cat_ids(18),
	          l_cat_ids(19), l_cat_ids(20), l_cat_ids(21), l_cat_ids(22),
	          l_cat_ids(23);
	    WHEN 24 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15), l_cat_ids(16), l_cat_ids(17), l_cat_ids(18),
	          l_cat_ids(19), l_cat_ids(20), l_cat_ids(21), l_cat_ids(22),
	          l_cat_ids(23), l_cat_ids(24);
	    WHEN 25 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15), l_cat_ids(16), l_cat_ids(17), l_cat_ids(18),
	          l_cat_ids(19), l_cat_ids(20), l_cat_ids(21), l_cat_ids(22),
	          l_cat_ids(23), l_cat_ids(24), l_cat_ids(25);
	    WHEN 26 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15), l_cat_ids(16), l_cat_ids(17), l_cat_ids(18),
	          l_cat_ids(19), l_cat_ids(20), l_cat_ids(21), l_cat_ids(22),
	          l_cat_ids(23), l_cat_ids(24), l_cat_ids(25), l_cat_ids(26);
	    WHEN 27 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15), l_cat_ids(16), l_cat_ids(17), l_cat_ids(18),
	          l_cat_ids(19), l_cat_ids(20), l_cat_ids(21), l_cat_ids(22),
	          l_cat_ids(23), l_cat_ids(24), l_cat_ids(25), l_cat_ids(26),
	          l_cat_ids(27);
	    WHEN 28 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15), l_cat_ids(16), l_cat_ids(17), l_cat_ids(18),
	          l_cat_ids(19), l_cat_ids(20), l_cat_ids(21), l_cat_ids(22),
	          l_cat_ids(23), l_cat_ids(24), l_cat_ids(25), l_cat_ids(26),
	          l_cat_ids(27), l_cat_ids(28);
	    WHEN 29 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15), l_cat_ids(16), l_cat_ids(17), l_cat_ids(18),
	          l_cat_ids(19), l_cat_ids(20), l_cat_ids(21), l_cat_ids(22),
	          l_cat_ids(23), l_cat_ids(24), l_cat_ids(25), l_cat_ids(26),
	          l_cat_ids(27), l_cat_ids(28), l_cat_ids(29);
	    WHEN 30 THEN
	        EXECUTE IMMEDIATE l_query
	        BULK COLLECT INTO l_attr_ids USING l_cat_ids(1), l_cat_ids(2),
	          l_cat_ids(3), l_cat_ids(4), l_cat_ids(5), l_cat_ids(6),
	          l_cat_ids(7), l_cat_ids(8), l_cat_ids(9), l_cat_ids(10),
	          l_cat_ids(11), l_cat_ids(12), l_cat_ids(13), l_cat_ids(14),
	          l_cat_ids(15), l_cat_ids(16), l_cat_ids(17), l_cat_ids(18),
	          l_cat_ids(19), l_cat_ids(20), l_cat_ids(21), l_cat_ids(22),
	          l_cat_ids(27), l_cat_ids(28), l_cat_ids(29), l_cat_ids(30);
	    END CASE;

	    l_index := l_attr_ids.FIRST;
	    WHILE (l_index IS NOT NULL)
	    LOOP
	        EXECUTE IMMEDIATE
	          'INSERT INTO category_attributes ' ||
	          'VALUES(category_attributes_seq.nextval, :catid, :attrid)'
	           USING p_catid, l_attr_ids(l_index);
	        l_index := l_attr_ids.NEXT(l_index);
	    END LOOP;

    END generate_non_leaf_attributes;

    PROCEDURE generate_category_attributes(p_catid IN categories.id %TYPE)
    IS
        CURSOR children_cursor(p_catid IN categories.id %TYPE) IS
        SELECT id FROM categories WHERE p_catid = parent_id;
        l_catid categories.id%TYPE;
        l_stmt VARCHAR2(500);
        leaf BOOLEAN := TRUE;
   BEGIN
   	    OPEN children_cursor(p_catid);
        LOOP
            FETCH children_cursor INTO l_catid;
            EXIT WHEN children_cursor%NOTFOUND;
            	generate_category_attributes(l_catid);
        END LOOP;
        IF children_cursor%ROWCOUNT > 0 THEN
        	leaf := FALSE;
        END IF;
        CLOSE children_cursor;
        IF leaf THEN
			DBMS_OUTPUT.PUT_LINE('Calling generate_leaf_attributes for ' || p_catid);
        	generate_leaf_attributes(p_catid);
        ELSE
			DBMS_OUTPUT.PUT_LINE('Calling generate_non_leaf_attributes for ' || p_catid);
        	generate_non_leaf_attributes(p_catid);
        END IF;
    END generate_category_attributes;

    PROCEDURE generate_category_attributes
    IS
        l_root_id categories.id%TYPE;
    BEGIN
        EXECUTE IMMEDIATE 'DELETE FROM category_attributes';
        SELECT id INTO l_root_id FROM categories WHERE name = 'root';
        generate_category_attributes(l_root_id);
    END generate_category_attributes;


	PROCEDURE complete_category_families
	IS
		l_root_id categories.id%TYPE;
	BEGIN
		SELECT id INTO l_root_id FROM categories WHERE name = 'root';
	    complete_category_families(l_root_id);
	END complete_category_families;

	--
	-- Assume that the product families have been set up for the leaf
	-- categories.  Internal categories may or may not have a valid set of
	-- product families.  Set up the product families for internal categories
	-- by propagating up from the leaves.
	--
	PROCEDURE complete_category_families(p_catid IN categories.id %TYPE)
	IS
		CURSOR children_cursor(p_catid IN categories.id %TYPE) IS
			SELECT id FROM categories WHERE p_catid = parent_id;
		l_catid categories.id%TYPE;
		l_stmt VARCHAR2(500);
		leaf BOOLEAN := TRUE;
	BEGIN
		OPEN children_cursor(p_catid);
		LOOP
		    FETCH children_cursor INTO l_catid;
		    EXIT WHEN children_cursor%NOTFOUND;
		    complete_category_families(l_catid);
		END LOOP;
        IF children_cursor%ROWCOUNT > 0 THEN
	        leaf := FALSE;
        END IF;
        CLOSE children_cursor;

        IF NOT leaf THEN
			l_stmt := 'DELETE FROM category_families where category_id = :catid';
			EXECUTE IMMEDIATE l_stmt USING p_catid;
			l_stmt :=
		        'INSERT INTO category_families (id, category_id, product_family_id) ' ||
		        'SELECT category_families_seq.nextval, cid, fid FROM ' ||
		        '(SELECT DISTINCT :p_catid cid, product_family_id fid ' ||
		        'FROM category_families cf ' ||
		        'WHERE cf.category_id IN ( ' ||
		                'SELECT id FROM categories cats ' ||
		                'WHERE cats.parent_id = :p_catid))';
			EXECUTE IMMEDIATE l_stmt USING p_catid, p_catid;
        END IF;

	END complete_category_families;

	PROCEDURE generate_category_products(p_catid IN categories.id %TYPE)
	IS
		CURSOR children_cursor(p_catid IN categories.id %TYPE) IS
			SELECT id FROM categories WHERE p_catid = parent_id;
		l_catid categories.id%TYPE;
		l_stmt VARCHAR2(500);
		leaf BOOLEAN := TRUE;
	BEGIN
		OPEN children_cursor(p_catid);
		LOOP
		    FETCH children_cursor INTO l_catid;
		    EXIT WHEN children_cursor%NOTFOUND;
		    generate_category_products(l_catid);
		END LOOP;
	    IF children_cursor%ROWCOUNT > 0 THEN
	        leaf := FALSE;
	    END IF;
	    CLOSE children_cursor;

		-- We could convert this to static SQL, but we want to use bind variables
		-- to improve performance.
		IF leaf THEN
			l_stmt :=
				'INSERT INTO category_products (id, category_id, product_id) ' ||
				'SELECT category_products_seq.nextval, :catid, pid FROM ' ||
				'(SELECT pl.product_id pid FROM product_leaves pl WHERE ' ||
					'(pl.category_id = :catid))';
		ELSE
			l_stmt := 
		    'INSERT INTO category_products (id, category_id, product_id) ' ||
				'SELECT category_products_seq.nextval, :catid, pid FROM ' ||
				'(SELECT DISTINCT product_id pid FROM category_products cp ' ||
					'WHERE cp.category_id IN ' ||
					'(SELECT id FROM categories ' ||
					'WHERE categories.parent_id = :catid))';
		END IF;
		EXECUTE IMMEDIATE l_stmt USING p_catid, p_catid;

	END generate_category_products;
	
	PROCEDURE generate_category_products
	IS
		l_root_id categories.id%TYPE;
	BEGIN
		SELECT id INTO l_root_id FROM categories WHERE name = 'root';
	    generate_category_products(l_root_id);
	END generate_category_products;
	
	-- The attribute_values table uses a composite primary key.  The ActiveRecord
	-- migration creates an index for this key.
	PROCEDURE write_attr_val(
		p_prod_id IN attribute_values.product_id%TYPE, 
		p_attr_id IN attribute_values.product_attribute_id%TYPE,
		p_str_val IN attribute_values.string_val%TYPE,
		p_int_val IN attribute_values.integer_val%TYPE)
	IS
	BEGIN
		BEGIN
			-- TODO would a MERGE DML statement be faster?  What about checking via
			-- a SELECT to decide whether to to an INSERT or UPDATE?
			INSERT INTO attribute_values VALUES(p_attr_id, p_prod_id, p_int_val, p_str_val, '');
		EXCEPTION
			WHEN DUP_VAL_ON_INDEX THEN
				UPDATE attribute_values SET
					integer_val = p_int_val,
					string_val = p_str_val
				WHERE
					product_attribute_id = p_attr_id
					AND product_id = p_prod_id;
		END;
	END write_attr_val;

BEGIN
    NULL; -- session initialization
END store;
/
SHOW ERRORS

exit



