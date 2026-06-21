/*===============================================================
  OrderOps — Multi-statement table-valued function Ops.tvf_PriceBreakdown
  Reference  : Technical Design Document §4.1, §14 ; Mappings and Formula §5.1 ; Development Plan Iteration 3
  Purpose    : Full deterministic financial breakdown for one order line (base, promo %, effective price, net, tax rate, estimated tax, extended amount, pricing note).
  Owner      : Lien (multi-statement table-valued function — analogous to L4-T4 (fn_GetProductInspectionData.sql) assigned by the team leader).
===============================================================*/
USE AdventureWorks2022;
GO

-- Create (or update) the multi-statement table-valued function that returns the full financial breakdown for a single order line: base price, promo %, effective price, net, tax rate, estimated tax, extended amount, and a human-readable pricing note.
-- Technical Design Document §4.1 and Mappings and Formula §5.1 define this whole sequence.
CREATE OR ALTER FUNCTION Ops.tvf_PriceBreakdown
(
    -- The product being priced; used to look up its list price in Production.Product.
    @ProductID            INT,

    -- The quantity ordered; drives the net amount and the promotion's minimum-quantity test.
    -- Business Requirements Document §7 BR-02: a promotion applies only if "min qty met."
    @OrderQty             INT,

    -- The sales territory of the order; selects which tax rate applies.
    @TerritoryID          INT,

    -- The order date. Every "nearest prior" lookup (currency and tax) is anchored to this date.
    -- Technical Design Document §4.1: rates are chosen "on or before the order date."
    @OrderDate            DATE,

    -- The order's currency (3-letter ISO code, e.g. 'USD', 'CAD'); drives currency conversion.
    @CurrencyCode         CHAR(3),

    -- Optional specific promotion to apply. NULL = let the function pick the best eligible offer.
    -- Mappings and Formula §5.1: a promotion is valid only when the product is linked via
    -- Sales.SpecialOfferProduct and the order date is within the offer window.
    @SpecialOfferID       INT           = NULL,

    -- Feature flag: when 1, skip promotions entirely.
    -- Technical Design Document §5.1: "Bypass promotions (forces promotion percentage to zero)."
    @BypassPromotions     BIT           = 0,

    -- Performance shortcut: when the batch procedure has already resolved the currency rate for
    -- the whole batch, it passes it here. When NULL, this function resolves the rate itself.
    @CurrencyRateOverride DECIMAL(19,8) = NULL
)
-- Returns a one-row table with the complete, ordered breakdown.
-- Technical Design Document §14 lists exactly these financial fields for the result envelope.
RETURNS @Result TABLE
(
    BaseUnitPrice      DECIMAL(19,4) NULL,  -- list price after currency conversion
    PromotionPct       DECIMAL(9,4)  NULL,  -- discount fraction actually applied (0 if none/invalid)
    EffectiveUnitPrice DECIMAL(19,4) NULL,  -- base price after the discount
    NetBeforeTax       DECIMAL(19,4) NULL,  -- effective price * quantity
    TaxRatePct         DECIMAL(5,2)  NULL,  -- tax rate as a percentage (e.g. 9.00)
    EstimatedTax       DECIMAL(19,4) NULL,  -- net * tax% / 100
    ExtendedAmount     DECIMAL(19,4) NULL,  -- net + tax (the line total)
    PricingNote        NVARCHAR(200) NULL   -- plain-English explanation / diagnostic code
)
AS
BEGIN
    -- Working variables. @CurrencyRate and @TaxRatePct start as NULL on purpose: a NULL that
    -- survives the lookup is how we detect "rate not found" (CUR006 / TAX007).
    DECLARE @ListPrice    DECIMAL(19,4),
            @CurrencyRate DECIMAL(19,8) = NULL,
            @PromoPct     DECIMAL(9,4)  = 0.0,
            @TaxRatePct   DECIMAL(5,2)  = NULL,
            @Note         NVARCHAR(200) = N'';

    -- Step 1 - Base/list price straight from the core product table (read-only).
    -- Technical Design Document §4.1: "Base price source: AdventureWorks list price."
    SELECT @ListPrice = p.ListPrice
    FROM Production.Product AS p
    WHERE p.ProductID = @ProductID;

    -- Step 2 - Resolve the currency rate, in priority order:
    --   (a) use the override the caller already resolved, else
    --   (b) USD needs no conversion, so the rate is exactly 1.0, else
    --   (c) take the most recent Sales.CurrencyRate on or before the order date.
    -- If none set a value, @CurrencyRate stays NULL -> flagged as CUR006 below.
    -- Business Requirements Document §7 BR-04: "Currency conversion uses nearest prior rate on/before order date."
    IF @CurrencyRateOverride IS NOT NULL
        SET @CurrencyRate = @CurrencyRateOverride;
    ELSE IF @CurrencyCode = 'USD'
        SET @CurrencyRate = 1.0;
    ELSE
        SELECT TOP (1) @CurrencyRate = cr.AverageRate
        FROM Sales.CurrencyRate AS cr
        WHERE cr.FromCurrencyCode = 'USD'
          AND cr.ToCurrencyCode   = @CurrencyCode
          AND cr.CurrencyRateDate <= @OrderDate     -- "nearest prior": on or before the order date
        ORDER BY cr.CurrencyRateDate DESC;          -- newest qualifying rate wins

    -- Step 3 - Resolve the promotion discount (unless promotions are bypassed). A promotion counts
    -- only when the product is linked to the offer, the order date is inside the offer window, and
    -- the quantity meets the offer minimum. Mappings and Formula §5.1; Business Requirements Document §7 BR-02.
    -- ORDER BY DiscountPct DESC: if several offers qualify, take the best (auto-select-best-promo).
    IF @BypassPromotions = 0
        SELECT TOP (1) @PromoPct = so.DiscountPct
        FROM Sales.SpecialOffer AS so
        INNER JOIN Sales.SpecialOfferProduct AS sop
            ON sop.SpecialOfferID = so.SpecialOfferID                       -- product must be linked to the offer
        WHERE sop.ProductID = @ProductID
          AND (@SpecialOfferID IS NULL OR so.SpecialOfferID = @SpecialOfferID)  -- a specific offer, or any
          AND @OrderDate >= CAST(so.StartDate AS DATE)                     -- within the offer window...
          AND @OrderDate <= CAST(so.EndDate   AS DATE)
          AND @OrderQty  >= so.MinQty                                       -- ...and meets the minimum quantity
        ORDER BY so.DiscountPct DESC;

    -- If no eligible promotion was found, treat the discount as 0% (no discount).
    SET @PromoPct = ISNULL(@PromoPct, 0.0);

    -- Step 4 - Resolve the tax rate: the most recent Ops.TaxRate row whose window covers the order date.
    -- Mappings and Formula §2.2 / §5.1. A NULL result here means "tax rate not found" (TAX007).
    SELECT TOP (1) @TaxRatePct = t.TaxRate
    FROM Ops.TaxRate AS t
    WHERE t.TerritoryID = @TerritoryID
      AND t.EffectiveDate <= @OrderDate
      AND (t.EndDate IS NULL OR @OrderDate <= t.EndDate)                   -- open-ended or still in window
    ORDER BY t.EffectiveDate DESC;

    -- Step 5 - Build the diagnostic note. The order mirrors the validation precedence:
    -- missing price, then currency, then tax, then promotion status. Codes come from the
    -- standard error catalog (Mappings and Formula §1 / Technical Design Document §4.3).
    SET @Note =
        CASE
            WHEN @ListPrice    IS NULL THEN N'PRC004: base/list price missing'
            WHEN @CurrencyRate IS NULL THEN N'CUR006: currency rate not found'
            WHEN @TaxRatePct   IS NULL THEN N'TAX007: tax rate not found'
            WHEN @PromoPct = 0.0       THEN N'No active promotion applied'
            ELSE N'Promotion applied'
        END;

    -- Step 6 - Do the arithmetic in the required order: base -> discount -> net -> tax -> extended.
    -- Business Requirements Document §7 BR-03: "Pricing follows base -> discount -> tax; always explainable."
    -- ISNULL guards keep a missing rate from turning the whole line NULL (it still prices; the note explains it).
    DECLARE @Base DECIMAL(19,4) = @ListPrice * ISNULL(@CurrencyRate, 1.0);  -- base unit price
    DECLARE @Eff  DECIMAL(19,4) = @Base * (1.0 - @PromoPct);                -- effective unit price after discount
    DECLARE @Net  DECIMAL(19,4) = @Eff * @OrderQty;                         -- net before tax
    DECLARE @Tax  DECIMAL(19,4) = @Net * (ISNULL(@TaxRatePct, 0) / 100.0);  -- estimated tax

    -- Emit the single result row. ExtendedAmount (line total) = net + tax.
    INSERT INTO @Result
        (BaseUnitPrice, PromotionPct, EffectiveUnitPrice, NetBeforeTax,
         TaxRatePct, EstimatedTax, ExtendedAmount, PricingNote)
    VALUES
        (@Base, @PromoPct, @Eff, @Net, @TaxRatePct, @Tax, @Net + @Tax, @Note);

    RETURN;
END
GO
