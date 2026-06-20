/*===============================================================
  OrderOps — Scalar function Ops.fn_EffectiveUnitPrice
  Reference  : Technical Design Document §4.1 ; Mappings and Formula §5.1 ; Development Plan Iteration 3
  Purpose    : Deterministic effective unit price for one line, given already-resolved inputs (list price, currency rate, promo).
  Formula    : BaseUnitPrice    = ListPrice * CurrencyRate
               EffectiveUnitPrice = BaseUnitPrice * (1 - PromoPct)
  Owner      : Brian (scalar UDF — analog of L4-T3 (fn_InspectionScoreClass.sql) assigned by Sahil).
===============================================================*/

USE AdventureWorks2022;
GO

-- Create (or update) the function that calculates the effective price of a single item after applying a currency conversion and a promotional discount.
CREATE OR ALTER FUNCTION Ops.fn_EffectiveUnitPrice
(
    -- The original list price of the product (as stored in Production.Product)
    -- Technical Design Document §4.1: "Base price source: AdventureWorks list price."
    @ListPrice    DECIMAL(19,4),

    -- The currency conversion rate to use.
    -- Defaults to 1.0, which means "no conversion" (used when the order currency is already USD).
    -- Callers must supply the correct nearest-prior rate from Sales.CurrencyRate.
    -- TDD §4.1: "Currency conversion: Use the nearest prior currency rate on or before the order date for the pair of currencies."
    @CurrencyRate DECIMAL(19,8) = 1.0,

    -- The promotional discount as a decimal fraction (e.g., 0.10 = 10% off).
    -- Business Requirements Document §7 BR-02: "Promotion applies only if product is linked, within date range, and min qty met."
    -- Defaults to 0.0, meaning no promotion is applied (or it was bypassed/invalid).
    @PromoPct     DECIMAL(9,4)  = 0.0
)
RETURNS DECIMAL(19,4)   -- The calculated effective unit price.
WITH SCHEMABINDING      -- Prevents the tables this function depends on from being altered or dropped while the function exists.
                        -- Development Plan §9.1: "functions are deterministic and side‑effect free"
AS
BEGIN
    -- First, convert the list price into the order's currency.
    -- Technical Design Document §4.1: "Base unit price = list price multiplied by currency rate (or unchanged if already in the header currency)."
    -- If a currency rate isn't supplied (NULL), we assume 1.0 to avoid a NULL result.
    DECLARE @BaseUnitPrice DECIMAL(19,4) =
        @ListPrice * ISNULL(@CurrencyRate, 1.0);

    -- Now subtract the promotion discount.
    -- The formula is: base price * (1 - promotion fraction).
    -- Business Requirements Document §7 BR-03: "Pricing follows base → discount → tax; always explainable."
    -- If the promotion percentage is NULL for any reason, treat it as 0% (no discount).
    -- The final result is cast back to DECIMAL(19,4) to maintain consistent precision.
    RETURN CAST(@BaseUnitPrice * (1.0 - ISNULL(@PromoPct, 0.0)) AS DECIMAL(19,4));
END
GO
