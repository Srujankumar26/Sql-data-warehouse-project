USE [Datawarehouse]
GO
/****** Object:  StoredProcedure [silver].[load_silver]    Script Date: 10-11-2026 15:49:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

ALTER   PROCEDURE [silver].[load_silver] AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';
        -- Loading silver.crm_cust_info

            SET @start_time = GETDATE();
            PRINT '>> Truncating Table: silver.crm_cust_info';
            TRUNCATE TABLE silver.crm_cust_info;
            PRINT '>> Inserting Data Into: silver.crm_cust_info';
            INSERT INTO silver.crm_cust_info (
                cust_id,
                cust_key,
                cust_Firstname,
                cust_Lastname,
                Cust_Marital_status,
                cust_Gender,
                cust_Create_date
            )
            SELECT
                cust_id,
                cust_key,
                TRIM(cust_Firstname) AS cust_Firstname,
                TRIM(cust_Lastname) AS cust_Lastname,
                CASE
                    WHEN UPPER(TRIM(Cust_Marital_status)) = 'S' THEN 'Single'
                    WHEN UPPER(TRIM(Cust_Marital_status)) = 'M' THEN 'Married'
                    ELSE 'n/a'
                END AS Cust_Marital_status,
                CASE
                    WHEN UPPER(TRIM(cust_Gender)) = 'F' THEN 'Female'
                    WHEN UPPER(TRIM(cust_Gender)) = 'M' THEN 'Male'
                    ELSE 'n/a'
                END AS cust_Gender,
                cust_Create_date
            FROM (
                SELECT
                    *,
                    ROW_NUMBER() OVER (
                        PARTITION BY cust_id
                        ORDER BY cust_Create_date DESC
                    ) AS flag_last
                FROM bronze.crm_cust_info
                WHERE cust_id IS NOT NULL
            ) t
            WHERE flag_last = 1;
            SET @end_time = GETDATE();
            PRINT '>> Load Duration: '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)+ ' seconds';
            PRINT '>> -------------';

            -- Loading silver.crm_prd_info
            SET @start_time = GETDATE();
            PRINT '>> Truncating Table: silver.crm_prd_info';
            TRUNCATE TABLE silver.crm_prd_info;
            PRINT '>> Inserting Data Into: silver.crm_prd_info';
            INSERT INTO silver.crm_prd_info (
                prd_id,
                cat_id,
                prd_Key,
                prd_nm,
                prd_cost,
                prd_line,
                prd_Start_date,
                Prd_end_date
            )
            SELECT
                prd_id,
                REPLACE(SUBSTRING(prd_Key, 1, 5), '-', '_') AS cat_id,
                SUBSTRING(prd_Key, 7, LEN(prd_Key)) AS prd_Key,
                prd_nm,
                ISNULL(prd_cost, 0) AS prd_cost,
                CASE
                    WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                    WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                    WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                    WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                    ELSE 'n/a'
                END AS prd_line,
                CAST(prd_Start_date AS DATE) AS prd_Start_date,
                CAST(
                    LEAD(prd_Start_date) OVER (
                        PARTITION BY prd_Key
                        ORDER BY prd_Start_date
                    ) - 1 AS DATE
                ) AS Prd_end_date
            FROM bronze.crm_prd_info;
            SET @end_time = GETDATE();
            PRINT '>> Load Duration: '+ CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)+ ' seconds';
            PRINT '>> -------------';
            -- Loading silver.crm_sales_details
            SET @start_time = GETDATE();
            PRINT '>> Truncating Table: silver.crm_sales_details';
            TRUNCATE TABLE silver.crm_sales_details;
            PRINT '>> Inserting Data Into: silver.crm_sales_details';
            INSERT INTO silver.crm_sales_details (
                sales_ord_num,
                sales_prd_key,
                sales_cust_id,
                sales_order_date,
                sales_ship_date,
                sales_due_date,
                sales_sls,
                sales_quantity,
                sales_price
            )
            SELECT
                sales_ord_num,
                sales_prd_key,
                sales_cust_id,
                CASE
                    WHEN sales_order_date = 0 OR LEN(sales_order_date) != 8 THEN NULL
                    ELSE CAST(CAST(sales_order_date AS VARCHAR) AS DATE)
                END AS sales_order_date,
                CASE
                    WHEN sales_ship_date = 0 OR LEN(sales_ship_date) != 8 THEN NULL
                    ELSE CAST(CAST(sales_ship_date AS VARCHAR) AS DATE)
                END AS sales_ship_date,
                CASE
                    WHEN sales_due_date = 0 OR LEN(sales_due_date) != 8 THEN NULL
                    ELSE CAST(CAST(sales_due_date AS VARCHAR) AS DATE)
                END AS sales_due_date,
                CASE
                    WHEN sales_sls IS NULL OR sales_sls <= 0 OR sales_sls != sales_quantity * ABS(sales_price)
                        THEN sales_quantity * ABS(sales_price)
                    ELSE sales_sls
                END AS sales_sls,
                sales_quantity,
                CASE
                    WHEN sales_price IS NULL OR sales_price <= 0
                        THEN sales_sls / NULLIF(sales_quantity,0)
                    ELSE sales_price
                END AS sales_price
            FROM bronze.crm_sales_Details;
            SET @end_time = GETDATE();
            PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
            PRINT '>> -------------';

            -- Loading erp_cust_az12
            SET @start_time = GETDATE();
            PRINT '>> Truncating Table: silver.erp_cust_az12';
            TRUNCATE TABLE silver.erp_cust_az12;
            PRINT '>> Inserting Data Into: silver.erp_cust_az12';
            INSERT INTO silver.erp_cust_az12 (
                cid,
                Bdate,
                Gender
            )
            SELECT
                CASE
                    WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
                    ELSE cid
                END AS cid,
                CASE
                    WHEN Bdate > GETDATE() THEN NULL
                    ELSE Bdate
                END AS Bdate,
                CASE
                    WHEN UPPER(TRIM(Gender)) IN ('F','FEMALE') THEN 'Female'
                    WHEN UPPER(TRIM(Gender)) IN ('M','MALE') THEN 'Male'
                    ELSE 'n/a'
                END AS Gender
            FROM bronze.erp_cust_az12;
            SET @end_time = GETDATE();
            PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
            PRINT '>> -------------';
            PRINT '------------------------------------------------';
            PRINT 'Loading ERP Tables';
            PRINT '------------------------------------------------';

            -- Loading erp_loc_a101
            SET @start_time = GETDATE();
            PRINT '>> Truncating Table: silver.erp_loc_a101';
            TRUNCATE TABLE silver.erp_loc_a101;
            PRINT '>> Inserting Data Into: silver.erp_loc_a101';
            INSERT INTO silver.erp_loc_a101 (
                CID,
                Country
            )
            SELECT
                REPLACE(CID,'-','') AS CID,
                CASE
                    WHEN TRIM(Country) = 'DE' THEN 'Germany'
                    WHEN TRIM(Country) IN ('US','USA') THEN 'United States'
                    WHEN TRIM(Country) = '' OR Country IS NULL THEN 'n/a'
                    ELSE TRIM(Country)
                END AS Country
            FROM bronze.erp_loc_a101;
            SET @end_time = GETDATE();
            PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
            PRINT '>> -------------';

            -- Loading erp_px_cat_g1v2
            SET @start_time = GETDATE();
            PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
            TRUNCATE TABLE silver.erp_px_cat_g1v2;
            PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
            INSERT INTO silver.erp_px_cat_g1v2 (
                ID,
                CAT,
                SUB_CAT,
                Maintenance
            )
            SELECT
                ID,
                CAT,
                SUB_CAT,
                Maintenance
            FROM bronze.erp_PX_CAT_g1v2;
            SET @end_time = GETDATE();
            PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' seconds';
            PRINT '>> -------------';

    SET @batch_end_time = GETDATE();
    PRINT '==========================================';
    PRINT 'Loading Silver Layer is Completed';
    PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds';
    PRINT '==========================================';
    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message ' + ERROR_MESSAGE();
        PRINT 'Error Number ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH
END
