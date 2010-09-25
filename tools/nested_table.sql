CREATE OR REPLACE TYPE number_array_type IS TABLE OF number(38);
/
CREATE OR REPLACE FUNCTION sum_array_elements(array_val IN number_array_type) RETURN NUMBER IS
	n NUMBER := 0;
BEGIN
	FOR i IN array_val.FIRST .. array_val.LAST
	LOOP
		n := n + array_val(i);
	END LOOP;
    RETURN n;
END;
/

CREATE OR REPLACE FUNCTION get_number_array RETURN number_array_type IS
	n number_array_type := number_array_type(5, 6);
BEGIN
	return n;
END;
/