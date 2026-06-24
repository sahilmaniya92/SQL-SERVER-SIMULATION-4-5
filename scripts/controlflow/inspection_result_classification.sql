/*
    L5-T3 — Brian: policy flag demonstration (bypass promo, strict inventory, auto-best promo).
*/
SET NOCOUNT ON;

DECLARE @RC INT, @CID UNIQUEIDENTIFIER;
DECLARE @H OrderOps.OrderHeaderTVP, @L OrderOps.OrderLineTVP;

INSERT INTO @H VALUES (11000, '2014-05-15', 1, 'USD', 'Web');
INSERT INTO @L VALUES (908, 12, NULL);

PRINT 'Auto-best promotion ON:';
EXEC OrderOps.usp_BatchOrderPricingValidation
    @Headers = @H, @Lines = @L, @AutoBestPromo = 1, @StrictInventory = 0,
    @ReturnCode = @RC OUTPUT, @CorrelationID = @CID OUTPUT;
GO

/* --- Test query: verify batch policy run logged --- */
SELECT TOP 1 * FROM OrderOps.BatchLog ORDER BY BatchLogID DESC;
GO
