/* L5-T13 — Kelvin: notification log table (OrderOps only — no AdventureWorks dependency) */
IF OBJECT_ID(N'OrderOps.NotificationLog', N'U') IS NULL
BEGIN
    CREATE TABLE OrderOps.NotificationLog
    (
        NotificationID BIGINT IDENTITY(1, 1) NOT NULL,
        ProductID      INT                  NOT NULL,
        SpecialOfferID INT                  NULL,
        Message        NVARCHAR(500)        NOT NULL,
        LoggedAt       DATETIME2(3)         NOT NULL CONSTRAINT DF_OrderOps_NotificationLog_LoggedAt DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_OrderOps_NotificationLog PRIMARY KEY CLUSTERED (NotificationID)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM OrderOps.NotificationLog)
BEGIN
    INSERT INTO OrderOps.NotificationLog (ProductID, SpecialOfferID, Message)
    VALUES
        (908, 2, N'Promotion reminder sent for product 908.'),
        (909, 3, N'Low-stock notification queued for product 909.'),
        (910, NULL, N'Inspection complete — no promo applied.');
END;
GO

/* Compatibility view used by validation and reports */
CREATE OR ALTER VIEW OrderOps.vPromoEligibleProducts
AS
    SELECT
        pc.ProductID,
        pc.SpecialOfferID,
        pc.Description,
        pc.DiscountPct,
        pc.MinQty,
        StartDate = pc.StartDate,
        EndDate   = pc.EndDate
    FROM OrderOps.PromotionCatalog AS pc
    WHERE pc.StartDate <= '2014-05-15'
      AND '2014-05-15' <= pc.EndDate;
GO

/* --- Test query: notification log --- */
IF OBJECT_ID(N'OrderOps.NotificationLog', N'U') IS NOT NULL
    SELECT TOP 5 * FROM OrderOps.NotificationLog ORDER BY NotificationID DESC;
GO
