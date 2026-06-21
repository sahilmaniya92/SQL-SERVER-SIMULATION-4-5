/*===============================================================
  OrderOps — Table Ops.InventoryDelta
  Reference  : Mappings and Formula §3 ; Technical Design Document §3.1 ; Development Plan Iteration 1
  Purpose    : "Soft" inventory adjustments that never modify AdventureWorks core inventory tables; used to compute EffectiveOnHand.
  Derived    : EffectiveOnHand(ProductID, LocationID) = Production.ProductInventory.Quantity + SUM(Ops.InventoryDelta.DeltaQty)
  Owner      : Lien (table — analogous to L5-T12 (product_release_review.sql) assigned by the team leader).
===============================================================*/
USE AdventureWorks2022;
GO

-- Create the "soft" inventory-adjustment table but only if it doesn't already exist
-- Mappings and Formula §3; Technical Design Document §3.1; Business Requirements Document §7 BR-06: "No writes to core OLTP; all operational adjustments live adjacent to OLTP." Production.ProductInventory is never modified; deltas are recorded here and added in at read time to get EffectiveOnHand.
IF OBJECT_ID(N'Ops.InventoryDelta', N'U') IS NULL
BEGIN
    CREATE TABLE Ops.InventoryDelta
    (
        -- Surrogate primary key. Auto-incrementing; never reused.
        DeltaID    BIGINT        IDENTITY(1,1) NOT NULL,

        -- The product this adjustment is for. Must be a real AdventureWorks2022 product.
        -- Mappings and Formula §6: "Ops.InventoryDelta.ProductID must exist in Production.Product."
        ProductID  INT           NOT NULL,

        -- The stock location this adjustment is for. Must be a real AdventureWorks location.
        -- Mappings and Formula §6: "Ops.InventoryDelta.LocationID must exist in Production.Location."
        LocationID INT           NOT NULL,

        -- Signed quantity change: positive adds stock, negative removes it. Cannot be zero (a zero adjustment carries no information) enforced by the CHECK constraint below.
        -- Mappings and Formula §3: "Positive or negative count change ... Cannot be zero; use sign to indicate direction."
        DeltaQty   INT           NOT NULL,

        -- Optional free-text reason. Keep it short and never put personal data here.
        -- Mappings and Formula §3: "Keep concise; no personal data."
        Reason     NVARCHAR(100) NULL,

        -- When the row was created (UTC). Set automatically; treated as immutable (audit trail).
        -- Mappings and Formula §3: source is the "Database clock ... Immutable (audit trail)."
        CreatedAt  DATETIME2(3)  NOT NULL
            CONSTRAINT DF_InventoryDelta_CreatedAt DEFAULT (SYSUTCDATETIME()),

        -- Primary key on the surrogate id (Mappings and Formula §3 / §7).
        CONSTRAINT PK_Ops_InventoryDelta PRIMARY KEY CLUSTERED (DeltaID),

        -- The "cannot be zero" business rule, enforced as a hard constraint.
        CONSTRAINT CK_Ops_InventoryDelta_NonZero CHECK (DeltaQty <> 0)
    );
END
GO

-- Index for the most commonly read: summing deltas per product+location to compute EffectiveOnHand.
-- Mappings and Formula §3.2: EffectiveOnHand = Production.ProductInventory.Quantity + SUM(DeltaQty).
-- Mappings and Formula §7: index "(ProductID, LocationID) - Fast aggregation for effective on-hand."
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = N'IX_InventoryDelta_Product_Location'
                 AND object_id = OBJECT_ID(N'Ops.InventoryDelta'))
    CREATE INDEX IX_InventoryDelta_Product_Location
        ON Ops.InventoryDelta (ProductID, LocationID);
GO

-- Index for operational reporting on the most recent changes (newest first).
-- Mappings and Formula §7: index "(CreatedAt DESC) - Operational reporting on most recent changes."
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = N'IX_InventoryDelta_CreatedAt'
                 AND object_id = OBJECT_ID(N'Ops.InventoryDelta'))
    CREATE INDEX IX_InventoryDelta_CreatedAt
        ON Ops.InventoryDelta (CreatedAt DESC);
GO
