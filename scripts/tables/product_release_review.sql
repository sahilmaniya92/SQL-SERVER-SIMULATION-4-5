/* L5-T12 — Lien: seed tax rates for at least three territories */
DELETE FROM OrderOps.TaxRate
WHERE TerritoryID IN (1, 2, 3, 6, 10);

INSERT INTO OrderOps.TaxRate (TerritoryID, TaxRate, EffectiveDate, EndDate)
VALUES
    (1, 8.50,  CONVERT(DATE, '2010-01-01'), CONVERT(DATE, '2014-12-31')),
    (1, 9.00,  CONVERT(DATE, '2015-01-01'), NULL),
    (2, 7.25,  CONVERT(DATE, '2010-01-01'), CONVERT(DATE, '2014-12-31')),
    (2, 7.75,  CONVERT(DATE, '2015-01-01'), NULL),
    (3, 6.50,  CONVERT(DATE, '2010-01-01'), NULL),
    (6, 13.00, CONVERT(DATE, '2010-01-01'), NULL),
    (10, 20.00, CONVERT(DATE, '2010-01-01'), NULL);
GO

/* --- Test query: seeded tax rates --- */
SELECT TOP 5 TerritoryID, TaxRate, EffectiveDate, EndDate
FROM OrderOps.TaxRate ORDER BY TerritoryID, EffectiveDate;
GO
