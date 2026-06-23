/* L5-T13 - Kelvin/Dhruv: bounded cursor vendor notification demo */
CREATE OR ALTER PROCEDURE OrderOps.usp_NotifyLowStockVendors
    @ThresholdQty    INT = 100,
    @MaxIterations   INT = 50,
    @DefaultLocation SMALLINT = 6,
    @ReturnCode      INT OUTPUT,
    @CorrelationID   UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProcName SYSNAME = N'OrderOps.usp_NotifyLowStockVendors';
    DECLARE @ProductID INT;
    DECLARE @EffectiveOnHand INT;
    DECLARE @ProductName NVARCHAR(100);
    DECLARE @VendorName NVARCHAR(100);
    DECLARE @IterationCount INT = 0;
    DECLARE @NotifyCount INT = 0;
    DECLARE @LoopIndex INT = 1;
    DECLARE @LoopMax INT = 0;
    DECLARE @LogMsg NVARCHAR(4000);
    DECLARE @SummaryMsg NVARCHAR(4000);

    SET @CorrelationID = NEWID();
    SET @ReturnCode = 0;

    EXEC OrderOps.usp_WriteBatchLog
        @CorrelationID = @CorrelationID,
        @ProcName = @ProcName,
        @Severity = 0,
        @Code = 'INFO',
        @Message = N'Low-stock vendor notification scan started.';

    SELECT TOP (@MaxIterations)
        RowID = IDENTITY(INT, 1, 1),
        inv.ProductID,
        inv.EffectiveOnHand,
        ProductName = p.Name,
        VendorName = CAST(N'Default Vendor' AS NVARCHAR(100))
    INTO #LowStock
    FROM OrderOps.vInventorySnapshot AS inv
    INNER JOIN OrderOps.ProductCatalog AS p
        ON p.ProductID = inv.ProductID
    WHERE inv.LocationID = @DefaultLocation
      AND inv.EffectiveOnHand > 0
      AND inv.EffectiveOnHand <= @ThresholdQty
    ORDER BY inv.EffectiveOnHand ASC, inv.ProductID;

    SELECT @LoopMax = MAX(RowID) FROM #LowStock;

    WHILE @LoopIndex <= ISNULL(@LoopMax, 0) AND @IterationCount < @MaxIterations
    BEGIN
        SELECT
            @ProductID = ProductID,
            @EffectiveOnHand = EffectiveOnHand,
            @ProductName = ProductName,
            @VendorName = VendorName
        FROM #LowStock
        WHERE RowID = @LoopIndex;

        SET @IterationCount = @IterationCount + 1;
        SET @NotifyCount = @NotifyCount + 1;

        SET @LogMsg =
            N'Reorder needed: Product ' + CAST(@ProductID AS NVARCHAR(20)) + N' (' + @ProductName
            + N') at location ' + CAST(@DefaultLocation AS NVARCHAR(10)) + N' - on-hand '
            + CAST(@EffectiveOnHand AS NVARCHAR(20)) + N'; notify vendor ' + @VendorName + N'.';

        EXEC OrderOps.usp_WriteBatchLog
            @CorrelationID = @CorrelationID,
            @ProcName = @ProcName,
            @Severity = 1,
            @Code = 'INV003',
            @Message = @LogMsg;

        SET @LoopIndex = @LoopIndex + 1;
    END;

    DROP TABLE #LowStock;

    IF @NotifyCount = 0
        SET @ReturnCode = 0;
    ELSE
        SET @ReturnCode = 1;

    SET @SummaryMsg =
        N'Low-stock scan completed. Notifications planned: ' + CAST(@NotifyCount AS NVARCHAR(20))
        + N'; iterations: ' + CAST(@IterationCount AS NVARCHAR(20)) + N' (cap '
        + CAST(@MaxIterations AS NVARCHAR(20)) + N').';

    EXEC OrderOps.usp_WriteBatchLog
        @CorrelationID = @CorrelationID,
        @ProcName = @ProcName,
        @Severity = 0,
        @Code = 'INFO',
        @Message = @SummaryMsg;

    SELECT
        NotificationsPlanned = @NotifyCount,
        IterationsUsed = @IterationCount,
        ThresholdQty = @ThresholdQty,
        DefaultLocation = @DefaultLocation;

    SELECT ReturnCode = @ReturnCode, CorrelationID = @CorrelationID;
END;
GO

/* --- Test query: low-stock vendor notification cursor --- */
DECLARE @RC INT, @CID UNIQUEIDENTIFIER;
EXEC OrderOps.usp_NotifyLowStockVendors
    @ThresholdQty = 500, @MaxIterations = 5,
    @ReturnCode = @RC OUTPUT, @CorrelationID = @CID OUTPUT;
GO