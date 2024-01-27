DROP TABLE IF EXISTS cars;

CREATE TABLE IF NOT EXISTS cars (id INT , model VARCHAR(50), brand VARCHAR(20), color VARCHAR(20), manufacture INT );

INSERT INTO cars VALUES 
(1, 'Model S', 'Tesla', 'Blue', 2018),
(2, 'EQS', 'Mercedes-Benz', 'Black', 2022),
(3, 'iX', 'BMW', 'Red', 2022),
(4, 'Ioniq 5', 'Hyundai', 'White', 2021),
(5, 'Model S', 'Tesla', 'Silver', 2018),
(6, 'Ioniq 5', 'Hyundai', 'Green', 2021);


ALTER TABLE cars
ALTER COLUMN id SET NOT NULL

/* ##########################################################################
   <<<<>>>> Scenario 1: Data duplicated based on SOME of the columns <<<<>>>>
   ########################################################################## */

-- Requirement: Delete duplicate data from cars table. Duplicate record is identified based on the model and brand name.

SELECT * FROM cars  ORDER BY model, brand;

-->> SOLUTION 1: Delete using Unique identifier.
-- 1. identify duplicate value. use of group by  AND CTE
WITH T1 AS (
	SELECT  MAX(id) AS max_id FROM cars 
		GROUP BY model, brand
	HAVING COUNT(*) > 1)

-- 2. remove duplicate value

DELETE FROM cars 
	USING T1
WHERE cars.id = T1.max_id;

DELETE FROM cars;

----ALTERNATIVELY USE OF WHERE AND  IN()
DELETE FROM cars WHERE id IN (
	SELECT  MAX(id) AS max_id FROM cars 
		GROUP BY model, brand
	HAVING COUNT(*) > 1);

----populate deleted data 
INSERT INTO cars VALUES 
(5, 'Model S', 'Tesla', 'Silver', 2018),
(6, 'Ioniq 5', 'Hyundai', 'Green', 2021);



-->> SOLUTION 2: Using SELF join.
WITH T1 AS (SELECT C2.id FROM cars AS C1 
	JOIN cars AS C2 
	ON C1.model = C2.model AND C1.brand = C2.brand
WHERE C1.id < C2.id)

DELETE FROM cars 
	USING T1
WHERE cars.id = T1.id


-->> SOLUTION 3: Using Window function.
DELETE FROM cars WHERE id IN (
	SELECT id FROM (
	SELECT *, ROW_NUMBER() OVER(PARTITION BY model, brand) AS row FROM cars) AS dup_cars
	WHERE dup_cars.row > 1);


-->> SOLUTION 4: Using MIN function. This delete even multiple duplicate records
DELETE FROM cars 
WHERE id NOT IN (
	SELECT MIN(id) FROM cars
	GROUP BY model, brand
);


-->> SOLUTION 5: Using backup table (Not good approach).
CREATE TABLE cars_bkup AS SELECT * FROM cars WHERE 1=2;

INSERT INTO cars_bkup
SELECT * FROM cars WHERE id IN (
	SELECT MIN(id) FROM cars GROUP BY model, brand
);


select * from cars_bkup;
DROP TABLE cars;
ALTER TABLE cars_bkup RENAME TO cars;
SELECT * FROM cars;

-->> SOLUTION 6:Using backup table without dropping the original table.

CREATE TABLE cars_bkup AS SELECT * FROM cars WHERE 1=2;

INSERT INTO cars_bkup
SELECT * FROM cars WHERE id IN (
	SELECT MIN(id) FROM cars GROUP BY model, brand
);

SELECT * FROM cars_bkup;
SELECT * FROM cars;


TRUNCATE TABLE cars;

INSERT INTO cars 
SELECT * FROM cars_bkup;
DROP TABLE cars_bkup;




/* ##########################################################################
   <<<<>>>> Scenario 2: Data duplicated based on ALL of the columns <<<<>>>>
   ########################################################################## */

-- Requirement: Delete duplicate entry for a car in the CARS table.


INSERT INTO cars VALUES 
(1, 'Model S', 'Tesla', 'Blue', 2018),
(4, 'Ioniq 5', 'Hyundai', 'White', 2021),
(2, 'EQS', 'Mercedes-Benz', 'Black', 2022),
(3, 'iX', 'BMW', 'Red', 2022),
(4, 'Ioniq 5', 'Hyundai', 'White', 2021),
(1, 'Model S', 'Tesla', 'Blue', 2018)

SELECT * FROM cars;

-->> SOLUTION 1: Delete using CTID / ROWID (in Oracle).
SELECT *, CTID FROM cars;

DELETE FROM cars WHERE CTID IN (
	SELECT MAX(CTID) FROM cars
	GROUP BY model, brand
	HAVING COUNT(*) > 1
) 

-->> SOLUTION 2: By creating a temporary unique id column alter table cars add column row_num int generated always as identity.
ALTER TABLE cars ADD COLUMN row_number int GENERATED ALWAYS AS IDENTITY;
DELETE FROM cars WHERE row_number IN (
	SELECT MAX(row_number) FROM cars 
	GROUP BY model, brand
	HAVING COUNT(*) > 1
)

ALTER TABLE cars DROP COLUMN row_number;

-->> SOLUTION 3: By creating a backup table.
CREATE TABLE cars_bkp AS
SELECT DISTINCT * FROM cars;

DROP TABLE cars;
ALTER TABLE cars_bkp RENAME TO cars;


-->> SOLUTION 4: By creating a backup table without dropping the original table.
CREATE TABLE cars_bkp AS
SELECT DISTINCT * FROM cars;

TRUNCATE TABLE cars;

INSERT INTO cars 
SELECT DISTINCT * FROM cars_bkup;
DROP TABLE cars_bkup;












