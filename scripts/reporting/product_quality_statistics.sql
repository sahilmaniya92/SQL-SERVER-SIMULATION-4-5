/* L4-T7 — Joshua: inventory snapshot analytics */
SELECT
    inv.LocationID,
    ProductCount  = COUNT(*),
    TotalOnHand   = SUM(inv.EffectiveOnHand),
    LowStockCount = SUM(CASE WHEN inv.EffectiveOnHand <= 100 THEN 1 ELSE 0 END)
FROM OrderOps.vInventorySnapshot AS inv
GROUP BY inv.LocationID
ORDER BY inv.LocationID;
GO

/* --- Test query: verify inventory snapshot aggregates --- */
SELECT TotalRows = COUNT(*) FROM OrderOps.vInventorySnapshot;
GO
