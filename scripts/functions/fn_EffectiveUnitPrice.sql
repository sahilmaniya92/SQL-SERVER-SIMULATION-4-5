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

CREATE OR ALTER FUNCTION Ops.fn_EffectiveUnitPrice
(
    @ListPrice    DECIMAL(19,4),
    @CurrencyRate DECIMAL(19,8) = 1.0,   -- 1.0 when already in header currency
    @PromoPct     DECIMAL(9,4)  = 0.0    -- fraction, e.g. 0.10 = 10%; 0 when invalid/bypassed
)
RETURNS DECIMAL(19,4)
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @BaseUnitPrice DECIMAL(19,4) =
        @ListPrice * ISNULL(@CurrencyRate, 1.0);

    RETURN CAST(@BaseUnitPrice * (1.0 - ISNULL(@PromoPct, 0.0)) AS DECIMAL(19,4));
END
GO
