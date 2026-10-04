# Sql-data-warehouse-project
Building a mordern data warehoure with sql server , including ETL processes , data modeling and data analytics



------------------------------------
if OBJECT_ID ('bronze.crm_cust_info','U') is not null
	drop table bronze.crm_cust_info;
go
Create TABLE bronze.crm_cust_info(
	cust_id INT,
	cust_key NVARCHAR(50),
	cust_Firstname NVARCHAR(50),
	cust_Lastname NVARCHAR(50),
	Cust_Marital_status Nvarchar(50),
	cust_Gender NVARCHAR(50),
	cust_Create_date DATE
);
go

if OBJECT_ID ('bronze.crm_prd_info','U') is not null
	drop table bronze.crm_prd_info;
go
Create table bronze.crm_prd_info(
	prd_id INT,
	prd_Key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_Start_date DateTime,
	Prd_end_date Datetime
);
go

if OBJECT_ID ('bronze.crm_sales_Details','U') is not null
	drop table bronze.crm_sales_Details;
go
create table bronze.crm_sales_Details(
	sales_ord_num NVARCHAR(50),
	sales_prd_key NVARCHAR(50),
	sales_cust_id INT,
	sales_order_date INT,
	sales_ship_date INT,
	sales_due_date INT,
	sales_sls INT,
	sales_quantity INT,
	sales_price INT
);
go

if OBJECT_ID ('bronze.erp_cust_az12','U') is not null
	drop table bronze.erp_cust_az12;
go
create table bronze.erp_cust_az12(
	cid NVARCHAR(50),
	Bdate Date,
	Gender Nvarchar(50)
);
go

if OBJECT_ID ('bronze.erp_LOC_a101(','U') is not null
	drop table bronze.erp_LOC_a101;
go
create table bronze.erp_LOC_a101(
	CID Nvarchar(50),
	Country Nvarchar(50)
);

if OBJECT_ID ('bronze.erp_PX_CAT_g1v2','U') is not null
	drop table bronze.erp_PX_CAT_g1v2;
go
create table bronze.erp_PX_CAT_g1v2(
	ID Nvarchar(50),
	CAT Nvarchar(50),
	SUB_CAT Nvarchar(50) ,
	Maintenance Nvarchar(50)
);
go
