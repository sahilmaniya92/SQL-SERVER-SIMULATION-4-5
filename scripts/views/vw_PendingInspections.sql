/* L4-T6 — Joshua: pending inspections view (OrderOps only) */
CREATE OR ALTER VIEW OrderOps.vOrderableProducts
AS
    SELECT
        p.ProductID,
        p.Name,
        p.ListPrice,
        SellStartDate = p.SellStartDate,
        SellEndDate   = p.SellEndDate,
        DiscontinuedDate = p.DiscontinuedDate
    FROM OrderOps.ProductCatalog AS p
    WHERE p.SellStartDate <= '2014-05-15'
      AND (p.SellEndDate IS NULL OR '2014-05-15' <= p.SellEndDate)
      AND p.DiscontinuedDate IS NULL
      AND p.ListPrice > 0
      AND EXISTS
      (
          SELECT 1
          FROM OrderOps.vInventorySnapshot AS inv
          WHERE inv.ProductID = p.ProductID
            AND inv.LocationID = 6
            AND inv.EffectiveOnHand > 0
      );
GO

/* --- Test query: pending inspections view --- */
IF OBJECT_ID(N'OrderOps.vOrderableProducts', N'V') IS NOT NULL
    SELECT TOP 5 * FROM OrderOps.vOrderableProducts ORDER BY ProductID;
GO
