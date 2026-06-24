/* L4-T10 — Sahasri: validation funnel by error code from BatchLog */
SELECT
    Code,
    Severity,
    ErrorCount = COUNT(*),
    LastSeen   = MAX(StartedAt)
FROM OrderOps.BatchLog
WHERE Code <> 'INFO'
GROUP BY Code, Severity
ORDER BY ErrorCount DESC;
GO

/* --- Test query: verify BatchLog audit rows --- */
SELECT TotalLogRows = COUNT(*) FROM OrderOps.BatchLog;
GO
