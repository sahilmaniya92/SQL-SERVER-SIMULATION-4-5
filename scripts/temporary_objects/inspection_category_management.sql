CREATE OR ALTER PROCEDURE OrderOps.usp_ApplyInventoryAdjustments
    @Adjustments   OrderOps.InventoryAdjTVP READONLY,
    @ReturnCode    INT OUTPUT,
    @CorrelationID UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ProcName SYSNAME = N'OrderOps.usp_ApplyInventoryAdjustments';

    SET @CorrelationID = NEWID();
    SET @ReturnCode = 2;

    EXEC OrderOps.usp_WriteBatchLog
        @CorrelationID = @CorrelationID,
        @ProcName = @ProcName,
        @Severity = 0,
        @Code = 'INFO',
        @Message = N'Inventory adjustment batch started.';

    CREATE TABLE #AdjResults
    (
        ProductID  INT         NOT NULL,
        LocationID SMALLINT    NOT NULL,
        DeltaQty   INT         NOT NULL,
        Status     VARCHAR(10) NOT NULL,
        Code       VARCHAR(10) NOT NULL,
        Message    NVARCHAR(4000) NOT NULL
    );

    INSERT INTO #AdjResults (ProductID, LocationID, DeltaQty, Status, Code, Message)
    SELECT
        a.ProductID,
        a.LocationID,
        a.DeltaQty,
        CASE
            WHEN a.DeltaQty = 0 THEN 'ERROR'
            WHEN p.ProductID IS NULL THEN 'ERROR'
            WHEN l.LocationID IS NULL THEN 'ERROR'
            ELSE 'OK'
        END,
        CASE
            WHEN a.DeltaQty = 0 THEN 'SYS999'
            WHEN p.ProductID IS NULL THEN 'PRD002'
            WHEN l.LocationID IS NULL THEN 'SYS999'
            ELSE 'INFO'
        END,
        CASE
            WHEN a.DeltaQty = 0 THEN N'Delta quantity cannot be zero.'
            WHEN p.ProductID IS NULL THEN N'Product not found.'
            WHEN l.LocationID IS NULL THEN N'Location not found.'
            ELSE N'Adjustment applied.'
        END
    FROM @Adjustments AS a
    LEFT JOIN OrderOps.ProductCatalog AS p ON p.ProductID = a.ProductID
    LEFT JOIN OrderOps.LocationCatalog AS l ON l.LocationID = a.LocationID;

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO OrderOps.InventoryDelta (ProductID, LocationID, DeltaQty, Reason)
        SELECT a.ProductID, a.LocationID, a.DeltaQty, a.Reason
        FROM @Adjustments AS a
        INNER JOIN OrderOps.ProductCatalog AS p ON p.ProductID = a.ProductID
        INNER JOIN OrderOps.LocationCatalog AS l ON l.LocationID = a.LocationID
        WHERE a.DeltaQty <> 0;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH;

    IF EXISTS (SELECT 1 FROM #AdjResults WHERE Status = 'ERROR')
        SET @ReturnCode = CASE WHEN EXISTS (SELECT 1 FROM #AdjResults WHERE Status = 'OK') THEN 1 ELSE 2 END;
    ELSE
        SET @ReturnCode = 0;

    EXEC OrderOps.usp_WriteBatchLog
        @CorrelationID = @CorrelationID,
        @ProcName = @ProcName,
        @Severity = 0,
        @Code = 'INFO',
        @Message = N'Inventory adjustment batch completed.';

    SELECT ProductID, LocationID, DeltaQty, Status, Code, Message FROM #AdjResults;
    SELECT ReturnCode = @ReturnCode, CorrelationID = @CorrelationID;
END;
GO

/* --- Test query: inventory adjustment stored procedure --- */
DECLARE @RC INT, @CID UNIQUEIDENTIFIER;
DECLARE @Adj OrderOps.InventoryAdjTVP;
INSERT INTO @Adj (ProductID, LocationID, DeltaQty, Reason)
VALUES (908, 6, 1, N'Test adjustment');
EXEC OrderOps.usp_ApplyInventoryAdjustments
    @Adjustments = @Adj, @ReturnCode = @RC OUTPUT, @CorrelationID = @CID OUTPUT;
GO
