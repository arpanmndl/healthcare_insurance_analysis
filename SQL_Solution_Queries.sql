-- creating new database and importing tables - "Medical Examinations", "Hospitalisation Details" and "Names"

create database capstone1;






-- checking the total row count of "Hospitalisation Details" table

SELECT COUNT(*) AS total_rows
FROM hos_details;


-- checking the total row count of "Medical Examinations" table

SELECT COUNT(*) AS total_rows
FROM med_exams;






-- Searching for missing values in "Hospitalisation Details" table

SELECT 
    COLUMN_NAME
FROM
    information_schema.columns
WHERE
    TABLE_NAME = 'hos_details';


SELECT
    SUM(CASE WHEN 'Customer ID' IS NULL THEN 1 ELSE 0 END) AS Customer_ID_null_count,
    SUM(CASE WHEN 'year' IS NULL THEN 1 ELSE 0 END) AS year_null_count,
    SUM(CASE WHEN 'month' IS NULL THEN 1 ELSE 0 END) AS month_null_count,
    SUM(CASE WHEN 'date' IS NULL THEN 1 ELSE 0 END) AS date_null_count,
    SUM(CASE WHEN 'children' IS NULL THEN 1 ELSE 0 END) AS children_null_count,
    SUM(CASE WHEN 'charges' IS NULL THEN 1 ELSE 0 END) AS charges_null_count,
    SUM(CASE WHEN 'Hospital tier' IS NULL THEN 1 ELSE 0 END) AS Hospital_tier_null_count,
    SUM(CASE WHEN 'City tier' IS NULL THEN 1 ELSE 0 END) AS City_tier_null_count,
    SUM(CASE WHEN 'State ID' IS NULL THEN 1 ELSE 0 END) AS State_ID_null_count
FROM hos_details;






-- Searching for missing values in "Medical Examinations" table

SELECT 
    COLUMN_NAME
FROM
    information_schema.columns
WHERE
    TABLE_NAME = 'med_exams';


SELECT
    SUM(CASE WHEN 'Customer ID' IS NULL THEN 1 ELSE 0 END) AS Customer_ID_null_count,
    SUM(CASE WHEN 'BMI' IS NULL THEN 1 ELSE 0 END) AS BMI_null_count,
    SUM(CASE WHEN 'HBA1C' IS NULL THEN 1 ELSE 0 END) AS HBA1C_null_count,
    SUM(CASE WHEN 'Heart Issues' IS NULL THEN 1 ELSE 0 END) AS Heart_Issues_null_count,
    SUM(CASE WHEN 'Any Transplants' IS NULL THEN 1 ELSE 0 END) AS Any_Transplants_null_count,
    SUM(CASE WHEN 'Cancer history' IS NULL THEN 1 ELSE 0 END) AS Cancer_history_null_count,
    SUM(CASE WHEN 'NumberOfMajorSurgeries' IS NULL THEN 1 ELSE 0 END) AS NumberOfMajorSurgeries_tier_null_count,
    SUM(CASE WHEN 'smoker' IS NULL THEN 1 ELSE 0 END) AS smoker_null_count
FROM med_exams;






-- checking unique values for categorical columns in "Hospitalisation Details" table

select `Hospital tier`, count(`Hospital tier`) from hos_details group by `Hospital tier`; -- have missing values -> "?"

select `City tier`, count(`City tier`) from hos_details group by `City tier`; -- have missing values -> "?"

select year, count(year) from hos_details group by year;

select date, count(date) from hos_details group by date;

select month, count(month) from hos_details group by month; -- have missing values -> "?"

select children, count(children) from hos_details group by children;

select `State ID`, count(`State ID`) from hos_details group by `State ID`; -- have missing values -> "?"

-- deleting rows having "?" as values

SET SQL_SAFE_UPDATES = 0;
DELETE FROM hos_details 
WHERE
    `Hospital tier` = '?'
    OR `City tier` = '?'
    OR month = '?'
    OR `State ID` = '?';
SET SQL_SAFE_UPDATES = 1;




-- checking unique values for categorical columns in "Hospitalisation Details" table

select `Heart Issues`, count(`Heart Issues`) from med_exams group by `Heart Issues`;

select `Any Transplants`, count(`Any Transplants`) from med_exams group by `Any Transplants`;

select `Cancer history`, count(`Cancer history`) from med_exams group by `Cancer history`;

select NumberOfMajorSurgeries, count(NumberOfMajorSurgeries) from med_exams group by NumberOfMajorSurgeries;

select smoker, count(smoker) from med_exams group by smoker;  -- have missing values -> "?"

-- deleting rows having "?" as values

SET SQL_SAFE_UPDATES = 0;
DELETE FROM med_exams
WHERE
    smoker = '?';
SET SQL_SAFE_UPDATES = 1;






-- Counting duplicates in "Hospitalisation Details" table

SELECT `Customer ID`,
    COUNT(*) AS CNT
FROM hos_details
GROUP BY `Customer ID`
HAVING COUNT(*) > 1;


-- Found some rows with "Customer ID" = ? in "Hospitalisation Details" table

select * from hos_details where `Customer ID`='?';


-- Deleting those rows having "Customer ID" = ? in "Hospitalisation Details" table

SET SQL_SAFE_UPDATES = 0;
DELETE FROM hos_details 
WHERE
    `Customer ID` = '?';
SET SQL_SAFE_UPDATES = 1;






-- Counting duplicates in "Medical Examinations" table

SELECT `Customer ID`,
    COUNT(*) AS CNT
FROM med_exams
GROUP BY `Customer ID`
HAVING COUNT(*) > 1;

-- no duplicate values found in "Medical Examinations" table






-- 1/a. Merge the two tables by first identifying the columns in the data tables that will help you in merging

SELECT *
FROM hos_details
INNER JOIN med_exams ON hos_details.`Customer ID` = med_exams.`Customer ID`;






--  1/b. In both tables, add a Primary Key constraint for these columns

ALTER TABLE hos_details
ADD PRIMARY KEY (`Customer ID`(255));


ALTER TABLE med_exams
ADD PRIMARY KEY (`Customer ID`(255));






-- 2. Retrieve information about people who are diabetic and have heart problems with their average age, the average number of dependent children, average BMI, and average hospitalization costs

SELECT 
    TRUNCATE(AVG(YEAR(CURDATE()) - h.year),2) AS `Average Age`,
    ROUND(AVG(h.children)) AS `Average Dependent Children`,
    TRUNCATE(AVG(m.BMI),2) AS `Average BMI`,
    TRUNCATE(AVG(h.charges),2) AS `Average Hospitalisation Charge`
FROM
    hos_details h
        INNER JOIN
    med_exams m ON h.`Customer ID` = m.`Customer ID`
WHERE
    m.`Heart Issues` = 'Yes'
        AND m.HBA1C >= 6.5;






-- 3. Find the average hospitalization cost for each hospital tier and each city level

SELECT 
    h.`Hospital tier`,
    h.`City tier`,
    TRUNCATE(AVG(h.charges) , 2) AS `Average Hospitalisation Charge`
FROM
    hos_details h
        INNER JOIN
    med_exams m ON h.`Customer ID` = m.`Customer ID`
GROUP BY h.`Hospital tier` , h.`City tier`;






-- 4. Determine the number of people who have had major surgery with a history of cancer

SELECT COUNT(NumberOfMajorSurgeries)
FROM med_exams
WHERE `Cancer history` = 'Yes' AND NumberOfMajorSurgeries > 0;






-- 5. Determine the number of tier-1 hospitals in each state

SELECT 
    `State ID`, COUNT(`Hospital tier`) AS `Tier 1 Hospitals`
FROM
    hos_details
WHERE
    `Hospital tier` = 'tier - 1'
GROUP BY `State ID`;