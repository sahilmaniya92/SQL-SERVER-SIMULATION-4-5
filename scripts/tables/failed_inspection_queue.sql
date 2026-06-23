/* L5-T10 — Hassana: soft inventory adjustments (FailedInspectionQueue / InventoryDelta) */
IF OBJECT_ID(N'OrderOps.InventoryDelta', N'U') IS NULL
BEGIN
    CREATE TABLE OrderOps.InventoryDelta
    (
        DeltaID    BIGINT IDENTITY(1, 1) NOT NULL,
        ProductID  INT                   NOT NULL,
        LocationID SMALLINT              NOT NULL,
        DeltaQty   INT                   NOT NULL,
        Reason     NVARCHAR(100)         NULL,
        CreatedAt  DATETIME2(3)          NOT NULL CONSTRAINT DF_OrderOps_InventoryDelta_CreatedAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_OrderOps_InventoryDelta PRIMARY KEY CLUSTERED (DeltaID),
        CONSTRAINT CK_OrderOps_InventoryDelta_NonZero CHECK (DeltaQty <> 0)
    );

    CREATE NONCLUSTERED INDEX IX_OrderOps_InventoryDelta_ProductLocation
        ON OrderOps.InventoryDelta (ProductID, LocationID);

    CREATE NONCLUSTERED INDEX IX_OrderOps_InventoryDelta_CreatedAt
        ON OrderOps.InventoryDelta (CreatedAt DESC);
END;
GO

/* --- Test query: InventoryDelta table --- */
IF OBJECT_ID(N'OrderOps.InventoryDelta', N'U') IS NOT NULL
    SELECT TOP 5 * FROM OrderOps.InventoryDelta ORDER BY DeltaID DESC;
GO
