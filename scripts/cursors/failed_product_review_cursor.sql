/* L5 support - Parth/Joshua: single-line promo/tax explanation */
/*
    OrderOps — Iteration 6
    Support explanation (single line) and low-stock vendor notification demo.
*/
CREATE OR ALTER PROCEDURE OrderOps.usp_ExplainPromoTax
    @CustomerID       INT,
    @OrderDate        DATE,
    @TerritoryID      INT,
    @CurrencyCode     CHAR(3),
    @ProductID        INT,
    @OrderQty         INT,
    @SpecialOfferID   INT = NULL,
    @BypassPromotions BIT = 0,
    @AutoBestPromo    BIT = 0,
    @StrictInventory  BIT = 0,
    @ReturnCode       INT OUTPUT,
    @CorrelationID    UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProcName SYSNAME = N'OrderOps.usp_ExplainPromoTax';
    DECLARE @DefaultLoc SMALLINT = 6;
    DECLARE @Status VARCHAR(10) = 'OK';
    DECLARE @ErrorCode VARCHAR(10) = 'INFO';
    DECLARE @MessageText NVARCHAR(4000) = N'Pricing explanation generated.';
    DECLARE @BaseUnitPrice DECIMAL(19, 4);
    DECLARE @PromotionPct DECIMAL(19, 4);
    DECLARE @EffectiveUnitPrice DECIMAL(19, 4);
    DECLARE @NetBeforeTax DECIMAL(19, 4);
    DECLARE @TaxRatePct DECIMAL(5, 2);
    DECLARE @EstimatedTax DECIMAL(19, 4);
    DECLARE @ExtendedAmount DECIMAL(19, 4);
    DECLARE @InventorySufficient BIT;
    DECLARE @PricingNote NVARCHAR(500);

    SET @CorrelationID = NEWID();
    SET @ReturnCode = 0;

    EXEC OrderOps.usp_WriteBatchLog
        @CorrelationID = @CorrelationID,
        @ProcName = @ProcName,
        @Severity = 0,
        @Code = 'INFO',
        @Message = N'Support explanation started.';

    IF NOT EXISTS (SELECT 1 FROM OrderOps.CustomerCatalog WHERE CustomerID = @CustomerID AND IsActive = 1)
    BEGIN
        SET @Status = 'ERROR'; SET @ErrorCode = 'CUST001';
        SET @MessageText = N'Customer not found or inactive.'; SET @ReturnCode = 2;
    END
    ELSE IF NOT EXISTS (
        SELECT 1 FROM OrderOps.ProductCatalog AS p
        WHERE p.ProductID = @ProductID
          AND p.SellStartDate <= @OrderDate
          AND (p.SellEndDate IS NULL OR @OrderDate <= p.SellEndDate)
          AND p.DiscontinuedDate IS NULL
          AND p.ListPrice IS NOT NULL AND p.ListPrice > 0)
    BEGIN
        SET @Status = 'ERROR'; SET @ErrorCode = 'PRD002';
        SET @MessageText = N'Product is not sellable on the order date.'; SET @ReturnCode = 2;
    END
    ELSE IF @CurrencyCode <> 'USD'
         AND OrderOps.fn_GetCurrencyRate(@OrderDate, 'USD', @CurrencyCode) IS NULL
    BEGIN
        SET @Status = 'ERROR'; SET @ErrorCode = 'CUR006';
        SET @MessageText = N'Currency rate not found for order date.'; SET @ReturnCode = 2;
    END
    ELSE IF OrderOps.fn_GetTaxRatePct(@TerritoryID, @OrderDate) IS NULL
    BEGIN
        SET @Status = 'ERROR'; SET @ErrorCode = 'TAX007';
        SET @MessageText = N'Tax rate not found for territory and order date.'; SET @ReturnCode = 2;
    END;

    IF @Status = 'OK'
       AND @BypassPromotions = 0
       AND @SpecialOfferID IS NOT NULL
       AND NOT EXISTS (
           SELECT 1 FROM OrderOps.PromotionCatalog AS pc
           WHERE pc.SpecialOfferID = @SpecialOfferID
             AND pc.ProductID = @ProductID
             AND pc.StartDate <= @OrderDate
             AND @OrderDate <= pc.EndDate
             AND @OrderQty >= pc.MinQty)
    BEGIN
        SET @Status = 'WARN'; SET @ErrorCode = 'PROM005';
        SET @MessageText = N'Promotion invalid; priced without discount.'; SET @ReturnCode = 1;
    END;

    IF @Status IN ('OK', 'WARN')
    BEGIN
        SELECT
            @BaseUnitPrice = f.BaseUnitPrice,
            @PromotionPct = f.PromotionPct,
            @EffectiveUnitPrice = f.EffectiveUnitPrice,
            @NetBeforeTax = f.NetBeforeTax,
            @TaxRatePct = f.TaxRatePct,
            @EstimatedTax = f.EstimatedTax,
            @ExtendedAmount = f.ExtendedAmount,
            @InventorySufficient = f.InventorySufficient,
            @PricingNote = f.PricingNote
        FROM OrderOps.fn_GetLineFinancialBreakdown(
            @CustomerID, @OrderDate, @TerritoryID, @CurrencyCode, @ProductID, @OrderQty,
            CASE WHEN @BypassPromotions = 1 THEN NULL ELSE @SpecialOfferID END,
            @BypassPromotions, @AutoBestPromo, @DefaultLoc) AS f;

        SELECT
            Status = @Status,
            Code = @ErrorCode,
            Message = @MessageText,
            CustomerID = @CustomerID,
            TerritoryID = @TerritoryID,
            CurrencyCode = @CurrencyCode,
            ProductID = @ProductID,
            OrderedQty = @OrderQty,
            BaseUnitPrice = @BaseUnitPrice,
            PromotionPct = @PromotionPct,
            EffectiveUnitPrice = @EffectiveUnitPrice,
            NetBeforeTax = @NetBeforeTax,
            TaxRatePct = @TaxRatePct,
            EstimatedTax = @EstimatedTax,
            ExtendedAmount = @ExtendedAmount,
            InventorySufficient = @InventorySufficient,
            PricingNote = COALESCE(
                CASE WHEN @Status = 'WARN' THEN N'Promotion specified but not eligible.' END,
                @PricingNote,
                N'Breakdown: base list price x currency rate, discount, net, tax, extended.');
    END;

    IF @Status = 'ERROR'
    BEGIN
        SELECT
            Status = @Status, Code = @ErrorCode, Message = @MessageText,
            CustomerID = @CustomerID, TerritoryID = @TerritoryID, CurrencyCode = @CurrencyCode,
            ProductID = @ProductID, OrderedQty = @OrderQty,
            BaseUnitPrice = CAST(NULL AS DECIMAL(19, 4)),
            PromotionPct = CAST(0 AS DECIMAL(19, 4)),
            EffectiveUnitPrice = CAST(NULL AS DECIMAL(19, 4)),
            NetBeforeTax = CAST(NULL AS DECIMAL(19, 4)),
            TaxRatePct = CAST(NULL AS DECIMAL(5, 2)),
            EstimatedTax = CAST(NULL AS DECIMAL(19, 4)),
            ExtendedAmount = CAST(NULL AS DECIMAL(19, 4)),
            InventorySufficient = CAST(0 AS BIT),
            PricingNote = CAST(NULL AS NVARCHAR(500));
    END;

    EXEC OrderOps.usp_WriteBatchLog
        @CorrelationID = @CorrelationID,
        @ProcName = @ProcName,
        @Severity = 0,
        @Code = 'INFO',
        @Message = N'Support explanation completed.';

    SELECT ReturnCode = @ReturnCode, CorrelationID = @CorrelationID;
END;
GO

/* --- Test query: promo/tax explanation stored procedure --- */
DECLARE @RC INT, @CID UNIQUEIDENTIFIER;
EXEC OrderOps.usp_ExplainPromoTax
    @CustomerID = 11000, @OrderDate = '2014-05-15', @TerritoryID = 1,
    @CurrencyCode = 'USD', @ProductID = 908, @OrderQty = 12, @SpecialOfferID = 2,
    @ReturnCode = @RC OUTPUT, @CorrelationID = @CID OUTPUT;
GO