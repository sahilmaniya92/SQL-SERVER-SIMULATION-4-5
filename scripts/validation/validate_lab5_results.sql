/*
    L5-T14 — Sahil (LAST): Validate full Lab 5 deploy results.
*/
SET NOCOUNT ON;

PRINT '=== validate_lab5_results.sql ===';

IF OBJECT_ID(N'OrderOps.usp_ApplyInventoryAdjustments', N'P') IS NULL
    THROW 50010, 'FAIL: Inventory adjustment procedure missing.', 1;

IF OBJECT_ID(N'OrderOps.usp_ExplainPromoTax', N'P') IS NULL
    THROW 50011, 'FAIL: Explain promo/tax procedure missing.', 1;

IF OBJECT_ID(N'OrderOps.usp_NotifyLowStockVendors', N'P') IS NULL
    THROW 50012, 'FAIL: Low-stock vendor notify procedure missing.', 1;

DECLARE @RC INT, @CID UNIQUEIDENTIFIER;
DECLARE @Adj OrderOps.InventoryAdjTVP;

INSERT INTO @Adj (ProductID, LocationID, DeltaQty, Reason)
VALUES (908, 6, 5, N'Validation test delta');

EXEC OrderOps.usp_ApplyInventoryAdjustments
    @Adjustments = @Adj,
    @ReturnCode = @RC OUTPUT,
    @CorrelationID = @CID OUTPUT;

EXEC OrderOps.usp_ExplainPromoTax
    @CustomerID = 11000, @OrderDate = '2014-05-15', @TerritoryID = 1,
    @CurrencyCode = 'USD', @ProductID = 908, @OrderQty = 12, @SpecialOfferID = 2,
    @ReturnCode = @RC OUTPUT, @CorrelationID = @CID OUTPUT;

EXEC OrderOps.usp_NotifyLowStockVendors
    @ThresholdQty = 500, @MaxIterations = 5,
    @ReturnCode = @RC OUTPUT, @CorrelationID = @CID OUTPUT;

PRINT 'PASS: Lab 5 validation succeeded.';
GO

/* --- Test query: confirm Lab 5 procedures exist --- */
SELECT name AS ProcedureName FROM sys.procedures
WHERE schema_id = SCHEMA_ID(N'OrderOps')
  AND name IN (N'usp_ApplyInventoryAdjustments', N'usp_ExplainPromoTax', N'usp_NotifyLowStockVendors')
ORDER BY name;
GO
