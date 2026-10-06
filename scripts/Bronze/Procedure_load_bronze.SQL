CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @starttime Datetime , @Endtime Datetime 
	BEGIN TRY
	DECLARE @batchTime_start Datetime , @batchTime_end Datetime
	Set @batchtime_start = GETDATE();
		PRINT '===========================================================';
		PRINT 'Loading Bronze layer ';
		PRINT '===========================================================';
		
		PRINT '--------------------------------------------';
		PRINT 'Loading CRM Tablers';
		PRINT '--------------------------------------------';

		SET @starttime = GETDATE(); 
		Print '----->Truncating bronze.crm_cust_info TABLE<-----';
		Truncate table bronze.crm_cust_info

		print 'Inserting Table: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Srujan kumar\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
				FIRSTROW=2,
				FIELDTERMINATOR =',',
				TABLOCK
		);
		SET @Endtime = GETDATE();
		print '---> Load Duration : ' + cast(datediff(second,@Starttime , @endtime) as Nvarchar)  +' Seconds';
		print'========---------- ------------==========';

		SET @starttime = GETDATE();
		Print '----->Truncating bronze.crm_prd_info TABLE<-----';
		TRUNCATE TABLE bronze.crm_prd_info

		print '----->Inserting Table: bronze.crm_prd_info<-----';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Srujan kumar\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with(
				FIRSTROW=2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);
		SET @Endtime = GETDATE();
		print '---> Load Duration : ' + cast(datediff(second,@Starttime , @endtime) as Nvarchar)  +' Seconds';
		print'========---------- ------------==========';

		SET @starttime = GETDATE();
		Print '----->Truncating bronze.crm_sales_Details TABLE<-----';
		Truncate table bronze.crm_sales_Details

		print '----->Inserting Table: bronze.crm_sales_Details<-----';
		BULK INSERT bronze.crm_sales_Details
		FROM 'C:\Users\Srujan kumar\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with(
				FIRSTROW=2,
				FIELDTERMINATOR = ',',
				TABLOCK
		);
		SET @Endtime = GETDATE();
		print '---> Load Duration : ' + cast(datediff(second,@Starttime , @endtime) as Nvarchar)  +' Seconds';
		print'========---------- ------------==========';

		
		PRINT '--------------------------------------------';
		PRINT 'Loading CRM Tablers';
		PRINT '--------------------------------------------';

		SET @starttime = GETDATE();
		Print '----->Truncating bronze.erp_cust_az12 TABLE<-----';
		Truncate table bronze.erp_cust_az12

		print '----->Inserting Table: bronze.erp_cust_az12<-----';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\Srujan kumar\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH(
				FIRSTROW=2,
				FIELDTERMINATOR=',',
				TABLOCK
		);
		SET @Endtime = GETDATE();
		print '---> Load Duration : ' + cast(datediff(second,@Starttime , @endtime) as Nvarchar)  +' Seconds';
		print'========---------- ------------==========';

		SET @starttime = GETDATE();
		Print '----->Truncating bronze.erp_loc_a101 TABLE<-----';
		TRUNCATE TABLE bronze.erp_loc_a101

		print '----->Inserting Table: bronze.erp_loc_a101<-----';
		BUlk INSERT bronze.erp_loc_a101
		FROM 'C:\Users\Srujan kumar\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR=',',
				TABLOCK
		);
		SET @Endtime = GETDATE();
		print '---> Load Duration : ' + cast(datediff(second,@Starttime , @endtime) as Nvarchar)  +' Seconds';
		print'========---------- ------------==========';
	
		SET @starttime = GETDATE();
		Print '----->Truncatingbronze.erp_loc_a101 TABLE<-----';
		TRUNCATE TABLE bronze.erp_loc_a101

		print '----->Inserting Table: bronze.erp_loc_a101<-----';
		BUlk INSERT bronze.erp_loc_a101
		FROM 'C:\Users\Srujan kumar\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH(
				FIRSTROW = 2,
				FIELDTERMINATOR=',',
				TABLOCK
		)
		SET @Endtime = GETDATE();
		print '---> Load Duration : ' + cast(datediff(second,@Starttime , @endtime) as Nvarchar)  +' Seconds';
		print'========---------- ------------==========';

		Set @batchtime_end = Getdate();
		print '<<<<<------------------------------------------------------------------>>>>>';
		print '--------------- Loading of bronze layer is completed -------------------';
		print '-----------------Load Duration : '+ cast(Datediff(second,@batchtime_start,@batchtime_end) as Nvarchar)
		print '<<<<<------------------------------------------------------------------>>>>>';

	End Try
	Begin catch
		print '====================================='
		print 'Error occured during loading bronze layer'
		print 'Error message :'+ error_message();
		print 'Error message :' +cast( error_number() as Nvarchar)
		print 'Error state :' +cast( error_state() as Nvarchar)
		print '====================================='
	end catch
END


