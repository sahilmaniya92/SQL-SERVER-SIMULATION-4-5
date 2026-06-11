# Simulation 4-5 — Detailed Work Allocation
## Who Does What — One Combined Project

**Course:** SQL Server Developer  
**Project:** Production Quality Inspection Processing System  
**Database:** AdventureWorks2022  
**Schema:** ProductionOps  
**Timeline:** 14 Days (one joined simulation)  
**Team Size:** 9 Members  
**Folder:** `Simulation4-5/` — all scripts, docs, and screenshots live here  

> Simulation 4 (Advanced T-SQL Reporting) and Simulation 5 (Control Flow & Cursors) are **one connected project**, not two separate deliverables. Each member owns a **single workload** across all 14 days.

---

## Table of Contents

1. [Assignment Rules](#1-assignment-rules)
2. [Team Overview](#2-team-overview)
3. [Project Dependency Map](#3-project-dependency-map)
4. [Member Work Allocations](#4-member-work-allocations)
5. [14-Day Schedule](#5-14-day-schedule)
6. [Screenshot Ownership](#6-screenshot-ownership)
7. [Data Mapping Rules](#7-data-mapping-rules)
8. [Submission Checklist](#8-submission-checklist)

---

## 1. Assignment Rules

| Rule | Description |
|------|-------------|
| **One joined project** | Simulation 4-5 is delivered as **one GitHub repo** with one README, one deploy script, and one submission. |
| **Unique ownership** | Every task is assigned to **ONE person only**. |
| **Last task owner** | **Sahil** owns the final deployment and submission — the LAST task of the entire project. |
| **Schema rule** | All custom objects go in `ProductionOps` — never in `dbo`. |
| **Re-runnability** | Every script uses existence checks and runs twice without error. |
| **Script header** | Every script starts with `USE AdventureWorks2022; GO` |

---

## 2. Team Overview

| # | Member | Role | Tasks Owned | Scripts | Total Hrs | Student No. |
|---|--------|------|-------------|---------|-----------|-------------|
| 1 | Hassana | Schema & Foundation Lead | L4-T1, L4-T2, L5-T10 | 3 | **20** | _TBD_ |
| 2 | Sahashri | Report & Batch Developer | L4-T10, L5-T6 | 2 | **12** | _TBD_ |
| 3 | Brain | UDF & Control Flow Developer | L4-T3, L5-T3, L5-T4 | 3 | **6** | _TBD_ |
| 4 | Parth | Stored Proc & Error Handling | L4-T5, L5-T5 | 3 | **11** | _TBD_ |
| 5 | Josovo | Views & Analytics Developer | L4-T6, L4-T7, L5 support | 3 | **6** | _TBD_ |
| 6 | Lien | TVF & Table Developer | L4-T4, L5-T12 | 2 | **6** | _TBD_ |
| 7 | Kelvin | Window Reports & Notification | L4-T8, L5-T7, L5-T13 | 4 | **6** | _TBD_ |
| 8 | Dhruv | Subquery & Cursor Developer | L4-T9, L5-T11 | 2 | **11** | _TBD_ |
| 9 | Sahil | Final Deployment (**LAST**) | L4-T12–14, L5-T14 | 5+ | **11** | _TBD_ |
| | **TEAM TOTAL** | | **28 tasks** | **25 scripts** | **88** | |

**Project phases (within the same repo):**

| Phase | Days | Focus |
|-------|------|-------|
| Phase 1 — Foundation & Reporting | Days 1–5 | Schema, tables, UDFs, views, reports, stored procedures |
| Phase 2 — Control Flow & Cursors | Days 6–11 | Temp objects, error handling, queues, cursors, notifications |
| Phase 3 — Deploy & Submit | Days 12–14 | Full deploy, validation, README, screenshots, GitHub submission |

---

## 3. Project Dependency Map

```
Hassana (L4-T1 Schema)
    └── ALL team members

Hassana (L4-T2 InspectionRequests)
    ├── Parth (L4-T5 Stored Procedure)
    └── Sahashri (L4-T10 JOIN Report)

Brain (L4-T3 UDF) ──► Brain (L5-T3 IF/ELSE) — same classification logic

Lien (L4-T4 TVF)          ── after schema
Josovo (L4-T6 Views)      ── after schema  (also covers L5-T8, L5-T9)
Josovo (L4-T7 CTE)        ── after schema
Kelvin (L4-T8 Window)     ── after schema
Dhruv (L4-T9 Subquery)    ── after schema

ALL L4-T1 to L4-T10
    └── Sahil (L4-T12–14 Mid-Project Deploy) — gate before Phase 2

Hassana (L5-T10 Failed Queue) + Lien (L5-T12 Release Review)
    └── Dhruv (L5-T11 Review Cursor)
            └── Kelvin (L5-T13 Notification Cursor)

ALL scripts complete
    └── Sahil (L5-T14 Final Deploy + Submit) ◄── LAST
```

### Critical Path

```
L4-T1 → L4-T2 → L4-T5/L4-T10 → Mid Deploy (Sahil)
     → L5-T10 + L5-T12 → L5-T11 → L5-T13 → Final Deploy (Sahil) → Submit
```

### Who Blocks Whom

| If late… | Blocks… |
|----------|---------|
| Hassana (Day 1) | **Everyone** |
| Hassana (L5-T10) | Dhruv (no queue data) |
| Lien (L5-T12) | Dhruv (no insert target) |
| Dhruv (L5-T11) | Kelvin (no review records) |
| Sahil (mid deploy) | Phase 2 cannot officially start |
| Sahil (final deploy) | Professor submission |

---

## 4. Member Work Allocations

Each section below is the **complete workload** for that member across the full 14-day project.

---

### 4.1 Hassana — Schema & Foundation Lead (20 Hours)

**Role:** Creates the foundation every other script depends on.

| Day | Task | Script | Folder | Hrs |
|-----|------|--------|--------|-----|
| 1 | L4-T1 — ProductionOps schema | `initialize_productionops_schema.sql` | `scripts/setup/` | 3 |
| 1 | L4-T2 — InspectionRequests table + 10+ rows | `inspection_request_registration.sql` | `scripts/tables/` | 3 |
| 6 | L5-T10 — FailedInspectionQueue table + 10+ rows | `failed_inspection_queue.sql` | `scripts/tables/` | 14 |

**L4-T1 — Build:**
- `IF NOT EXISTS` check on `sys.schemas`, create `ProductionOps` if missing
- Validation: `SELECT name FROM sys.schemas WHERE name = 'ProductionOps'`
- Run twice without error

**L4-T2 — Build:**
- Table: InspectionRequestID (IDENTITY PK), ProductID, RequestDate, RequestedBy, InspectionType, Status
- Insert 10+ rows from `Production.Product` using mapping rules (Section 7)
- `IF OBJECT_ID(..., 'U') IS NULL` + `IF NOT EXISTS` on inserts

**L5-T10 — Build:**
- Table: QueueID (IDENTITY PK), ProductID, InspectionScore, InspectionDate, ProcessingStatus (default `Pending`)
- Insert 10+ rows with scores **below 70 only** (mapping rules in Section 7)
- Notify Dhruv when queue data is committed

**Screenshots:** Schema validation · InspectionRequests data · FailedInspectionQueue data

**Depends on:** Nothing (starts Day 1)  
**Blocks:** Entire team · Dhruv (L5-T11 needs queue data)

---

### 4.2 Sahashri — Report & Batch Developer (12 Hours)

| Day | Task | Script | Folder | Hrs |
|-----|------|--------|--------|-----|
| 3 | L4-T10 — JOIN report | `inspection_product_detail_report.sql` | `scripts/reporting/` | 5 |
| 6 | L5-T6 — Temp inspection batch | `inspection_batch_processing.sql` | `scripts/temporary_objects/` | 7 |

**L4-T10 — Build:**
- JOIN: `InspectionRequests` + `Production.Product` + `Production.ProductSubcategory`
- Explicit columns, readable aliases, logical sort (e.g. RequestDate DESC)

**L5-T6 — Build:**
- Temp table `#InspectionBatch`: ProductID, ProductName, ProductNumber, ListPrice, SafetyStockLevel
- Load where `ListPrice > 1000` OR `SafetyStockLevel < 500`
- `SELECT * FROM #InspectionBatch ORDER BY ListPrice DESC`

**Screenshots:** JOIN report output · #InspectionBatch temp table output

**Depends on:** Hassana (L4-T1, L4-T2)  
**Blocks:** Sahil (mid deploy)

---

### 4.3 Brain — UDF & Control Flow Developer (6 Hours)

| Day | Task | Script | Folder | Hrs |
|-----|------|--------|--------|-----|
| 2 | L4-T3 — Scalar UDF | `fn_InspectionScoreClass.sql` | `scripts/functions/` | 2 |
| 7 | L5-T3 — IF...ELSE classification | `inspection_result_classification.sql` | `scripts/controlflow/` | 2 |
| 7 | L5-T4 — WHILE monthly schedule | `monthly_inspection_schedule.sql` | `scripts/controlflow/` | 2 |

**L4-T3 — Build:**
- `ProductionOps.fn_InspectionScoreClass(@Score INT)` → NVARCHAR(50)
- 90–100 Approved · 70–89 Conditional Approval · below 70 Failed
- Test scores: 95, 78, 45

**L5-T3 — Build:**
- IF...ELSE using same rules as UDF; test scores 95, 78, 45
- Output: ProductID, InspectionScore, InspectionResult

**L5-T4 — Build:**
- Table variable `@InspectionSchedule` (MonthNumber, MonthName)
- WHILE loop inserts months 1–12

**Screenshots:** UDF test · IF...ELSE output · WHILE schedule (12 months)

**Depends on:** Hassana (L4-T1)  
**Blocks:** None

---

### 4.4 Parth — Stored Proc & Error Handling (11 Hours)

| Day | Task | Script | Folder | Hrs |
|-----|------|--------|--------|-----|
| 2 | L4-T5 — Inspection lookup SP | `usp_GetInspectionRequests.sql` | `scripts/procedures/` | 4 |
| 7 | L5-T5 — ErrorLog table | `error_log.sql` | `scripts/tables/` | 3 |
| 7 | L5-T5 — TRY...CATCH logging | `inspection_error_logging.sql` | `scripts/errorhandling/` | 4 |

**L4-T5 — Build:**
- `ProductionOps.usp_GetInspectionRequests @Status NVARCHAR(50)`
- `SET NOCOUNT ON`, JOIN to Product, filter by status
- Test with 2+ status values

**L5-T5 — Build:**
- `ProductionOps.ErrorLog`: ErrorLogID, ErrorDate, ErrorNumber, ErrorSeverity, ErrorState, ErrorLine, ErrorMessage
- TRY...CATCH on intentional error (`SELECT 1/0`), capture all ERROR_* functions, INSERT into ErrorLog

**Screenshots:** SP output with parameters · ErrorLog with captured error row

**Depends on:** Hassana (L4-T2 for SP; L4-T1 for error logging)  
**Blocks:** Sahil (mid deploy)

---

### 4.5 Josovo — Views & Analytics Developer (6 Hours)

| Day | Task | Script | Folder | Hrs |
|-----|------|--------|--------|-----|
| 2 | L4-T6 — Product inspection summary view | `vProductInspectionSummary.sql` | `scripts/views/` | 1 |
| 2 | L4-T6 — Pending inspections view | `vw_PendingInspections.sql` | `scripts/views/` | 1 |
| 2 | L4-T7 — CTE quality statistics | `product_quality_statistics.sql` | `scripts/reporting/` | 2 |
| 11 | L5 support — Reporting validation | Re-run views + CTE after full deploy | — | 2 |

**L4-T6 — Views:**
- `vProductInspectionSummary`: ProductID, ProductName, ProductNumber, ListPrice, SafetyStockLevel from `Production.Product`
- `vw_PendingInspections`: InspectionRequests JOIN Product WHERE Status = 'Pending'

**L4-T7 — CTE:**
- Per subcategory: ProductCount, AverageListPrice; sort by AverageListPrice DESC

> L4-T6 and L4-T7 also satisfy Lab 5 tasks L5-T8 and L5-T9 — no duplicate scripts needed.

**Phase 2 role:** Re-validate reporting components after full deploy; assist Sahil with validation queries.

**Screenshots:** vProductInspectionSummary TOP 20 · CTE quality statistics

**Depends on:** Hassana (L4-T1; L4-T2 for pending view)  
**Blocks:** None

---

### 4.6 Lien — TVF & Table Developer (6 Hours)

| Day | Task | Script | Folder | Hrs |
|-----|------|--------|--------|-----|
| 2 | L4-T4 — Table-valued function | `fn_GetProductInspectionData.sql` | `scripts/functions/` | 2 |
| 6 | L5-T12 — Product release review table | `product_release_review.sql` | `scripts/tables/` | 4 |

**L4-T4 — Build:**
- Inline TVF `fn_GetProductInspectionData(@ProductSubcategoryID INT)`
- Returns ProductID, ProductName, ListPrice, SafetyStockLevel
- Test with 2+ subcategory IDs

**L5-T12 — Build:**
- `ProductReleaseReview`: ReviewID (IDENTITY PK), ProductID, ProductName, InspectionScore, ReviewDecision, ReviewDate
- DDL only — data populated by Dhruv's cursor
- Notify Dhruv when table is ready

**Screenshots:** TVF output · ProductReleaseReview table structure

**Depends on:** Hassana (L4-T1)  
**Blocks:** Dhruv (L5-T11 needs insert target)

---

### 4.7 Kelvin — Window Reports & Notification (6 Hours)

| Day | Task | Script | Folder | Hrs |
|-----|------|--------|--------|-----|
| 3 | L4-T8 — Window ranking report | `product_ranking_report.sql` | `scripts/reporting/` | 2 |
| 7 | L5-T7 — Category table variable | `inspection_category_management.sql` | `scripts/temporary_objects/` | 2 |
| 9 | L5-T13 — NotificationLog table | `notification_log.sql` | `scripts/tables/` | 1 |
| 9 | L5-T13 — Notification cursor | `inspection_notification_cursor.sql` | `scripts/cursors/` | 3 |

**L4-T8 — Build:**
- `RANK()` or `DENSE_RANK()` OVER (PARTITION BY Subcategory ORDER BY ListPrice DESC)
- Output: SubcategoryName, ProductName, ListPrice, PriceRank

**L5-T7 — Build:**
- `@InspectionCategories` with 4 rows: Critical, High Risk, Standard, Low Risk

**L5-T13 — Build:**
- `NotificationLog`: NotificationID, ProductID, NotificationMessage, NotificationDate
- Cursor on `ProductReleaseReview` where ReviewDecision IN ('Reject', 'Rework Required')
- Reject: `Product [Name] has been rejected and must not be released.`
- Rework: `Product [Name] requires rework before release approval.`
- Must include CLOSE and DEALLOCATE

**Screenshots:** Window ranking · @InspectionCategories · NotificationLog contents

**Depends on:** Hassana (L4-T1) · Dhruv (L5-T11 for review data)  
**Blocks:** Sahil (final deploy)

---

### 4.8 Dhruv — Subquery & Cursor Developer (11 Hours)

| Day | Task | Script | Folder | Hrs |
|-----|------|--------|--------|-----|
| 3 | L4-T9 — Subquery safety stock report | `products_below_safety_stock_report.sql` | `scripts/reporting/` | 4 |
| 9 | L5-T11 — Failed product review cursor | `failed_product_review_cursor.sql` | `scripts/cursors/` | 7 |

**L4-T9 — Build:**
- Products where `SafetyStockLevel < 500` using correlated subquery or IN/EXISTS
- Columns: ProductName, ProductNumber, SafetyStockLevel, ListPrice

**L5-T11 — Build:**
- Cursor on `FailedInspectionQueue` WHERE ProcessingStatus = 'Pending'
- For each row: fetch score, get ProductName, apply decision (below 50 → Reject; 50–69 → Rework Required)
- INSERT into `ProductReleaseReview`, UPDATE queue to `Processed`, PRINT message
- Must include CLOSE and DEALLOCATE
- Notify Kelvin when review data is ready

**Screenshots:** Subquery report · Review cursor messages · ProductReleaseReview after processing

**Depends on:** Hassana (L5-T10) · Lien (L5-T12)  
**Blocks:** Kelvin (L5-T13)

---

### 4.9 Sahil — Final Deployment & Submission (**LAST**) (11 Hours)

**Role:** Owns both deployment gates and the final professor submission.

| Day | Task | Script / Deliverable | Folder | Hrs |
|-----|------|----------------------|--------|-----|
| 4 | L4-T12 — Mid-project deploy | `deploy_lab4.sql` | `scripts/deployment/` | 2 |
| 4 | L4-T13 — Lab 4 validation | `validate_lab4_results.sql` | `scripts/validation/` | 1 |
| 4 | L4-T14 — Phase 1 README section | README reporting section | `Simulation4-5/` | 1 |
| 11 | L5-T14 — Full deploy | `deploy_all.sql` | `scripts/deployment/` | 3 |
| 11 | L5-T14 — Full validation | `validate_lab5_results.sql` | `scripts/validation/` | 2 |
| 12 | L5-T14 — Final README + screenshots + QA | Complete submission package | `Simulation4-5/` | 2 |

**Mid-project deploy order (`deploy_lab4.sql`):**
```
scripts/setup/initialize_productionops_schema.sql
scripts/tables/inspection_request_registration.sql
scripts/functions/fn_InspectionScoreClass.sql
scripts/functions/fn_GetProductInspectionData.sql
scripts/procedures/usp_GetInspectionRequests.sql
scripts/views/vProductInspectionSummary.sql
scripts/views/vw_PendingInspections.sql
scripts/reporting/product_quality_statistics.sql
scripts/reporting/product_ranking_report.sql
scripts/reporting/products_below_safety_stock_report.sql
scripts/reporting/inspection_product_detail_report.sql
scripts/validation/validate_lab4_results.sql
```

**Full deploy order (`deploy_all.sql`) — Lab 4 scripts above, then:**
```
scripts/tables/failed_inspection_queue.sql
scripts/tables/error_log.sql
scripts/tables/product_release_review.sql
scripts/tables/notification_log.sql
scripts/controlflow/inspection_result_classification.sql
scripts/controlflow/monthly_inspection_schedule.sql
scripts/errorhandling/inspection_error_logging.sql
scripts/temporary_objects/inspection_batch_processing.sql
scripts/temporary_objects/inspection_category_management.sql
scripts/cursors/failed_product_review_cursor.sql
scripts/cursors/inspection_notification_cursor.sql
scripts/validation/validate_lab5_results.sql
```

**Final deliverables:**
- `README.md` with all 9 member names + student numbers
- Data Mapping section (Section 7)
- All screenshots in `screenshots/`
- Instructor added as GitHub collaborator
- Repository link submitted to professor

**Screenshots:** deploy_lab4.sql success · deploy_all.sql success

**Depends on:** ALL scripts from all 8 other members  
**Blocks:** Final submission

---

## 5. 14-Day Schedule

| Day | Phase | Hassana | Sahashri | Brain | Parth | Josovo | Lien | Kelvin | Dhruv | Sahil |
|-----|-------|---------|----------|-------|-------|--------|------|--------|-------|-------|
| **1** | Foundation | L4-T1, T2 | — | — | — | — | — | — | — | — |
| **2** | Reporting | Support | — | L4-T3 | L4-T5 | L4-T6, T7 | L4-T4 | — | — | — |
| **3** | Reporting | — | L4-T10 | — | — | — | — | L4-T8 | L4-T9 | — |
| **4** | Deploy | — | — | — | — | — | — | — | — | **Mid deploy** |
| **5** | Test | Test | Test | Test | Test | Test | Test | Test | Test | Gate check |
| **6** | Control Flow | L5-T10 | L5-T6 | — | — | — | L5-T12 | — | — | — |
| **7** | Control Flow | — | — | L5-T3, T4 | L5-T5 | — | — | L5-T7 | — | — |
| **8** | Test | — | Test | Test | Test | — | — | — | — | — |
| **9** | Cursors | Support | — | — | — | — | Support | L5-T13 | L5-T11 | — |
| **10** | Handoff | Push | Push | Push | Push | Push | Push | Push | Push | Collect |
| **11** | Deploy | — | — | — | — | Validate | — | — | — | **Final deploy** |
| **12** | Submit | Review | Review | Review | Review | Review | Review | Review | Review | **Submit** |
| **13–14** | Buffer | Fix issues | Fix | Fix | Fix | Fix | Fix | Fix | Fix | QA |

---

## 6. Screenshot Ownership

| # | Screenshot | Owner | Day |
|---|------------|-------|-----|
| 1 | Schema validation | Hassana | 1 |
| 2 | InspectionRequests data | Hassana | 1 |
| 3 | FailedInspectionQueue data | Hassana | 6 |
| 4 | JOIN report output | Sahashri | 3 |
| 5 | #InspectionBatch temp table | Sahashri | 6 |
| 6 | Scalar UDF test | Brain | 2 |
| 7 | IF...ELSE classification | Brain | 7 |
| 8 | WHILE monthly schedule | Brain | 7 |
| 9 | Stored procedure output | Parth | 2 |
| 10 | ErrorLog contents | Parth | 7 |
| 11 | vProductInspectionSummary | Josovo | 2 |
| 12 | CTE quality statistics | Josovo | 2 |
| 13 | TVF output | Lien | 2 |
| 14 | ProductReleaseReview table | Lien | 6 |
| 15 | Window function ranking | Kelvin | 3 |
| 16 | @InspectionCategories | Kelvin | 7 |
| 17 | NotificationLog contents | Kelvin | 9 |
| 18 | Subquery report | Dhruv | 3 |
| 19 | Review cursor messages | Dhruv | 9 |
| 20 | ProductReleaseReview data | Dhruv | 9 |
| 21 | deploy_lab4.sql success | Sahil | 4 |
| 22 | deploy_all.sql success | Sahil | 11 |

Sahil compiles all screenshots into `Simulation4-5/screenshots/` before Day 12 submission.

---

## 7. Data Mapping Rules

### InspectionRequests (Hassana — L4-T2)

| Target Column | Source / Rule |
|---------------|---------------|
| ProductID | `Production.Product.ProductID` |
| RequestDate | `GETDATE()` or fixed lab date |
| RequestedBy | Static value e.g. `Supervisor A` |
| InspectionType | ListPrice > 2000 → Performance; SafetyStockLevel < 500 → Safety; MakeFlag = 1 → Assembly; else Final Release |
| Status | SafetyStockLevel < 500 → Pending; ListPrice > 1000 → Scheduled; else Completed |

### FailedInspectionQueue (Hassana — L5-T10)

| Condition | InspectionScore |
|-----------|-----------------|
| ListPrice > 2000 AND SafetyStockLevel < 500 | 45 |
| ListPrice > 1000 AND SafetyStockLevel < 800 | 55 |
| SafetyStockLevel < 300 | 60 |
| Otherwise | 65 |

*Insert only where score < 70.*

### ProductReleaseReview (Dhruv — L5-T11 Cursor)

| Score | ReviewDecision |
|-------|----------------|
| Below 50 | Reject |
| 50–69 | Rework Required |

### NotificationLog (Kelvin — L5-T13 Cursor)

| ReviewDecision | NotificationMessage |
|----------------|---------------------|
| Reject | Product [Name] has been rejected and must not be released. |
| Rework Required | Product [Name] requires rework before release approval. |

---

## 8. Submission Checklist

One submission for the full Simulation 4-5 project:

- [ ] All 25 scripts execute without error
- [ ] `deploy_lab4.sql` runs green (SQLCMD Mode) — Day 4 gate
- [ ] `deploy_all.sql` runs full project green — Day 11 gate
- [ ] `validate_lab4_results.sql` and `validate_lab5_results.sql` pass
- [ ] All 22 screenshots in `Simulation4-5/screenshots/`
- [ ] `README.md` with all 9 names + student numbers + Data Mapping
- [ ] Instructor added as GitHub collaborator
- [ ] Repository link submitted to professor

---

*Unified work allocation for Simulation 4-5. Excel timeline: `TEAM_WORK_ALLOCATION.xlsx` · Full plan: `TEAM_PROJECT_PLAN.md`*
