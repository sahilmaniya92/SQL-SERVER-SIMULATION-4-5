CREATE OR ALTER PROCEDURE OrderOps.usp_BatchOrderPricingValidation
    @Headers         OrderOps.OrderHeaderTVP READONLY,
    @Lines           OrderOps.OrderLineTVP READONLY,
    @AutoBestPromo   BIT = 0,
    @StrictInventory BIT = 0,
    @ReturnCode      INT OUTPUT,
    @CorrelationID   UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProcName SYSNAME = N'OrderOps.usp_BatchOrderPricingValidation';
    SET @CorrelationID = NEWID();
    SET @ReturnCode = 2;

    INSERT INTO OrderOps.BatchLog (CorrelationID, ProcName, Severity, Code, Message)
    VALUES (@CorrelationID, @ProcName, 0, 'INFO', N'Batch order pricing validation started.');

    DECLARE @CustomerID INT, @OrderDate DATE, @TerritoryID INT, @CurrencyCode CHAR(3);

    SELECT TOP (1)
        @CustomerID = CustomerID,
        @OrderDate = OrderDate,
        @TerritoryID = TerritoryID,
        @CurrencyCode = CurrencyCode
    FROM @Headers;

    CREATE TABLE #LineResults
    (
        ProductID          INT            NOT NULL,
        OrderQty           INT            NOT NULL,
        SpecialOfferID     INT            NULL,
        EffectiveUnitPrice DECIMAL(19, 4) NULL,
        TaxRatePct         DECIMAL(5, 2)  NULL,
        Status             VARCHAR(10)    NOT NULL,
        Code               VARCHAR(10)    NOT NULL,
        Message            NVARCHAR(4000) NOT NULL
    );

    IF NOT EXISTS (SELECT 1 FROM OrderOps.CustomerCatalog WHERE CustomerID = @CustomerID AND IsActive = 1)
    BEGIN
        INSERT INTO #LineResults (ProductID, OrderQty, SpecialOfferID, Status, Code, Message)
        SELECT ProductID, OrderQty, SpecialOfferID, 'ERROR', 'CUS001', N'Customer not found or inactive.'
        FROM @Lines;
    END
    ELSE
    BEGIN
        DECLARE @ProductID INT, @OrderQty INT, @SpecialOfferID INT;
        DECLARE @ResolvedOfferID INT, @Stock INT, @Price DECIMAL(19, 4), @Tax DECIMAL(5, 2);

        DECLARE LineCursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT ProductID, OrderQty, SpecialOfferID FROM @Lines;

        OPEN LineCursor;
        FETCH NEXT FROM LineCursor INTO @ProductID, @OrderQty, @SpecialOfferID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @ResolvedOfferID = @SpecialOfferID;
            SET @Stock = NULL;

            IF @AutoBestPromo = 1
                SELECT TOP (1) @ResolvedOfferID = pc.SpecialOfferID
                FROM OrderOps.PromotionCatalog AS pc
                WHERE pc.ProductID = @ProductID
                  AND pc.StartDate <= @OrderDate
                  AND @OrderDate <= pc.EndDate
                  AND @OrderQty >= pc.MinQty
                ORDER BY pc.DiscountPct DESC;

            IF @StrictInventory = 1
                SELECT @Stock = SUM(ps.Quantity)
                FROM OrderOps.ProductStock AS ps
                WHERE ps.ProductID = @ProductID;

            IF @StrictInventory = 1 AND ISNULL(@Stock, 0) < @OrderQty
                INSERT INTO #LineResults (ProductID, OrderQty, SpecialOfferID, Status, Code, Message)
                VALUES (@ProductID, @OrderQty, @ResolvedOfferID, 'ERROR', 'INV004', N'Insufficient stock for strict inventory check.');
            ELSE
            BEGIN
                SET @Price = OrderOps.fn_GetEffectiveUnitPrice(@ProductID, @OrderDate, @CurrencyCode, @OrderQty, @ResolvedOfferID, 0);
                SET @Tax = OrderOps.fn_GetTaxRatePct(@TerritoryID, @OrderDate);

                IF @Price IS NULL
                    INSERT INTO #LineResults (ProductID, OrderQty, SpecialOfferID, Status, Code, Message)
                    VALUES (@ProductID, @OrderQty, @ResolvedOfferID, 'ERROR', 'PRC004', N'Effective price could not be resolved.');
                ELSE
                    INSERT INTO #LineResults (ProductID, OrderQty, SpecialOfferID, EffectiveUnitPrice, TaxRatePct, Status, Code, Message)
                    VALUES (@ProductID, @OrderQty, @ResolvedOfferID, @Price, @Tax, 'OK', 'INFO', N'Priced successfully.');
            END;

            FETCH NEXT FROM LineCursor INTO @ProductID, @OrderQty, @SpecialOfferID;
        END;

        CLOSE LineCursor;
        DEALLOCATE LineCursor;
    END;

    IF EXISTS (SELECT 1 FROM #LineResults WHERE Status = 'ERROR')
        SET @ReturnCode = CASE WHEN EXISTS (SELECT 1 FROM #LineResults WHERE Status = 'OK') THEN 1 ELSE 2 END;
    ELSE
        SET @ReturnCode = 0;

    INSERT INTO OrderOps.BatchLog (CorrelationID, ProcName, Severity, Code, Message)
    VALUES (@CorrelationID, @ProcName, 0, 'INFO', N'Batch order pricing validation completed.');

    SELECT ProductID, OrderQty, SpecialOfferID, EffectiveUnitPrice, TaxRatePct, Status, Code, Message FROM #LineResults;
    SELECT ReturnCode = @ReturnCode, CorrelationID = @CorrelationID;

    DROP TABLE #LineResults;
END;
GO
