/* L4-T2 — Hassana: inspection request + OrderOps catalog tables */
IF OBJECT_ID(N'OrderOps.BatchLog', N'U') IS NULL
BEGIN
    CREATE TABLE OrderOps.BatchLog
    (
        BatchLogID    BIGINT IDENTITY(1, 1) NOT NULL,
        CorrelationID UNIQUEIDENTIFIER      NOT NULL,
        ProcName      SYSNAME               NOT NULL,
        StartedAt     DATETIME2(3)          NOT NULL CONSTRAINT DF_OrderOps_BatchLog_StartedAt DEFAULT (SYSUTCDATETIME()),
        EndedAt       DATETIME2(3)          NULL,
        Severity      TINYINT               NOT NULL,
        Code          VARCHAR(10)           NOT NULL,
        Message       NVARCHAR(4000)        NOT NULL,
        PayloadHash   VARBINARY(32)         NULL,
        CONSTRAINT PK_OrderOps_BatchLog PRIMARY KEY CLUSTERED (BatchLogID),
        CONSTRAINT CK_OrderOps_BatchLog_Severity CHECK (Severity BETWEEN 0 AND 3)
    );

    CREATE NONCLUSTERED INDEX IX_OrderOps_BatchLog_Correlation
        ON OrderOps.BatchLog (CorrelationID, StartedAt);

    CREATE NONCLUSTERED INDEX IX_OrderOps_BatchLog_SeverityCode
        ON OrderOps.BatchLog (Severity, Code, StartedAt DESC);
END;
GO

IF OBJECT_ID(N'OrderOps.CustomerCatalog', N'U') IS NULL
BEGIN
    CREATE TABLE OrderOps.CustomerCatalog
    (
        CustomerID INT  NOT NULL,
        IsActive   BIT  NOT NULL CONSTRAINT DF_OrderOps_CustomerCatalog_IsActive DEFAULT (1),
        CONSTRAINT PK_OrderOps_CustomerCatalog PRIMARY KEY CLUSTERED (CustomerID)
    );
END;
GO

IF OBJECT_ID(N'OrderOps.ProductCatalog', N'U') IS NULL
BEGIN
    CREATE TABLE OrderOps.ProductCatalog
    (
        ProductID        INT            NOT NULL,
        Name             NVARCHAR(100)  NOT NULL,
        ListPrice        MONEY          NOT NULL,
        SellStartDate    DATE           NOT NULL,
        SellEndDate      DATE           NULL,
        DiscontinuedDate DATE           NULL,
        CONSTRAINT PK_OrderOps_ProductCatalog PRIMARY KEY CLUSTERED (ProductID)
    );
END;
GO

IF OBJECT_ID(N'OrderOps.ProductStock', N'U') IS NULL
BEGIN
    CREATE TABLE OrderOps.ProductStock
    (
        ProductID  INT      NOT NULL,
        LocationID SMALLINT NOT NULL,
        Quantity   INT      NOT NULL,
        CONSTRAINT PK_OrderOps_ProductStock PRIMARY KEY CLUSTERED (ProductID, LocationID)
    );
END;
GO

IF OBJECT_ID(N'OrderOps.LocationCatalog', N'U') IS NULL
BEGIN
    CREATE TABLE OrderOps.LocationCatalog
    (
        LocationID SMALLINT     NOT NULL,
        Name       NVARCHAR(50) NOT NULL,
        CONSTRAINT PK_OrderOps_LocationCatalog PRIMARY KEY CLUSTERED (LocationID)
    );
END;
GO

IF OBJECT_ID(N'OrderOps.CurrencyRateCatalog', N'U') IS NULL
BEGIN
    CREATE TABLE OrderOps.CurrencyRateCatalog
    (
        FromCurrencyCode CHAR(3)        NOT NULL,
        ToCurrencyCode   CHAR(3)        NOT NULL,
        CurrencyRateDate DATE           NOT NULL,
        AverageRate      DECIMAL(19, 6) NOT NULL,
        CONSTRAINT PK_OrderOps_CurrencyRateCatalog PRIMARY KEY CLUSTERED (FromCurrencyCode, ToCurrencyCode, CurrencyRateDate)
    );
END;
GO

IF OBJECT_ID(N'OrderOps.PromotionCatalog', N'U') IS NULL
BEGIN
    CREATE TABLE OrderOps.PromotionCatalog
    (
        SpecialOfferID INT            NOT NULL,
        ProductID      INT            NOT NULL,
        Description    NVARCHAR(200)  NOT NULL,
        DiscountPct    DECIMAL(19, 4) NOT NULL,
        MinQty         INT            NOT NULL,
        StartDate      DATE           NOT NULL,
        EndDate        DATE           NOT NULL,
        CONSTRAINT PK_OrderOps_PromotionCatalog PRIMARY KEY CLUSTERED (SpecialOfferID, ProductID)
    );
END;
GO

IF NOT EXISTS (SELECT 1 FROM OrderOps.CustomerCatalog)
    INSERT INTO OrderOps.CustomerCatalog (CustomerID, IsActive) VALUES (11000, 1);

IF NOT EXISTS (SELECT 1 FROM OrderOps.ProductCatalog)
    INSERT INTO OrderOps.ProductCatalog (ProductID, Name, ListPrice, SellStartDate, SellEndDate, DiscontinuedDate)
    VALUES
        (908, N'Test Product 908', 12.50, '2010-01-01', NULL, NULL),
        (909, N'Test Product 909',  8.75, '2010-01-01', NULL, NULL),
        (910, N'Test Product 910', 15.00, '2010-01-01', NULL, NULL);

IF NOT EXISTS (SELECT 1 FROM OrderOps.ProductStock)
    INSERT INTO OrderOps.ProductStock (ProductID, LocationID, Quantity)
    VALUES
        (908, 6, 500),
        (909, 6,  80),
        (910, 6,  45);

IF NOT EXISTS (SELECT 1 FROM OrderOps.LocationCatalog)
    INSERT INTO OrderOps.LocationCatalog (LocationID, Name) VALUES (6, N'Main Warehouse');

IF NOT EXISTS (SELECT 1 FROM OrderOps.CurrencyRateCatalog)
    INSERT INTO OrderOps.CurrencyRateCatalog (FromCurrencyCode, ToCurrencyCode, CurrencyRateDate, AverageRate)
    VALUES ('USD', 'EUR', '2014-01-01', 0.750000);

IF NOT EXISTS (SELECT 1 FROM OrderOps.PromotionCatalog)
    INSERT INTO OrderOps.PromotionCatalog (SpecialOfferID, ProductID, Description, DiscountPct, MinQty, StartDate, EndDate)
    VALUES
        (2, 908, N'Spring discount', 0.10, 1, '2014-01-01', '2014-12-31'),
        (3, 909, N'Clearance promo', 0.15, 1, '2014-01-01', '2014-12-31');
GO

/* --- Test query: BatchLog table --- */
SELECT TOP 5 * FROM OrderOps.BatchLog ORDER BY BatchLogID DESC;
GO
