
CREATE OR REPLACE PROCEDURE find_children(
	p_parent_id IN categories.parent_id%TYPE, padding VARCHAR2)
IS
	CURSOR category_cur IS 
		SELECT * from categories c WHERE c.parent_id = p_parent_id;
BEGIN
	
	FOR category_rec IN category_cur
	LOOP
		DBMS_OUTPUT.PUT_LINE(padding || category_rec.name || ' ' || 
			category_rec.id || ' ' || category_rec.parent_id);
		find_children(category_rec.id, '--> ' || padding);
	END LOOP;
		
END;
/

CREATE OR REPLACE PROCEDURE find_ancestors(p_category IN categories%ROWTYPE)

IS	
	l_name1 categories.name%TYPE;
	l_name2 categories.name%TYPE;
	l_name3 categories.name%TYPE;
BEGIN
	SELECT c3.name, c2.name, c1.name INTO l_name3, l_name2, l_name1
	FROM categories AS c3
	LEFT OUTER JOIN categories AS c2 ON (c3.parent_id = c2.id)
	LEFT OUTER JOIN categories AS c1 ON (c2.parent_id = c1.id)
	WHERE c3.id = p_category.parent_id;
		
	DBMS_OUTPUT.PUT_LINE(p_category.name || ' ---> ' || 
		l_name3 || ' ---> ' || l_name2 || ' ---> ' || l_name1);
END;
/

-- Display the categories in a hierarchical manner.
DECLARE
	l_root_id categories.id%TYPE;
	l_cat categories%ROWTYPE;
BEGIN
	
	-- Get the ID of the root element.
	SELECT id INTO l_root_id FROM categories WHERE name = 'root';

	DBMS_OUTPUT.PUT_LINE('The root id is: ' || l_root_id);
	
	find_children(l_root_id, '');
	
	SELECT * INTO l_cat FROM categories where name = 'root';
	
	find_ancestors(l_cat);
	

EXCEPTION

	WHEN OTHERS
	THEN
		NULL;
END;
/

