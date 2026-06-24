/*
    L5-T6 — Sahashri: batch staging pattern used by usp_BatchOrderPricingValidation.
    Demonstrates #Stage temp table structure for TVP ingress.
*/
SET NOCOUNT ON;

DECLARE @Headers OrderOps.OrderHeaderTVP;
DECLARE @Lines   OrderOps.OrderLineTVP;

INSERT INTO @Headers (CustomerID, OrderDate, TerritoryID, CurrencyCode, Channel)
VALUES (11000, '2014-05-15', 1, 'USD', 'Web');

INSERT INTO @Lines (ProductID, OrderQty, SpecialOfferID)
VALUES (908, 12, 2);

CREATE TABLE #Stage
(
    RowNum         INT NOT NULL,
    CustomerID     INT NOT NULL,
    OrderDate      DATE NOT NULL,
    TerritoryID    INT NOT NULL,
    CurrencyCode   CHAR(3) NOT NULL,
    ProductID      INT NOT NULL,
    OrderQty       INT NOT NULL,
    SpecialOfferID INT NULL
);

DECLARE @CustomerID INT, @OrderDate DATE, @TerritoryID INT, @CurrencyCode CHAR(3);

SELECT TOP 1
    @CustomerID = CustomerID,
    @OrderDate = OrderDate,
    @TerritoryID = TerritoryID,
    @CurrencyCode = CurrencyCode
FROM @Headers;

INSERT INTO #Stage (RowNum, CustomerID, OrderDate, TerritoryID, CurrencyCode, ProductID, OrderQty, SpecialOfferID)
SELECT
    0,
    @CustomerID,
    @OrderDate,
    @TerritoryID,
    @CurrencyCode,
    l.ProductID,
    l.OrderQty,
    l.SpecialOfferID
FROM @Lines AS l;

DECLARE @RowCounter INT = 0;
UPDATE #Stage
SET @RowCounter = @RowCounter + 1,
    RowNum = @RowCounter;

SELECT * FROM #Stage;

/* --- Test query: verify staging row count --- */
SELECT StageRowCount = COUNT(*) FROM #Stage;
GO
