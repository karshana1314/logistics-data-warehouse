# Logistics Data Warehouse

A Logistics Data Warehouse project built using SQL, covering data staging, data quality checks, transformation, dimensional modeling, and data mart creation.

## Project Overview

This project demonstrates an end-to-end SQL data warehouse workflow using logistics data.

The project includes:

- Customers
- Drivers
- Locations
- Shipments
- Deliveries

## Project Workflow

Source Tables
↓
Staging Tables
↓
Data Quality Checks
↓
Dimension & Fact Tables
↓
Data Mart

## Data Staging

Staging tables are created for:

- Customers
- Drivers
- Locations
- Shipments
- Deliveries

Data quality checks include duplicate detection, NULL checks, invalid references, date validation, and delivery status checks.

## Data Warehouse

The warehouse layer includes:

### Dimension Tables
- dim_customer
- dim_driver
- dim_location
- dim_date

### Fact Tables
- fact_shipment
- fact_delivery

## Data Mart

A delivery performance data mart is created using:

`dm_delivery_performance`

It combines shipment, customer, driver, location, date, and delivery information for analysis.

## Technologies

- MySQL
- SQL
- Data Staging
- Data Quality Checks
- Dimensional Modeling
- Data Warehouse
- Data Mart

## SQL Script

The complete SQL implementation is available in:

`final_log.sql`
