/*
--------------Create Database & Schema---------------

---------->code purpose<-------------------------
This script creates new database named "Datawarehouse" if it already exists it will be dropped and created again . it also creates schema 
names "bronze" , "silver" , "gold" .

-----------> Warning <-----------------
Running this code drops the entire database if named under "Datawarehouse" exists .
All the data inside this database will de deleted . 
*/




USE master;
GO

-- Drop and recreate 'Datawarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Datawarehouse')
BEGIN
    ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Datawarehouse;
END;
GO

-- Create Database
CREATE DATABASE Datawarehouse;
GO

USE Datawarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
