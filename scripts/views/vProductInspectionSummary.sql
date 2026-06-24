/* L4-T6 — Joshua: product inspection summary view (OrderOps only) */
CREATE OR ALTER VIEW OrderOps.vInventorySnapshot
AS
    SELECT
        ps.ProductID,
        ps.LocationID,
        EffectiveOnHand = ps.Quantity + ISNULL(d.DeltaQtySum, 0)
    FROM OrderOps.ProductStock AS ps
    LEFT JOIN
    (
        SELECT ProductID, LocationID, DeltaQtySum = SUM(DeltaQty)
        FROM OrderOps.InventoryDelta
        GROUP BY ProductID, LocationID
    ) AS d
        ON d.ProductID = ps.ProductID
       AND d.LocationID = ps.LocationID;
GO

/* --- Test query: product inspection summary view --- */
IF OBJECT_ID(N'OrderOps.vInventorySnapshot', N'V') IS NOT NULL
    SELECT TOP 5 * FROM OrderOps.vInventorySnapshot ORDER BY ProductID, LocationID;
GO
