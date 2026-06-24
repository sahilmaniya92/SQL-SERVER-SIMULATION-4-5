/*
================================================================================
  deploy_all.sql — Full deploy (Lab 4 + Lab 5)
================================================================================

  HOW TO RUN IN SSMS:
  -------------------
  1. Connect to SQL Server (e.g. .\SQLEXPRESS)
  2. Select your database in the dropdown
  3. Query -> SQLCMD Mode -> ON  (required!)
  4. Open THIS file and press F5

  HOW TO RUN IN POWERSHELL:
  -------------------------
  cd "D:\ITS\SEM-2\SQL SERVER\SIMULATION\simulation 4-5\simulation 4-5\scripts\deployment"
  sqlcmd -S .\SQLEXPRESS -C -E -d master -i deploy_all.sql

  If you moved the project folder, update ScriptRoot below to your scripts path.
================================================================================
*/

:setvar ScriptRoot "D:\ITS\SEM-2\SQL SERVER\SIMULATION\simulation 4-5\simulation 4-5\scripts"

:r $(ScriptRoot)\deployment\deploy_lab4.sql
:r $(ScriptRoot)\temporary_objects\inspection_category_management.sql
:r $(ScriptRoot)\controlflow\inspection_result_classification.sql
:r $(ScriptRoot)\cursors\failed_product_review_cursor.sql
:r $(ScriptRoot)\cursors\inspection_notification_cursor.sql
GO

PRINT '=== deploy_all.sql completed successfully ===';
GO

SELECT name AS ObjectName, type_desc AS ObjectType
FROM sys.objects
WHERE schema_id = SCHEMA_ID(N'OrderOps')
  AND name IN (
      N'usp_ApplyInventoryAdjustments',
      N'usp_ExplainPromoTax',
      N'usp_NotifyLowStockVendors'
  )
ORDER BY name;
GO

:r $(ScriptRoot)\validation\validate_lab5_results.sql
