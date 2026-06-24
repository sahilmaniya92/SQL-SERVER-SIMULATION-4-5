/* L4-T1 — Hassana: OrderOps schema scaffolding */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'OrderOps')
BEGIN
    EXEC(N'CREATE SCHEMA OrderOps AUTHORIZATION dbo;');
END;
GO

IF OBJECT_ID(N'OrderOps.Config', N'U') IS NOT NULL
    DROP TABLE OrderOps.Config;
GO

IF OBJECT_ID(N'OrderOps.usp_NotifyLowStockVendors', N'P') IS NOT NULL
    DROP PROCEDURE OrderOps.usp_NotifyLowStockVendors;
GO

IF OBJECT_ID(N'OrderOps.usp_ExplainPromoTax', N'P') IS NOT NULL
    DROP PROCEDURE OrderOps.usp_ExplainPromoTax;
GO

IF TYPE_ID(N'OrderOps.ReturnTVP') IS NOT NULL
    DROP TYPE OrderOps.ReturnTVP;
GO

/* L5-T10 — Hassana: table-valued parameter contracts */
IF TYPE_ID(N'OrderOps.OrderHeaderTVP') IS NULL
BEGIN
    CREATE TYPE OrderOps.OrderHeaderTVP AS TABLE
    (
        CustomerID   INT          NOT NULL,
        OrderDate    DATE         NOT NULL,
        TerritoryID  INT          NOT NULL,
        CurrencyCode CHAR(3)      NOT NULL,
        Channel      NVARCHAR(50) NULL
    );
END;
GO

IF TYPE_ID(N'OrderOps.OrderLineTVP') IS NULL
BEGIN
    CREATE TYPE OrderOps.OrderLineTVP AS TABLE
    (
        ProductID      INT NOT NULL,
        OrderQty       INT NOT NULL,
        SpecialOfferID INT NULL
    );
END;
GO

IF TYPE_ID(N'OrderOps.InventoryAdjTVP') IS NULL
BEGIN
    CREATE TYPE OrderOps.InventoryAdjTVP AS TABLE
    (
        ProductID  INT           NOT NULL,
        LocationID SMALLINT      NOT NULL,
        DeltaQty   INT           NOT NULL,
        Reason     NVARCHAR(100) NULL
    );
END;
GO

/* --- Test query: schema validation --- */
SELECT name AS SchemaName FROM sys.schemas WHERE name = N'OrderOps';
GO
