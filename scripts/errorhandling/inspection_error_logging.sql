/*
    OrderOps — shared logging helper.
*/
CREATE OR ALTER PROCEDURE OrderOps.usp_WriteBatchLog
    @CorrelationID UNIQUEIDENTIFIER,
    @ProcName      SYSNAME,
    @Severity      TINYINT,
    @Code          VARCHAR(10),
    @Message       NVARCHAR(4000),
    @PayloadHash   VARBINARY(32) = NULL,
    @EndedAt       DATETIME2(3)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO OrderOps.BatchLog
    (
        CorrelationID, ProcName, StartedAt, EndedAt,
        Severity, Code, Message, PayloadHash
    )
    VALUES
    (
        @CorrelationID, @ProcName, SYSUTCDATETIME(), @EndedAt,
        @Severity, @Code, @Message, @PayloadHash
    );
END;
GO

/* --- Test query: batch log write --- */
DECLARE @TestCID UNIQUEIDENTIFIER = NEWID();
EXEC OrderOps.usp_WriteBatchLog
    @CorrelationID = @TestCID,
    @ProcName      = N'Test',
    @Severity      = 0,
    @Code          = 'INFO',
    @Message       = N'Test log entry from orderops_error_logging.sql';
SELECT TOP 1 * FROM OrderOps.BatchLog WHERE CorrelationID = @TestCID;
GO
