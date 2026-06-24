/* L5-T5 — Parth: effective-dated tax rate catalog (ErrorLog / TaxRate) */
IF OBJECT_ID(N'OrderOps.TaxRate', N'U') IS NULL
BEGIN
    CREATE TABLE OrderOps.TaxRate
    (
        TerritoryID   INT           NOT NULL,
        TaxRate       DECIMAL(5, 2) NOT NULL,
        EffectiveDate DATE          NOT NULL,
        EndDate       DATE          NULL,
        CONSTRAINT PK_OrderOps_TaxRate PRIMARY KEY CLUSTERED (TerritoryID, EffectiveDate),
        CONSTRAINT CK_OrderOps_TaxRate_Range CHECK (TaxRate BETWEEN 0.00 AND 99.99),
        CONSTRAINT CK_OrderOps_TaxRate_EndDate CHECK (EndDate IS NULL OR EndDate > EffectiveDate)
    );

    CREATE NONCLUSTERED INDEX IX_OrderOps_TaxRate_TerritoryEffective
        ON OrderOps.TaxRate (TerritoryID, EffectiveDate DESC);
END;
GO

/* --- Test query: TaxRate table --- */
IF OBJECT_ID(N'OrderOps.TaxRate', N'U') IS NOT NULL
    SELECT TOP 5 * FROM OrderOps.TaxRate ORDER BY TerritoryID, EffectiveDate;
GO
