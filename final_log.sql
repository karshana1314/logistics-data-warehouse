CREATE DATABASE logistics_source;
USE logistics_source;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100)
);


/* DRIVERS */

CREATE TABLE drivers (
    driver_id INT PRIMARY KEY,
    driver_name VARCHAR(100),
    phone VARCHAR(20)
);


/* LOCATIONS */

CREATE TABLE locations (
    location_id INT PRIMARY KEY,
    location_name VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100)
);


/* SHIPMENTS */

CREATE TABLE shipments (
    shipment_id INT PRIMARY KEY,
    customer_id INT,
    shipment_date DATE,
    origin_location_id INT,
    destination_location_id INT
);


/* DELIVERIES */

CREATE TABLE deliveries (
    delivery_id INT PRIMARY KEY,
    shipment_id INT,
    driver_id INT,
    delivery_date DATE,
    delivery_status VARCHAR(30)
);



SHOW TABLES;




SELECT * FROM customers;

SELECT * FROM drivers;

SELECT * FROM locations;

SELECT * FROM shipments;

SELECT * FROM deliveries;




CREATE TABLE stg_shipments (
    shipment_id INT,
    customer_id INT,
    shipment_date DATE,
    origin_location_id INT,
    destination_location_id INT
);

INSERT INTO stg_shipments (
    shipment_id,
    customer_id,
    shipment_date,
    origin_location_id,
    destination_location_id
)
SELECT
    shipment_id,
    customer_id,
    shipment_date,
    origin_location_id,
    destination_location_id
FROM shipments;




SELECT *
FROM stg_shipments;



SELECT
    shipment_id,
    COUNT(*) AS duplicate_count
FROM stg_shipments
GROUP BY shipment_id
HAVING COUNT(*) > 1;


SELECT *
FROM stg_shipments
WHERE shipment_id IS NULL
   OR customer_id IS NULL
   OR shipment_date IS NULL
   OR origin_location_id IS NULL
   OR destination_location_id IS NULL;


-- Why check?

-- Historical shipment data warehouse-ku load pannumbodhu, accidentally future date irundha data quality problem.

SELECT *
FROM stg_shipments
WHERE shipment_date > CURDATE();#current date =CURDATE()


SELECT s.*
FROM stg_shipments s
LEFT JOIN locations l
    ON s.destination_location_id = l.location_id
WHERE l.location_id IS NULL;

DESCRIBE customers;

CREATE TABLE stg_customers (
    customer_id INT,
    customer_name VARCHAR(100),
    phone VARCHAR(15),
    city VARCHAR(50)
);

INSERT INTO stg_customers (
    customer_id,
    customer_name,
    phone,
    city
)
SELECT
    customer_id,
    customer_name,
    phone,
    city
FROM customers;

SELECT customer_id, COUNT(*) AS duplicate_count
FROM stg_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT *
FROM stg_customers
WHERE customer_id IS NULL
   OR customer_name IS NULL
   OR phone IS NULL
   OR city IS NULL;
   
   SELECT *
FROM stg_customers
WHERE phone IS NOT NULL
  AND phone = '';
  
  SELECT s.*
FROM stg_customers s
LEFT JOIN customers c
    ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

DESCRIBE drivers;

CREATE TABLE stg_drivers (
    driver_id INT,
    driver_name VARCHAR(100),
    phone VARCHAR(15)
);

INSERT INTO stg_drivers (
    driver_id,
    driver_name,
    phone
)
SELECT
    driver_id,
    driver_name,
    phone
FROM drivers;

SELECT driver_id, COUNT(*) AS duplicate_count
FROM stg_drivers
GROUP BY driver_id
HAVING COUNT(*) > 1;

SELECT *
FROM stg_drivers
WHERE driver_id IS NULL
   OR driver_name IS NULL
   OR phone IS NULL;
   
   SELECT *
FROM stg_drivers
WHERE phone IS NOT NULL
  AND phone = '';
  
  SELECT s.*
FROM stg_drivers s
LEFT JOIN drivers d
    ON s.driver_id = d.driver_id
WHERE d.driver_id IS NULL;


DESCRIBE locations;

CREATE TABLE stg_locations (
    location_id INT,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);

INSERT INTO stg_locations (
    location_id,
    city,
    state,
    country
)
SELECT
    location_id,
    city,
    state,
    country
FROM locations;

SELECT location_id, COUNT(*) AS duplicate_count
FROM stg_locations
GROUP BY location_id
HAVING COUNT(*) > 1;

SELECT *
FROM stg_locations
WHERE location_id IS NULL
   OR city IS NULL
   OR state IS NULL
   OR country IS NULL;
   
   SELECT s.*
FROM stg_locations s
LEFT JOIN locations l
    ON s.location_id = l.location_id
WHERE l.location_id IS NULL;

DESCRIBE deliveries;

CREATE TABLE stg_deliveries (
    delivery_id INT,
    shipment_id INT,
    driver_id INT,
    pickup_datetime DATETIME,
    delivery_datetime DATETIME,
    delivery_status VARCHAR(30)
);

INSERT INTO stg_deliveries (
    delivery_id,
    shipment_id,
    driver_id,
    pickup_datetime,
    delivery_datetime,
    delivery_status
)
SELECT
    delivery_id,
    shipment_id,
    driver_id,
    pickup_datetime,
    delivery_datetime,
    delivery_status
FROM deliveries;

SELECT * FROM stg_deliveries;

SELECT delivery_id, COUNT(*) AS duplicate_count
FROM stg_deliveries
GROUP BY delivery_id
HAVING COUNT(*) > 1;

SELECT *
FROM stg_deliveries
WHERE delivery_id IS NULL
   OR shipment_id IS NULL
   OR driver_id IS NULL
   OR pickup_datetime IS NULL
   OR delivery_status IS NULL;
  
  
  SELECT d.*
FROM stg_deliveries d
LEFT JOIN shipments s
    ON d.shipment_id = s.shipment_id
WHERE s.shipment_id IS NULL;

SELECT d.*
FROM stg_deliveries d
LEFT JOIN drivers dr
    ON d.driver_id = dr.driver_id
WHERE dr.driver_id IS NULL;

SELECT *
FROM stg_deliveries
WHERE delivery_datetime IS NOT NULL
  AND delivery_datetime < pickup_datetime;
  
  SELECT DISTINCT delivery_status
FROM stg_deliveries;

CREATE TABLE dim_customer (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(100),
    phone VARCHAR(15),
    city VARCHAR(50)
);

INSERT INTO dim_customer (
    customer_id,
    customer_name,
    phone,
    city
)
SELECT
    customer_id,
    customer_name,
    phone,
    city
FROM stg_customers;

SELECT * FROM dim_customer;

SELECT * FROM dim_customer;

CREATE TABLE dim_driver (
    driver_key INT AUTO_INCREMENT PRIMARY KEY,
    driver_id INT,
    driver_name VARCHAR(100),
    phone VARCHAR(15)
);

INSERT INTO dim_driver (
    driver_id,
    driver_name,
    phone
)
SELECT
    driver_id,
    driver_name,
    phone
FROM stg_drivers;

CREATE TABLE dim_location (
    location_key INT AUTO_INCREMENT PRIMARY KEY,
    location_id INT,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50)
);

INSERT INTO dim_location (
    location_id,
    city,
    state,
    country
)
SELECT
    location_id,
    city,
    state,
    country
FROM stg_locations;

SELECT * FROM dim_location;

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    year INT
);

INSERT INTO dim_date (
    date_key,
    full_date,
    day,
    month,
    month_name,
    quarter,
    year
)
SELECT
    DATE_FORMAT(d, '%Y%m%d') + 0,
    d,
    DAY(d),
    MONTH(d),
    MONTHNAME(d),
    QUARTER(d),
    YEAR(d)
FROM (
    SELECT '2026-08-20' AS d
    UNION ALL SELECT '2026-08-21'
    UNION ALL SELECT '2026-08-22'
    UNION ALL SELECT '2026-08-23'
    UNION ALL SELECT '2026-08-24'
    UNION ALL SELECT '2026-08-25'
    UNION ALL SELECT '2026-08-26'
    UNION ALL SELECT '2026-08-27'
) dates;

SELECT * FROM dim_date;

CREATE TABLE fact_shipment (
    shipment_key INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT,
    customer_key INT,
    shipment_date_key INT,
    origin_location_key INT,
    destination_location_key INT
);INSERT INTO fact_shipment (
    shipment_id,
    customer_key,
    shipment_date_key,
    origin_location_key,
    destination_location_key
)
SELECT
    s.shipment_id,
    c.customer_key,
    d.date_key,
    ol.location_key,
    dl.location_key
FROM stg_shipments s

JOIN dim_customer c
    ON s.customer_id = c.customer_id

JOIN dim_date d
    ON s.shipment_date = d.full_date

JOIN dim_location ol
    ON s.origin_location_id = ol.location_id

JOIN dim_location dl
    ON s.destination_location_id = dl.location_id;
    
    SELECT * FROM fact_shipment;
    
    CREATE TABLE fact_delivery (
    delivery_key INT AUTO_INCREMENT PRIMARY KEY,
    delivery_id INT,
    shipment_id INT,
    driver_key INT,
    pickup_date_key INT,
    delivery_date_key INT,
    delivery_status VARCHAR(30)
);

INSERT INTO fact_delivery (
    delivery_id,
    shipment_id,
    driver_key,
    pickup_date_key,
    delivery_date_key,
    delivery_status
)
SELECT
    d.delivery_id,
    d.shipment_id,
    dr.driver_key,
    DATE_FORMAT(d.pickup_datetime, '%Y%m%d') + 0,
    CASE
        WHEN d.delivery_datetime IS NOT NULL
        THEN DATE_FORMAT(d.delivery_datetime, '%Y%m%d') + 0
        ELSE NULL
    END,
    d.delivery_status
FROM stg_deliveries d
JOIN dim_driver dr
    ON d.driver_id = dr.driver_id;
    
    SELECT * FROM fact_delivery;
    
    SELECT f.*
FROM fact_delivery f
LEFT JOIN fact_shipment s
    ON f.shipment_id = s.shipment_id
WHERE s.shipment_id IS NULL;

SELECT f.*
FROM fact_shipment f
LEFT JOIN dim_customer c
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;

SELECT f.*
FROM fact_shipment f
LEFT JOIN dim_location l
    ON f.origin_location_key = l.location_key
WHERE l.location_key IS NULL;

SELECT f.*
FROM fact_shipment f
LEFT JOIN dim_location l
    ON f.destination_location_key = l.location_key
WHERE l.location_key IS NULL;


CREATE TABLE dm_delivery_performance (
    delivery_id INT,
    shipment_id INT,
    customer_name VARCHAR(100),
    driver_name VARCHAR(100),
    origin_city VARCHAR(50),
    destination_city VARCHAR(50),
    shipment_date DATE,
    pickup_datetime DATETIME,
    delivery_datetime DATETIME,
    delivery_status VARCHAR(30)
);


INSERT INTO dm_delivery_performance (
    delivery_id,
    shipment_id,
    customer_name,
    driver_name,
    origin_city,
    destination_city,
    shipment_date,
    pickup_datetime,
    delivery_datetime,
    delivery_status
)
SELECT
    fd.delivery_id,
    fs.shipment_id,
    c.customer_name,
    dr.driver_name,
    ol.city AS origin_city,
    dl.city AS destination_city,
    dd.full_date AS shipment_date,
    sd.pickup_datetime,
    sd.delivery_datetime,
    sd.delivery_status
FROM fact_delivery fd

JOIN fact_shipment fs
    ON fd.shipment_id = fs.shipment_id

JOIN dim_customer c
    ON fs.customer_key = c.customer_key

JOIN dim_driver dr
    ON fd.driver_key = dr.driver_key

JOIN dim_location ol
    ON fs.origin_location_key = ol.location_key

JOIN dim_location dl
    ON fs.destination_location_key = dl.location_key

JOIN dim_date dd
    ON fs.shipment_date_key = dd.date_key

JOIN stg_deliveries sd
    ON fd.delivery_id = sd.delivery_id;
    
    SELECT * 
FROM dm_delivery_performance;

SELECT COUNT(*) AS total_records
FROM dm_delivery_performance;

SELECT COUNT(*) AS total_records
FROM fact_delivery;

SELECT delivery_id, COUNT(*) AS count
FROM fact_delivery
GROUP BY delivery_id
HAVING COUNT(*) > 1;

TRUNCATE TABLE fact_delivery;

INSERT INTO fact_delivery (
    delivery_id,
    shipment_id,
    driver_key,
    pickup_date_key,
    delivery_date_key,
    delivery_status
)
SELECT
    d.delivery_id,
    d.shipment_id,
    dr.driver_key,
    DATE_FORMAT(d.pickup_datetime, '%Y%m%d') + 0,
    CASE
        WHEN d.delivery_datetime IS NOT NULL
        THEN DATE_FORMAT(d.delivery_datetime, '%Y%m%d') + 0
        ELSE NULL
    END,
    d.delivery_status
FROM stg_deliveries d
JOIN dim_driver dr
    ON d.driver_id = dr.driver_id;
    
    SELECT COUNT(*) AS total_records
FROM fact_delivery;

SELECT driver_id, COUNT(*) AS count
FROM stg_deliveries
GROUP BY driver_id;

SELECT COUNT(*) AS total_records
FROM stg_deliveries;

SELECT driver_id, COUNT(*) AS count
FROM dim_driver
GROUP BY driver_id
HAVING COUNT(*) > 1;

SELECT * FROM dim_driver;

TRUNCATE TABLE fact_delivery;

TRUNCATE TABLE dim_driver;

INSERT INTO dim_driver (
    driver_id,
    driver_name,
    phone
)
SELECT
    driver_id,
    driver_name,
    phone
FROM stg_drivers;

SELECT * FROM dim_driver;

INSERT INTO fact_delivery (
    delivery_id,
    shipment_id,
    driver_key,
    pickup_date_key,
    delivery_date_key,
    delivery_status
)
SELECT
    d.delivery_id,
    d.shipment_id,
    dr.driver_key,
    DATE_FORMAT(d.pickup_datetime, '%Y%m%d') + 0,
    CASE
        WHEN d.delivery_datetime IS NOT NULL
        THEN DATE_FORMAT(d.delivery_datetime, '%Y%m%d') + 0
        ELSE NULL
    END,
    d.delivery_status
FROM stg_deliveries d
JOIN dim_driver dr
    ON d.driver_id = dr.driver_id;
    
    SELECT COUNT(*) AS total_records
FROM fact_delivery;

TRUNCATE TABLE dm_delivery_performance;

INSERT INTO dm_delivery_performance (
    delivery_id,
    shipment_id,
    customer_name,
    driver_name,
    origin_city,
    destination_city,
    shipment_date,
    pickup_datetime,
    delivery_datetime,
    delivery_status
)
SELECT
    fd.delivery_id,
    fs.shipment_id,
    c.customer_name,
    dr.driver_name,
    ol.city AS origin_city,
    dl.city AS destination_city,
    dd.full_date AS shipment_date,
    sd.pickup_datetime,
    sd.delivery_datetime,
    sd.delivery_status
FROM fact_delivery fd
JOIN fact_shipment fs
    ON fd.shipment_id = fs.shipment_id
JOIN dim_customer c
    ON fs.customer_key = c.customer_key
JOIN dim_driver dr
    ON fd.driver_key = dr.driver_key
JOIN dim_location ol
    ON fs.origin_location_key = ol.location_key
JOIN dim_location dl
    ON fs.destination_location_key = dl.location_key
JOIN dim_date dd
    ON fs.shipment_date_key = dd.date_key
JOIN stg_deliveries sd
    ON fd.delivery_id = sd.delivery_id;
    
    SELECT COUNT(*) AS total_records
FROM dm_delivery_performance;

SELECT *
FROM dm_delivery_performance;

SELECT
    delivery_status,
    COUNT(*) AS total_deliveries
FROM dm_delivery_performance
GROUP BY delivery_status;