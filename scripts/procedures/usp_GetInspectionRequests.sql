CREATE OR ALTER PROCEDURE OrderOps.usp_BatchOrderPricingValidation
    @Headers          OrderOps.OrderHeaderTVP READONLY,
    @Lines            OrderOps.OrderLineTVP READONLY,
    @BypassPromotions BIT = 0,
    @StrictInventory  BIT = 1,
    @AutoBestPromo    BIT = 0,
    @ReturnCode       INT OUTPUT,
    @CorrelationID    UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProcName SYSNAME = N'OrderOps.usp_BatchOrderPricingValidation';
    DECLARE @DefaultLoc SMALLINT = 6;
    DECLARE @OkCount INT;
    DECLARE @WarnCount INT;
    DECLARE @ErrCount INT;
    DECLARE @HdrCustomerID INT;
    DECLARE @HdrOrderDate DATE;
    DECLARE @HdrTerritoryID INT;
    DECLARE @HdrCurrencyCode CHAR(3);
    DECLARE @StageRowCounter INT;
    DECLARE @PricingRowNum INT;
    DECLARE @MaxPricingRow INT;
    DECLARE @LineCustomerID INT;
    DECLARE @LineOrderDate DATE;
    DECLARE @LineTerritoryID INT;
    DECLARE @LineCurrencyCode CHAR(3);
    DECLARE @LineProductID INT;
    DECLARE @LineOrderQty INT;
    DECLARE @LineSpecialOfferID INT;
    DECLARE @LineBaseUnitPrice DECIMAL(19, 4);
    DECLARE @LinePromotionPct DECIMAL(19, 4);
    DECLARE @LineEffectiveUnitPrice DECIMAL(19, 4);
    DECLARE @LineNetBeforeTax DECIMAL(19, 4);
    DECLARE @LineTaxRatePct DECIMAL(5, 2);
    DECLARE @LineEstimatedTax DECIMAL(19, 4);
    DECLARE @LineExtendedAmount DECIMAL(19, 4);
    DECLARE @LineInventorySufficient BIT;
    DECLARE @LinePricingNote NVARCHAR(500);

    SET @CorrelationID = NEWID();
    SET @ReturnCode = 2;

    EXEC OrderOps.usp_WriteBatchLog
        @CorrelationID = @CorrelationID,
        @ProcName = @ProcName,
        @Severity = 0,
        @Code = 'INFO',
        @Message = N'Batch started.';

    CREATE TABLE #Stage
    (
        RowNum             INT NOT NULL,
        CustomerID         INT NOT NULL,
        OrderDate          DATE NOT NULL,
        TerritoryID        INT NOT NULL,
        CurrencyCode       CHAR(3) NOT NULL,
        ProductID          INT NOT NULL,
        OrderQty           INT NOT NULL,
        SpecialOfferID     INT NULL,
        Status             VARCHAR(10) NOT NULL DEFAULT ('OK'),
        ErrorCode          VARCHAR(10) NOT NULL DEFAULT ('INFO'),
        MessageText        NVARCHAR(4000) NOT NULL DEFAULT (N'Line validated successfully.'),
        BaseUnitPrice      DECIMAL(19, 4) NULL,
        PromotionPct       DECIMAL(19, 4) NULL,
        EffectiveUnitPrice DECIMAL(19, 4) NULL,
        NetBeforeTax       DECIMAL(19, 4) NULL,
        TaxRatePct         DECIMAL(5, 2) NULL,
        EstimatedTax       DECIMAL(19, 4) NULL,
        ExtendedAmount     DECIMAL(19, 4) NULL,
        InventorySufficient BIT NULL,
        PricingNote        NVARCHAR(500) NULL
    );

    SELECT TOP 1
        @HdrCustomerID = CustomerID,
        @HdrOrderDate = OrderDate,
        @HdrTerritoryID = TerritoryID,
        @HdrCurrencyCode = CurrencyCode
    FROM @Headers;

    INSERT INTO #Stage (RowNum, CustomerID, OrderDate, TerritoryID, CurrencyCode, ProductID, OrderQty, SpecialOfferID)
    SELECT
        0,
        @HdrCustomerID,
        @HdrOrderDate,
        @HdrTerritoryID,
        @HdrCurrencyCode,
        l.ProductID,
        l.OrderQty,
        l.SpecialOfferID
    FROM @Lines AS l;

    SET @StageRowCounter = 0;
    UPDATE #Stage
    SET @StageRowCounter = @StageRowCounter + 1,
        RowNum = @StageRowCounter;

    UPDATE s SET Status = 'ERROR', ErrorCode = 'CUST001', MessageText = N'Customer not found or inactive.'
    FROM #Stage AS s
    LEFT JOIN OrderOps.CustomerCatalog AS c ON c.CustomerID = s.CustomerID AND c.IsActive = 1
    WHERE c.CustomerID IS NULL AND s.Status = 'OK';

    UPDATE s SET Status = 'ERROR', ErrorCode = 'PRD002', MessageText = N'Product is not sellable on the order date.'
    FROM #Stage AS s
    LEFT JOIN OrderOps.ProductCatalog AS p ON p.ProductID = s.ProductID
    WHERE s.Status = 'OK'
      AND (p.ProductID IS NULL
           OR p.SellStartDate > s.OrderDate
           OR (p.SellEndDate IS NOT NULL AND s.OrderDate > p.SellEndDate)
           OR p.DiscontinuedDate IS NOT NULL
           OR p.ListPrice IS NULL OR p.ListPrice <= 0);

    UPDATE s
    SET Status = CASE WHEN s.Status = 'OK' THEN 'WARN' ELSE s.Status END,
        ErrorCode = CASE WHEN s.Status = 'OK' THEN 'PROM005' ELSE s.ErrorCode END,
        MessageText = CASE WHEN s.Status = 'OK' THEN N'Promotion invalid; priced without discount.' ELSE s.MessageText END,
        PricingNote = N'Promotion specified but not eligible.'
    FROM #Stage AS s
    WHERE s.Status IN ('OK', 'WARN')
      AND @BypassPromotions = 0
      AND s.SpecialOfferID IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM OrderOps.PromotionCatalog AS pc
          WHERE pc.SpecialOfferID = s.SpecialOfferID
            AND pc.ProductID = s.ProductID
            AND pc.StartDate <= s.OrderDate
            AND s.OrderDate <= pc.EndDate
            AND s.OrderQty >= pc.MinQty);

    UPDATE s SET Status = 'ERROR', ErrorCode = 'CUR006', MessageText = N'Currency rate not found for order date.'
    FROM #Stage AS s
    WHERE s.Status IN ('OK', 'WARN') AND s.CurrencyCode <> 'USD'
      AND OrderOps.fn_GetCurrencyRate(s.OrderDate, 'USD', s.CurrencyCode) IS NULL;

    UPDATE s SET Status = 'ERROR', ErrorCode = 'TAX007', MessageText = N'Tax rate not found for territory and order date.'
    FROM #Stage AS s
    WHERE s.Status IN ('OK', 'WARN') AND OrderOps.fn_GetTaxRatePct(s.TerritoryID, s.OrderDate) IS NULL;

    UPDATE s
    SET Status = CASE WHEN @StrictInventory = 1 THEN 'ERROR' ELSE CASE WHEN s.Status = 'OK' THEN 'WARN' ELSE s.Status END END,
        ErrorCode = CASE WHEN s.Status = 'OK' OR @StrictInventory = 1 THEN 'INV003' ELSE s.ErrorCode END,
        MessageText = CASE WHEN s.Status = 'OK' OR @StrictInventory = 1 THEN N'Insufficient inventory at selected location.' ELSE s.MessageText END,
        InventorySufficient = 0
    FROM #Stage AS s
    LEFT JOIN OrderOps.vInventorySnapshot AS inv ON inv.ProductID = s.ProductID AND inv.LocationID = @DefaultLoc
    WHERE s.Status IN ('OK', 'WARN') AND ISNULL(inv.EffectiveOnHand, 0) < s.OrderQty;

    SELECT @MaxPricingRow = MAX(RowNum) FROM #Stage;
    SET @PricingRowNum = 1;

    WHILE @PricingRowNum <= ISNULL(@MaxPricingRow, 0)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM #Stage
            WHERE RowNum = @PricingRowNum
              AND Status IN ('OK', 'WARN')
              AND ErrorCode NOT IN ('CUR006', 'TAX007', 'PRC004')
        )
        BEGIN
            SELECT
                @LineCustomerID = CustomerID,
                @LineOrderDate = OrderDate,
                @LineTerritoryID = TerritoryID,
                @LineCurrencyCode = CurrencyCode,
                @LineProductID = ProductID,
                @LineOrderQty = OrderQty,
                @LineSpecialOfferID = SpecialOfferID
            FROM #Stage
            WHERE RowNum = @PricingRowNum;

            SELECT
                @LineBaseUnitPrice = f.BaseUnitPrice,
                @LinePromotionPct = f.PromotionPct,
                @LineEffectiveUnitPrice = f.EffectiveUnitPrice,
                @LineNetBeforeTax = f.NetBeforeTax,
                @LineTaxRatePct = f.TaxRatePct,
                @LineEstimatedTax = f.EstimatedTax,
                @LineExtendedAmount = f.ExtendedAmount,
                @LineInventorySufficient = f.InventorySufficient,
                @LinePricingNote = f.PricingNote
            FROM OrderOps.fn_GetLineFinancialBreakdown(
                @LineCustomerID, @LineOrderDate, @LineTerritoryID, @LineCurrencyCode,
                @LineProductID, @LineOrderQty,
                CASE WHEN @BypassPromotions = 1 THEN NULL ELSE @LineSpecialOfferID END,
                @BypassPromotions, @AutoBestPromo, @DefaultLoc) AS f;

            UPDATE #Stage
            SET BaseUnitPrice = @LineBaseUnitPrice,
                PromotionPct = @LinePromotionPct,
                EffectiveUnitPrice = @LineEffectiveUnitPrice,
                NetBeforeTax = @LineNetBeforeTax,
                TaxRatePct = @LineTaxRatePct,
                EstimatedTax = @LineEstimatedTax,
                ExtendedAmount = @LineExtendedAmount,
                InventorySufficient = @LineInventorySufficient,
                PricingNote = COALESCE(PricingNote, @LinePricingNote)
            WHERE RowNum = @PricingRowNum;
        END;

        SET @PricingRowNum = @PricingRowNum + 1;
    END;

    UPDATE s SET InventorySufficient = 1
    FROM #Stage AS s
    WHERE s.Status = 'OK' AND s.InventorySufficient IS NULL;

    SELECT
        @OkCount = SUM(CASE WHEN Status = 'OK' THEN 1 ELSE 0 END),
        @WarnCount = SUM(CASE WHEN Status = 'WARN' THEN 1 ELSE 0 END),
        @ErrCount = SUM(CASE WHEN Status = 'ERROR' THEN 1 ELSE 0 END)
    FROM #Stage;

    SET @ReturnCode = CASE WHEN @ErrCount = 0 THEN 0 WHEN @OkCount > 0 OR @WarnCount > 0 THEN 1 ELSE 2 END;

    EXEC OrderOps.usp_WriteBatchLog
        @CorrelationID = @CorrelationID, @ProcName = @ProcName, @Severity = 0,
        @Code = 'INFO', @Message = N'Batch completed.';

    SELECT Status, Code = ErrorCode, Message = MessageText, CustomerID, TerritoryID, CurrencyCode,
           ProductID, OrderedQty = OrderQty, BaseUnitPrice, PromotionPct, EffectiveUnitPrice,
           NetBeforeTax, TaxRatePct, EstimatedTax, ExtendedAmount, InventorySufficient, PricingNote
    FROM #Stage ORDER BY RowNum;

    SELECT ReturnCode = @ReturnCode, CorrelationID = @CorrelationID;
END;
GO

/* --- Test query: batch pricing stored procedure --- */
DECLARE @RC INT, @CID UNIQUEIDENTIFIER;
DECLARE @H OrderOps.OrderHeaderTVP, @L OrderOps.OrderLineTVP;
INSERT INTO @H VALUES (11000, '2014-05-15', 1, 'USD', 'Web');
INSERT INTO @L VALUES (908, 12, 2);
EXEC OrderOps.usp_BatchOrderPricingValidation
    @Headers = @H, @Lines = @L, @StrictInventory = 0,
    @ReturnCode = @RC OUTPUT, @CorrelationID = @CID OUTPUT;
GO
