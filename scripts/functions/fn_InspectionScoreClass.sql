/* L4-T3 — Brian: scalar inspection score helpers */
CREATE OR ALTER FUNCTION OrderOps.fn_GetCurrencyRate
(
    @OrderDate    DATE,
    @FromCurrency CHAR(3),
    @ToCurrency   CHAR(3)
)
RETURNS DECIMAL(19, 6)
AS
BEGIN
    IF @FromCurrency = @ToCurrency
        RETURN 1.000000;

    DECLARE @Rate DECIMAL(19, 6);

    SELECT TOP (1)
        @Rate = CONVERT(DECIMAL(19, 6), cr.AverageRate)
    FROM OrderOps.CurrencyRateCatalog AS cr
    WHERE cr.FromCurrencyCode = @FromCurrency
      AND cr.ToCurrencyCode = @ToCurrency
      AND CONVERT(DATE, cr.CurrencyRateDate) <= @OrderDate
    ORDER BY cr.CurrencyRateDate DESC;

    RETURN @Rate;
END;
GO

CREATE OR ALTER FUNCTION OrderOps.fn_GetEffectiveUnitPrice
(
    @ProductID      INT,
    @OrderDate      DATE,
    @CurrencyCode   CHAR(3),
    @OrderQty       INT,
    @SpecialOfferID INT,
    @BypassPromo    BIT
)
RETURNS DECIMAL(19, 4)
AS
BEGIN
    DECLARE @ListPrice       MONEY;
    DECLARE @CurrencyRate    DECIMAL(19, 6);
    DECLARE @DiscountPct     DECIMAL(19, 4) = 0;
    DECLARE @BaseUnitPrice   DECIMAL(19, 4);
    DECLARE @EffectivePrice  DECIMAL(19, 4);

    SELECT @ListPrice = p.ListPrice
    FROM OrderOps.ProductCatalog AS p
    WHERE p.ProductID = @ProductID;

    IF @ListPrice IS NULL
        RETURN NULL;

    SET @CurrencyRate = OrderOps.fn_GetCurrencyRate(@OrderDate, 'USD', @CurrencyCode);
    IF @CurrencyRate IS NULL
        RETURN NULL;

    SET @BaseUnitPrice = CONVERT(DECIMAL(19, 4), @ListPrice * @CurrencyRate);

    IF @BypassPromo = 0 AND @SpecialOfferID IS NOT NULL
    BEGIN
        SELECT @DiscountPct = CONVERT(DECIMAL(19, 4), pc.DiscountPct)
        FROM OrderOps.PromotionCatalog AS pc
        WHERE pc.SpecialOfferID = @SpecialOfferID
          AND pc.ProductID = @ProductID
          AND pc.StartDate <= @OrderDate
          AND @OrderDate <= pc.EndDate
          AND @OrderQty >= pc.MinQty;
    END;

    SET @EffectivePrice = @BaseUnitPrice * (1.0 - ISNULL(@DiscountPct, 0));
    RETURN @EffectivePrice;
END;
GO

/* --- Test query: inspection score class UDF --- */
SELECT OrderOps.fn_GetCurrencyRate('2014-05-15', 'USD', 'EUR') AS CurrencyRate;
GO
