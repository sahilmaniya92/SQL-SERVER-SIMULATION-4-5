/* L4-T9 — Dhruv: orderable products with inventory join */
SELECT TOP 25
    op.ProductID,
    op.Name,
    op.ListPrice,
    inv.EffectiveOnHand
FROM OrderOps.vOrderableProducts AS op
INNER JOIN OrderOps.vInventorySnapshot AS inv
    ON inv.ProductID = op.ProductID
   AND inv.LocationID = 6
ORDER BY inv.EffectiveOnHand ASC;
GO

/* --- Test query: verify orderable products source --- */
SELECT OrderableCount = COUNT(*) FROM OrderOps.vOrderableProducts;
GO
