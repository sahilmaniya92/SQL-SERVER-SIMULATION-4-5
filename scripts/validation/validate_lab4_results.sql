/*
    L4-T13 — Sahil (LAST): Validate Lab 4 deploy results.
*/
SET NOCOUNT ON;

PRINT '=== validate_lab4_results.sql ===';

IF SCHEMA_ID(N'OrderOps') IS NULL
    THROW 50001, 'FAIL: OrderOps schema missing.', 1;

IF OBJECT_ID(N'OrderOps.usp_BatchOrderPricingValidation', N'P') IS NULL
    THROW 50002, 'FAIL: Batch pricing procedure missing.', 1;

IF (SELECT COUNT(*) FROM OrderOps.TaxRate) < 3
    THROW 50003, 'FAIL: TaxRate seed count below 3 territories.', 1;

DECLARE @RC INT, @CID UNIQUEIDENTIFIER;
DECLARE @H OrderOps.OrderHeaderTVP, @L OrderOps.OrderLineTVP;

INSERT INTO @H VALUES (11000, '2014-05-15', 1, 'USD', 'Web');
INSERT INTO @L VALUES (908, 12, 2);

EXEC OrderOps.usp_BatchOrderPricingValidation
    @Headers = @H, @Lines = @L, @StrictInventory = 0,
    @ReturnCode = @RC OUTPUT, @CorrelationID = @CID OUTPUT;

IF @RC <> 0
    THROW 50004, 'FAIL: Happy-path batch did not return code 0.', 1;

IF NOT EXISTS (SELECT 1 FROM OrderOps.BatchLog WHERE CorrelationID = @CID)
    THROW 50005, 'FAIL: BatchLog missing CorrelationID audit rows.', 1;

SELECT [Check] = 'vOrderableProducts', [RowCount] = COUNT(*) FROM OrderOps.vOrderableProducts;
SELECT [Check] = 'vPromoEligibleProducts', [RowCount] = COUNT(*) FROM OrderOps.vPromoEligibleProducts;
SELECT [Check] = 'vInventorySnapshot', [RowCount] = COUNT(*) FROM OrderOps.vInventorySnapshot;

PRINT 'PASS: Lab 4 validation succeeded.';
GO

/* --- Test query: confirm OrderOps views exist --- */
SELECT name AS ViewName FROM sys.views WHERE schema_id = SCHEMA_ID(N'OrderOps') ORDER BY name;
GO
