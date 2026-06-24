/* L4-T8 — Kelvin: pricing consistency board by channel from audit log */
SELECT
    Channel = 'Batch',
    ProcName,
    RunCount = COUNT(DISTINCT CorrelationID),
    ErrorRows = SUM(CASE WHEN Severity >= 2 THEN 1 ELSE 0 END)
FROM OrderOps.BatchLog
GROUP BY ProcName
ORDER BY ErrorRows DESC;
GO

/* --- Test query: verify pricing audit coverage --- */
SELECT DistinctProcs = COUNT(DISTINCT ProcName) FROM OrderOps.BatchLog;
GO
