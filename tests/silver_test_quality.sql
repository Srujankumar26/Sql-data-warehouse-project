/*===============================================================================
Quality Checks
===============================================================================*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
SELECT
    cust_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cust_id
HAVING COUNT(*) > 1 OR cust_id IS NULL;

-- Check for Unwanted Spaces
SELECT
    cust_key
FROM silver.crm_cust_info
WHERE cust_key != TRIM(cust_key);

-- Data Standardization & Consistency
SELECT DISTINCT
    Cust_Marital_status
FROM silver.crm_cust_info;

-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
SELECT
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Values in Cost
SELECT
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info;

-- Check for Invalid Date Orders
SELECT
    *
FROM silver.crm_prd_info
WHERE Prd_end_date < prd_Start_date;

-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================

-- Check for Invalid Dates
SELECT
    NULLIF(sales_due_date,0) AS sales_due_date
FROM bronze.crm_sales_Details
WHERE sales_due_date <= 0
   OR LEN(sales_due_date) != 8
   OR sales_due_date > 20500101
   OR sales_due_date < 19000101;

-- Check for Invalid Date Orders
SELECT
    *
FROM silver.crm_sales_details
WHERE sales_order_date > sales_ship_date
   OR sales_order_date > sales_due_date;

-- Check Data Consistency
SELECT DISTINCT
    sales_sls,
    sales_quantity,
    sales_price
FROM silver.crm_sales_details
WHERE sales_sls != sales_quantity * sales_price
   OR sales_sls IS NULL
   OR sales_quantity IS NULL
   OR sales_price IS NULL
   OR sales_sls <= 0
   OR sales_quantity <= 0
   OR sales_price <= 0
ORDER BY sales_sls,sales_quantity,sales_price;

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================

-- Identify Out-of-Range Dates
SELECT DISTINCT
    Bdate
FROM silver.erp_cust_az12
WHERE Bdate < '1924-01-01'
   OR Bdate > GETDATE();

-- Data Standardization & Consistency
SELECT DISTINCT
    Gender
FROM silver.erp_cust_az12;

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================

-- Data Standardization & Consistency
SELECT DISTINCT
    Country
FROM silver.erp_loc_a101
ORDER BY Country;

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================

-- Check for Unwanted Spaces
SELECT
    *
FROM silver.erp_px_cat_g1v2
WHERE CAT != TRIM(CAT)
   OR SUB_CAT != TRIM(SUB_CAT)
   OR Maintenance != TRIM(Maintenance);

-- Data Standardization & Consistency
SELECT DISTINCT
    Maintenance
FROM silver.erp_px_cat_g1v2;
