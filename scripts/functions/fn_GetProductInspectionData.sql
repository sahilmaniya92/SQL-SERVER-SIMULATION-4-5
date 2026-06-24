/* L4-T4 - Lien: full line financial breakdown TVF */
CREATE OR ALTER FUNCTION OrderOps.fn_GetLineFinancialBreakdown
(
    @CustomerID      INT,
    @OrderDate       DATE,
    @TerritoryID     INT,
    @CurrencyCode    CHAR(3),
    @ProductID       INT,
    @OrderQty        INT,
    @SpecialOfferID  INT,
    @BypassPromo     BIT,
    @AutoBestPromo   BIT,
    @DefaultLocation INT
)
RETURNS @Result TABLE
(
    BaseUnitPrice       DECIMAL(19, 4) NULL,
    PromotionPct        DECIMAL(19, 4) NOT NULL,
    EffectiveUnitPrice  DECIMAL(19, 4) NULL,
    NetBeforeTax        DECIMAL(19, 4) NULL,
    TaxRatePct          DECIMAL(5, 2)  NULL,
    EstimatedTax        DECIMAL(19, 4) NULL,
    ExtendedAmount      DECIMAL(19, 4) NULL,
    InventorySufficient BIT            NOT NULL,
    PricingNote         NVARCHAR(500)  NULL,
    ResolvedOfferID     INT            NULL
)
AS
BEGIN
    DECLARE @ListPrice        MONEY;
    DECLARE @CurrencyRate     DECIMAL(19, 6);
    DECLARE @DiscountPct      DECIMAL(19, 4) = 0;
    DECLARE @BaseUnitPrice    DECIMAL(19, 4);
    DECLARE @EffectivePrice   DECIMAL(19, 4);
    DECLARE @NetBeforeTax     DECIMAL(19, 4);
    DECLARE @TaxRatePct       DECIMAL(5, 2);
    DECLARE @EstimatedTax     DECIMAL(19, 4);
    DECLARE @ExtendedAmount   DECIMAL(19, 4);
    DECLARE @EffectiveOnHand  INT = 0;
    DECLARE @PricingNote      NVARCHAR(500) = N'';
    DECLARE @ResolvedOfferID  INT = @SpecialOfferID;

    SELECT @ListPrice = p.ListPrice
    FROM OrderOps.ProductCatalog AS p
    WHERE p.ProductID = @ProductID;

    IF @ListPrice IS NULL
    BEGIN
        INSERT INTO @Result
        VALUES (NULL, 0, NULL, NULL, NULL, NULL, NULL, 0, N'Base list price missing.', @ResolvedOfferID);
        RETURN;
    END;

    SET @CurrencyRate = OrderOps.fn_GetCurrencyRate(@OrderDate, 'USD', @CurrencyCode);
    IF @CurrencyRate IS NULL
    BEGIN
        INSERT INTO @Result
        VALUES (NULL, 0, NULL, NULL, NULL, NULL, NULL, 0, N'Currency conversion rate not resolved.', @ResolvedOfferID);
        RETURN;
    END;

    SET @BaseUnitPrice = CONVERT(DECIMAL(19, 4), @ListPrice * @CurrencyRate);

    IF @BypassPromo = 1
    BEGIN
        SET @PricingNote = N'Promotions bypassed by policy flag.';
    END
    ELSE IF @SpecialOfferID IS NULL AND @AutoBestPromo = 1
    BEGIN
        SELECT @DiscountPct = MAX(CONVERT(DECIMAL(19, 4), pc.DiscountPct))
        FROM OrderOps.PromotionCatalog AS pc
        WHERE pc.ProductID = @ProductID
          AND pc.StartDate <= @OrderDate
          AND @OrderDate <= pc.EndDate
          AND @OrderQty >= pc.MinQty;

        IF @DiscountPct IS NOT NULL AND @DiscountPct > 0
        BEGIN
            SELECT TOP 1 @ResolvedOfferID = pc.SpecialOfferID
            FROM OrderOps.PromotionCatalog AS pc
            WHERE pc.ProductID = @ProductID
              AND pc.StartDate <= @OrderDate
              AND @OrderDate <= pc.EndDate
              AND @OrderQty >= pc.MinQty
              AND pc.DiscountPct = @DiscountPct;

            SET @PricingNote = N'Auto-selected best eligible promotion.';
        END;
    END
    ELSE IF @SpecialOfferID IS NOT NULL
    BEGIN
        SELECT @DiscountPct = CONVERT(DECIMAL(19, 4), pc.DiscountPct)
        FROM OrderOps.PromotionCatalog AS pc
        WHERE pc.SpecialOfferID = @SpecialOfferID
          AND pc.ProductID = @ProductID
          AND pc.StartDate <= @OrderDate
          AND @OrderDate <= pc.EndDate
          AND @OrderQty >= pc.MinQty;

        IF @DiscountPct = 0
            SET @PricingNote = N'Promotion specified but not eligible; priced without discount.';
    END;

    SET @EffectivePrice = @BaseUnitPrice * (1.0 - ISNULL(@DiscountPct, 0));
    SET @NetBeforeTax = @EffectivePrice * @OrderQty;

    SET @TaxRatePct = OrderOps.fn_GetTaxRatePct(@TerritoryID, @OrderDate);

    IF @TaxRatePct IS NULL
    BEGIN
        INSERT INTO @Result
        VALUES (@BaseUnitPrice, ISNULL(@DiscountPct, 0), @EffectivePrice, @NetBeforeTax, NULL, NULL, NULL, 0, N'Tax rate not found for territory/date.', @ResolvedOfferID);
        RETURN;
    END;

    SET @EstimatedTax = @NetBeforeTax * (@TaxRatePct / 100.0);
    SET @ExtendedAmount = @NetBeforeTax + @EstimatedTax;

    SELECT @EffectiveOnHand = inv.EffectiveOnHand
    FROM OrderOps.vInventorySnapshot AS inv
    WHERE inv.ProductID = @ProductID
      AND inv.LocationID = @DefaultLocation;

    SET @EffectiveOnHand = ISNULL(@EffectiveOnHand, 0);

    INSERT INTO @Result
    (
        BaseUnitPrice, PromotionPct, EffectiveUnitPrice, NetBeforeTax,
        TaxRatePct, EstimatedTax, ExtendedAmount, InventorySufficient,
        PricingNote, ResolvedOfferID
    )
    VALUES
    (
        @BaseUnitPrice, ISNULL(@DiscountPct, 0), @EffectivePrice, @NetBeforeTax,
        @TaxRatePct, @EstimatedTax, @ExtendedAmount,
        CASE WHEN @EffectiveOnHand >= @OrderQty THEN 1 ELSE 0 END,
        NULLIF(@PricingNote, N''), @ResolvedOfferID
    );

    RETURN;
END;
GO

/* --- Test query: line financial breakdown TVF --- */
SELECT * FROM OrderOps.fn_GetLineFinancialBreakdown(
    11000, '2014-05-15', 1, 'USD', 908, 12, 2, 0, 0, 6);
GO
