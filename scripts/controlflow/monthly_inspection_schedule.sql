/* L4-T3 — Brian: nearest-prior territory tax rate lookup */
CREATE OR ALTER FUNCTION OrderOps.fn_GetTaxRatePct
(
    @TerritoryID INT,
    @OrderDate   DATE
)
RETURNS DECIMAL(5, 2)
AS
BEGIN
    DECLARE @TaxRate DECIMAL(5, 2);

    SELECT TOP (1)
        @TaxRate = tr.TaxRate
    FROM OrderOps.TaxRate AS tr
    WHERE tr.TerritoryID = @TerritoryID
      AND tr.EffectiveDate <= @OrderDate
      AND (tr.EndDate IS NULL OR @OrderDate <= tr.EndDate)
    ORDER BY tr.EffectiveDate DESC;

    RETURN @TaxRate;
END;
GO

/* --- Test query: tax rate UDF --- */
SELECT OrderOps.fn_GetTaxRatePct(1, '2014-05-15') AS TaxRatePct;
GO
