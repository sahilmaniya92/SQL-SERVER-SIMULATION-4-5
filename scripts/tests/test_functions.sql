/*===============================================================
  OrderOps — Unit tests for Ops.fn_EffectiveUnitPrice & Ops.tvf_PriceBreakdown
  Reference  : Development Plan §6.1 Iteration 3 ; Technical Design Document §10.1
  Purpose    : Black-box PASS/FAIL assertions for the pricing functions (deterministic, hand-calculated expectations).
  Coverage   : fn_EffectiveUnitPrice (no promo; 10% promo) ; tvf_PriceBreakdown (USD happy path base/tax; missing-currency CUR006).
  Owner      : Brian (function unit tests / IF-ELSE assertions — analog of L5-T3 (inspection_result_classification.sql) assigned by Sahil).
===============================================================*/
USE AdventureWorks2022;
GO

-- ---- Test 1: scalar function, NO promotion, currency rate 1.0 ----
-- Expectation: price is unchanged (100 in -> 100 out). Proves the "no conversion, no discount" path.
DECLARE @v DECIMAL(19,4) = Ops.fn_EffectiveUnitPrice(100.0000, 1.0, 0.0);
-- Compare against the hand-calculated answer (Development Plan §6.1: "exact numbers for curated cases").
PRINT 'fn no-promo: ' + CASE WHEN @v = 100.0000 THEN 'PASS' ELSE 'FAIL got ' + CONVERT(VARCHAR(40), @v) END;
GO

-- ---- Test 2: scalar function with a 10% promotion ----
-- Expectation: 100 * (1 - 0.10) = 90.00.
-- Business Requirements Document §7 BR-03: "Pricing follows base -> discount -> tax; always explainable."
-- @v is re-declared because each batch (after GO) is a fresh variable scope.
DECLARE @v DECIMAL(19,4) = Ops.fn_EffectiveUnitPrice(100.0000, 1.0, 0.10);
PRINT 'fn 10%-promo: ' + CASE WHEN @v = 90.0000 THEN 'PASS' ELSE 'FAIL got ' + CONVERT(VARCHAR(40), @v) END;
GO

-- ---- Test 3: table-valued function, happy path ----
-- Product 870 (Water Bottle, ListPrice 4.99), USD, Territory 1 (seeded at 9% tax), qty 3, 2014-06-01.
-- The table variable mirrors the TVF's 8 output columns, in order, so we can INSERT its row.
DECLARE @r TABLE (BaseUnitPrice DECIMAL(19,4), PromotionPct DECIMAL(9,4), EffectiveUnitPrice DECIMAL(19,4),
                  NetBeforeTax DECIMAL(19,4), TaxRatePct DECIMAL(5,2), EstimatedTax DECIMAL(19,4),
                  ExtendedAmount DECIMAL(19,4), PricingNote NVARCHAR(200));
-- Call the TVF; the two trailing DEFAULTs mean @BypassPromotions = 0 and @CurrencyRateOverride = NULL.
-- Mappings and Formula §5.1 defines the base -> promo -> net -> tax -> extended sequence this exercises.
INSERT INTO @r
SELECT * FROM Ops.tvf_PriceBreakdown(870, 3, 1, '2014-06-01', 'USD', NULL, DEFAULT, DEFAULT);
-- Expectation: base equals the USD list price (4.99) and the tax rate is the seeded 9.00%.
DECLARE @result NVARCHAR(10);
IF EXISTS (SELECT 1 FROM @r WHERE BaseUnitPrice = 4.99 AND TaxRatePct = 9.00)
    SET @result = 'PASS';
ELSE
    SET @result = 'FAIL';
PRINT 'tvf USD base/tax: ' + @result;
-- Show the full breakdown row for visual inspection / grading.
SELECT * FROM @r;
GO

-- ---- Test 4: table-valued function, MISSING currency rate ----
-- 'ZZZ' is a bogus currency with no Sales.CurrencyRate row, so the rate cannot be resolved.
-- Technical Design Document §4.1; Mappings and Formula §5.1: a missing rate must raise the "currency rate not found" code (CUR006), not silently price at 1.0.
DECLARE @r TABLE (BaseUnitPrice DECIMAL(19,4), PromotionPct DECIMAL(9,4), EffectiveUnitPrice DECIMAL(19,4),
                  NetBeforeTax DECIMAL(19,4), TaxRatePct DECIMAL(5,2), EstimatedTax DECIMAL(19,4),
                  ExtendedAmount DECIMAL(19,4), PricingNote NVARCHAR(200));
INSERT INTO @r
SELECT * FROM Ops.tvf_PriceBreakdown(870, 3, 1, '2014-06-01', 'ZZZ', NULL, DEFAULT, DEFAULT);
-- Expectation: the PricingNote contains 'CUR006'.
DECLARE @result NVARCHAR(10);
IF EXISTS (SELECT 1 FROM @r WHERE PricingNote LIKE '%CUR006%')
    SET @result = 'PASS';
ELSE
    SET @result = 'FAIL';
PRINT 'tvf missing-currency CUR006: ' + @result;
GO
