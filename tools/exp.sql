-- SET DEFINE '?' to disable prompting for the ampersand in SQL*PLUS.

-- this is a 4-way self-join.  If we already know the data for the
-- lowest category, we can use a three way join.
SELECT NVL(c4.name, 'NULL') || ' ' || NVL(c4.id, 0) || ' ' ||
	NVL(c3.name, 'NULL') || ' ' || NVL(c3.id, 0) || ' ' ||
	NVL(c2.name, 'NULL') || ' ' || NVL(c2.id, 0) || ' ' ||
	NVL(c1.name, 'NULL') || ' ' || NVL(c1.id, 0) category_chain_4_way
FROM categories c4
LEFT OUTER JOIN categories c3 ON (c4.parent_id = c3.id)
LEFT OUTER JOIN categories c2 ON (c3.parent_id = c2.id)
LEFT OUTER JOIN categories c1 ON (c2.parent_id = c1.id)
WHERE c4.name = 'Quilts';

-- this is a three way self-join (see above).
SELECT NVL(c3.name, 'NULL') || ' ' || NVL(c3.id, 0) || ' ' ||
	NVL(c2.name, 'NULL') || ' ' || NVL(c2.id, 0) || ' ' ||
	NVL(c1.name, 'NULL') || ' ' || NVL(c1.id, 0) category_chain_3_way
FROM categories c3
LEFT OUTER JOIN categories c2 ON (c3.parent_id = c2.id)
LEFT OUTER JOIN categories c1 ON (c2.parent_id = c1.id)
WHERE c3.name = 'Bedding & Bath';
