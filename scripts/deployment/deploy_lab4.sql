/*
================================================================================
  deploy_lab4.sql — Lab 4 mid deploy (OrderOps schema + core objects)
================================================================================



  If you moved the project folder, update ScriptRoot below to your scripts path.
================================================================================
*/

:setvar ScriptRoot "D:\ITS\SEM-2\SQL SERVER\SIMULATION\simulation 4-5\simulation 4-5\scripts"

:r $(ScriptRoot)\setup\initialize_orderops_schema.sql
:r $(ScriptRoot)\tables\inspection_request_registration.sql
:r $(ScriptRoot)\tables\error_log.sql
:r $(ScriptRoot)\tables\failed_inspection_queue.sql
:r $(ScriptRoot)\tables\product_release_review.sql
:r $(ScriptRoot)\tables\notification_log.sql
:r $(ScriptRoot)\views\vProductInspectionSummary.sql
:r $(ScriptRoot)\views\vw_PendingInspections.sql
:r $(ScriptRoot)\functions\fn_InspectionScoreClass.sql
:r $(ScriptRoot)\controlflow\monthly_inspection_schedule.sql
:r $(ScriptRoot)\functions\fn_GetProductInspectionData.sql
:r $(ScriptRoot)\errorhandling\inspection_error_logging.sql
:r $(ScriptRoot)\procedures\usp_GetInspectionRequests.sql
GO

PRINT '=== deploy_lab4.sql completed successfully ===';
GO

SELECT name AS ObjectName, type_desc AS ObjectType
FROM sys.objects
WHERE schema_id = SCHEMA_ID(N'OrderOps')
  AND name IN (
      N'BatchLog', N'TaxRate', N'ProductCatalog', N'ProductStock',
      N'usp_BatchOrderPricingValidation', N'vOrderableProducts',
      N'vInventorySnapshot', N'vPromoEligibleProducts'
  )
ORDER BY name;
GO

:r $(ScriptRoot)\validation\validate_lab4_results.sql
