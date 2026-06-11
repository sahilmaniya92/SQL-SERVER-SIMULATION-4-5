# Simulation 4-5 – Team Project Plan
## Production Quality Inspection Processing System (One Joined Project)

**Course:** SQL Server Developer  
**Project:** Simulation 4-5 (Lab 4 + Lab 5 combined)  
**Delivery Type:** Group Activity (Whole Class)  
**Timeline:** 14 Days (one joined simulation)  
**Database:** AdventureWorks2022  
**Schema:** ProductionOps  
**Repo Folder:** `Simulation4-5/`  

> Simulation 4 (Advanced T-SQL Reporting) and Simulation 5 (Control Flow & Cursors) are **one connected project** — one GitHub repo, one deploy script, one submission. Each member owns a **single workload** across all 14 days.  
> Detailed day-by-day breakdown: see `work_allocated.md` · Excel tracker: `TEAM_WORK_ALLOCATION.xlsx`

---

## 1. Team Members

| # | Name | Role | Tasks Owned | Total Hrs | Student No. |
|---|------|------|-------------|-----------|-------------|
| 1 | Hassana | Schema & Foundation Lead | L4-T1, L4-T2, L5-T10 | **20** | _TBD_ |
| 2 | Sahashri | Report & Batch Developer | L4-T10, L5-T6 | **12** | _TBD_ |
| 3 | Brain | UDF & Control Flow Developer | L4-T3, L5-T3, L5-T4 | **6** | _TBD_ |
| 4 | Parth | Stored Proc & Error Handling | L4-T5, L5-T5 | **11** | _TBD_ |
| 5 | Josovo | Views & Analytics Developer | L4-T6, L4-T7, L5 support | **6** | _TBD_ |
| 6 | Lien | TVF & Table Developer | L4-T4, L5-T12 | **6** | _TBD_ |
| 7 | Kelvin | Window Reports & Notification | L4-T8, L5-T7, L5-T13 | **6** | _TBD_ |
| 8 | Dhruv | Subquery & Cursor Developer | L4-T9, L5-T11 | **11** | _TBD_ |
| 9 | Sahil | Final Deployment (**LAST**) | L4-T12–14, L5-T14 | **11** | _TBD_ |
| | **TEAM TOTAL** | | **28 tasks · 25 scripts** | **88** | |

**Rules:** Each task is owned by **ONE person only**. Sahil owns the **LAST task** — final deploy and professor submission.

**Project phases:**

| Phase | Days | Focus |
|-------|------|-------|
| Phase 1 — Foundation & Reporting | Days 1–5 | Schema, tables, UDFs, views, reports, stored procedures, mid deploy |
| Phase 2 — Control Flow & Cursors | Days 6–11 | Temp objects, error handling, queues, cursors, notifications |
| Phase 3 — Deploy & Submit | Days 12–14 | Full deploy, validation, README, screenshots, GitHub submission |

---

## 2. Project Overview

This project builds a **Production Quality Inspection Processing System** inside AdventureWorks2022. All custom database objects live in the **ProductionOps** schema. Every script must be **re-runnable** (existence checks, no errors on second run).

| Content Area | Lab Source | What You Build |
|--------------|------------|----------------|
| Reporting foundation | Lab 4 (Sim 4) | Schema, tables, UDFs, TVFs, views, stored procedures, JOIN/CTE/window/subquery reports |
| Control flow & processing | Lab 5 (Sim 5) | IF/ELSE, WHILE, temp tables, table variables, TRY/CATCH, cursors, notifications |
| Deployment | Both | Mid deploy (Day 4) + full deploy (Day 11) + final submission (Day 12) |

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

---

## 4. Member Work Allocations (Complete 14-Day Workload)

### 4.1 Hassana — Schema & Foundation Lead (20 Hours)

| Day | Task | Script | Folder |
|-----|------|--------|--------|
| 1 | L4-T1 | `initialize_productionops_schema.sql` | `scripts/setup/` |
| 1 | L4-T2 | `inspection_request_registration.sql` | `scripts/tables/` |
| 6 | L5-T10 | `failed_inspection_queue.sql` | `scripts/tables/` |

- Create `ProductionOps` schema; build `InspectionRequests` with 10+ rows
- Build `FailedInspectionQueue` with 10+ rows (scores below 70 only)
- **Starts Day 1** · **Blocks everyone** · Notify Dhruv when queue is ready

---

### 4.2 Sahashri — Report & Batch Developer (12 Hours)

| Day | Task | Script | Folder |
|-----|------|--------|--------|
| 3 | L4-T10 | `inspection_product_detail_report.sql` | `scripts/reporting/` |
| 6 | L5-T6 | `inspection_batch_processing.sql` | `scripts/temporary_objects/` |

- Multi-table JOIN report (InspectionRequests + Product + Subcategory)
- Temp table `#InspectionBatch` for high-value / low-stock products
- **Depends on:** Hassana (L4-T1, L4-T2)

---

### 4.3 Brain — UDF & Control Flow Developer (6 Hours)

| Day | Task | Script | Folder |
|-----|------|--------|--------|
| 2 | L4-T3 | `fn_InspectionScoreClass.sql` | `scripts/functions/` |
| 7 | L5-T3 | `inspection_result_classification.sql` | `scripts/controlflow/` |
| 7 | L5-T4 | `monthly_inspection_schedule.sql` | `scripts/controlflow/` |

- Scalar UDF for score classification; IF/ELSE with same rules; WHILE loop for 12-month schedule
- **Depends on:** Hassana (L4-T1)

---

### 4.4 Parth — Stored Proc & Error Handling (11 Hours)

| Day | Task | Script | Folder |
|-----|------|--------|--------|
| 2 | L4-T5 | `usp_GetInspectionRequests.sql` | `scripts/procedures/` |
| 7 | L5-T5 | `error_log.sql` | `scripts/tables/` |
| 7 | L5-T5 | `inspection_error_logging.sql` | `scripts/errorhandling/` |

- Parameterized stored procedure filtered by status; ErrorLog table + TRY/CATCH error capture
- **Depends on:** Hassana (L4-T2 for SP)

---

### 4.5 Josovo — Views & Analytics Developer (6 Hours)

| Day | Task | Script | Folder |
|-----|------|--------|--------|
| 2 | L4-T6 | `vProductInspectionSummary.sql` + `vw_PendingInspections.sql` | `scripts/views/` |
| 2 | L4-T7 | `product_quality_statistics.sql` | `scripts/reporting/` |
| 11 | L5 support | Reporting validation after full deploy | — |

- Two views + CTE quality statistics report (also satisfies L5-T8 and L5-T9 — no duplicate scripts)
- Re-validate views and CTE after Sahil's full deploy on Day 11
- **Depends on:** Hassana (L4-T1)

---

### 4.6 Lien — TVF & Table Developer (6 Hours)

| Day | Task | Script | Folder |
|-----|------|--------|--------|
| 2 | L4-T4 | `fn_GetProductInspectionData.sql` | `scripts/functions/` |
| 6 | L5-T12 | `product_release_review.sql` | `scripts/tables/` |

- Inline table-valued function; `ProductReleaseReview` table (DDL only — Dhruv's cursor fills data)
- **Depends on:** Hassana (L4-T1) · **Blocks:** Dhruv (L5-T11)

---

### 4.7 Kelvin — Window Reports & Notification (6 Hours)

| Day | Task | Script | Folder |
|-----|------|--------|--------|
| 3 | L4-T8 | `product_ranking_report.sql` | `scripts/reporting/` |
| 7 | L5-T7 | `inspection_category_management.sql` | `scripts/temporary_objects/` |
| 9 | L5-T13 | `notification_log.sql` + `inspection_notification_cursor.sql` | `scripts/tables/` + `scripts/cursors/` |

- Window function ranking report; category table variable; notification cursor for Reject/Rework
- **Depends on:** Hassana (L4-T1); Dhruv (L5-T11)

---

### 4.8 Dhruv — Subquery & Cursor Developer (11 Hours)

| Day | Task | Script | Folder |
|-----|------|--------|--------|
| 3 | L4-T9 | `products_below_safety_stock_report.sql` | `scripts/reporting/` |
| 9 | L5-T11 | `failed_product_review_cursor.sql` | `scripts/cursors/` |

- Subquery report for low safety stock; review cursor processes failed inspection queue
- **Depends on:** Hassana (L5-T10) + Lien (L5-T12) · **Blocks:** Kelvin (L5-T13)

---

### 4.9 Sahil — Final Deployment & Submission (**LAST**) (11 Hours)

| Day | Task | Script / Deliverable | Folder |
|-----|------|----------------------|--------|
| 4 | L4-T12–14 | `deploy_lab4.sql` + `validate_lab4_results.sql` + README section | `scripts/deployment/` + `scripts/validation/` |
| 11 | L5-T14 | `deploy_all.sql` + `validate_lab5_results.sql` | `scripts/deployment/` + `scripts/validation/` |
| 12 | L5-T14 | README + screenshots + QA + GitHub submit | `Simulation4-5/` |

- **Day 4 gate:** Phase 2 cannot start until mid deploy is green
- **Day 12:** Final professor submission
- **Depends on:** ALL scripts from all 8 other members

---

## 5. 14-Day Schedule

| Day | Phase | Key Work | Exit Criteria |
|-----|-------|----------|---------------|
| **1** | Phase 1 | Hassana: L4-T1 + L4-T2 | Schema + InspectionRequests committed |
| **2** | Phase 1 | Brain, Parth, Josovo, Lien: L4-T3–T7 | UDF, SP, views, CTE, TVF done |
| **3** | Phase 1 | Kelvin, Dhruv, Sahashri: L4-T8–T10 | All reports complete |
| **4** | Phase 1 | **Sahil: L4-T12–14 mid deploy** | Mid deploy green |
| **5** | Phase 1 | All: test Phase 1 scripts | Zero errors |
| **6** | Phase 2 | Hassana, Sahashri, Lien: L5-T10, T6, T12 | Queue + batch + review table |
| **7** | Phase 2 | Brain, Parth, Kelvin: L5-T3–T5, T7 | Control flow + error logging |
| **8** | Phase 2 | All (except Sahil): test Phase 2 scripts | All pass |
| **9** | Phase 2 | Dhruv, Kelvin: L5-T11, T13 | Both cursors working |
| **10** | Phase 2 | All: push to GitHub | Repo complete |
| **11** | Phase 3 | **Sahil: L5-T14 deploy** · Josovo: L5 support | Full deploy green |
| **12** | Phase 3 | **Sahil: submit** | Link sent to professor |
| **13–14** | Buffer | Fix issues / final QA | Project complete |

---

## 6. Data Mapping Reference

### InspectionRequests (Hassana — L4-T2)

| Target Column | Source / Rule |
|---------------|---------------|
| ProductID | `Production.Product.ProductID` |
| InspectionType | ListPrice > 2000 → Performance; SafetyStockLevel < 500 → Safety; MakeFlag = 1 → Assembly; else Final Release |
| Status | SafetyStockLevel < 500 → Pending; ListPrice > 1000 → Scheduled; else Completed |

### FailedInspectionQueue (Hassana — L5-T10)

| Condition | InspectionScore |
|-----------|-----------------|
| ListPrice > 2000 AND SafetyStockLevel < 500 | 45 |
| ListPrice > 1000 AND SafetyStockLevel < 800 | 55 |
| SafetyStockLevel < 300 | 60 |
| Otherwise | 65 |

*Only insert where score < 70.*

### ProductReleaseReview (Dhruv — L5-T11 via Cursor)

| Score | ReviewDecision |
|-------|----------------|
| Below 50 | Reject |
| 50–69 | Rework Required |

### NotificationLog (Kelvin — L5-T13 via Cursor)

| ReviewDecision | NotificationMessage |
|----------------|---------------------|
| Reject | Product [Name] has been rejected and must not be released. |
| Rework Required | Product [Name] requires rework before release approval. |

---

## 7. Expected Folder Structure

```
Simulation4-5/
│
├── scripts/
│   ├── setup/
│   ├── tables/
│   ├── functions/
│   ├── procedures/
│   ├── views/
│   ├── reporting/
│   ├── controlflow/
│   ├── errorhandling/
│   ├── temporary_objects/
│   ├── cursors/
│   ├── deployment/
│   └── validation/
│
├── screenshots/
├── TEAM_PROJECT_PLAN.md
├── work_allocated.md
├── TEAM_WORK_ALLOCATION.xlsx
└── README.md
```

---

## 8. Submission Checklist

- [ ] All 25 scripts execute without errors
- [ ] `deploy_lab4.sql` runs green (SQLCMD Mode) — Day 4 gate
- [ ] `deploy_all.sql` runs full project green — Day 11 gate
- [ ] `validate_lab4_results.sql` and `validate_lab5_results.sql` pass
- [ ] All 22 screenshots in `screenshots/`
- [ ] `README.md` with all 9 names + student numbers + Data Mapping
- [ ] Instructor added as GitHub collaborator
- [ ] GitHub repository link submitted to professor

---

## 9. Task Code Reference — What Does Each Task Mean?

Task codes follow this pattern: **`L4-T#`** = Lab 4 (Simulation 4) task number · **`L5-T#`** = Lab 5 (Simulation 5) task number.  
These are the **official lab assignment task numbers** from your course. Each code maps to one specific deliverable in the project.

---

### How to Read Task Codes

| Prefix | Meaning |
|--------|---------|
| **L4** | Lab 4 — Advanced T-SQL Scripting & Reusable Reporting Components (Phase 1, Days 1–5) |
| **L5** | Lab 5 — T-SQL Control Flow & Data Structures (Phase 2, Days 6–11) |
| **T#** | Task number from the lab handout (e.g. T1 = first task, T10 = tenth task) |
| **L5 support** | Not a lab task number — Josovo's validation role after full deploy (Day 11) |

---

### Hassana — `L4-T1, L4-T2, L5-T10`

| Task Code | Full Name | What You Actually Build |
|-----------|-----------|-------------------------|
| **L4-T1** | Production Operations Schema Setup | Create the `ProductionOps` schema in AdventureWorks2022 using `IF NOT EXISTS`. This is the **first task in the entire project** — nothing else can start until this is done. |
| **L4-T2** | Inspection Request Registration Table | Create `ProductionOps.InspectionRequests` table and insert **10+ rows** from `Production.Product`. Applies data mapping rules for `InspectionType` and `Status`. Parth and Sahashri need this data for their scripts. |
| **L5-T10** | Failed Inspection Queue Table | Create `ProductionOps.FailedInspectionQueue` and insert **10+ rows** with inspection scores **below 70**. Dhruv's review cursor (L5-T11) reads from this queue. This is Hassana's largest single task (14 hours). |

---

### Sahashri — `L4-T10, L5-T6`

| Task Code | Full Name | What You Actually Build |
|-----------|-----------|-------------------------|
| **L4-T10** | Inspection Product Detail JOIN Report | A multi-table **JOIN report** combining `InspectionRequests`, `Production.Product`, and `Production.ProductSubcategory`. Must use explicit column lists and readable aliases. Requires Hassana's schema (L4-T1) and table data (L4-T2). |
| **L5-T6** | Temporary Inspection Batch Processing | A script using a **local temp table** `#InspectionBatch` loaded from `Production.Product` where `ListPrice > 1000` OR `SafetyStockLevel < 500`. Demonstrates temporary table usage for batch inspection processing. |

---

### Brain — `L4-T3, L5-T3, L5-T4`

| Task Code | Full Name | What You Actually Build |
|-----------|-----------|-------------------------|
| **L4-T3** | Scalar User-Defined Function (UDF) | `ProductionOps.fn_InspectionScoreClass(@Score INT)` — takes an inspection score and returns a text label: **Approved** (90–100), **Conditional Approval** (70–89), or **Failed** (below 70). Test with scores 95, 78, and 45. |
| **L5-T3** | IF...ELSE Result Classification | A control-flow script using **IF...ELSE** logic with the same classification rules as the UDF. Declares variables, applies conditions, and outputs ProductID + score + result. Builds on the concept from L4-T3. |
| **L5-T4** | WHILE Loop Monthly Schedule | A script using a **WHILE loop** and a **table variable** `@InspectionSchedule` to generate all 12 months of the year (MonthNumber 1–12 with month names). Demonstrates iterative control flow. |

---

### Parth — `L4-T5, L5-T5`

| Task Code | Full Name | What You Actually Build |
|-----------|-----------|-------------------------|
| **L4-T5** | Stored Procedure — Inspection Lookup | `ProductionOps.usp_GetInspectionRequests @Status NVARCHAR(50)` — a **parameterized stored procedure** that filters inspection requests by status and JOINs to `Production.Product`. Uses `SET NOCOUNT ON`. Requires L4-T2 table data. |
| **L5-T5** | Error Logging (Table + TRY/CATCH) | Two deliverables: (1) `ProductionOps.ErrorLog` **table** to store error details, and (2) a **TRY...CATCH script** that intentionally causes an error (`SELECT 1/0`), captures `ERROR_NUMBER()`, `ERROR_SEVERITY()`, `ERROR_STATE()`, `ERROR_LINE()`, `ERROR_MESSAGE()`, and inserts them into ErrorLog. |

---

### Josovo — `L4-T6, L4-T7, L5 support`

| Task Code | Full Name | What You Actually Build |
|-----------|-----------|-------------------------|
| **L4-T6** | Reusable Views (2 views) | **View 1:** `vProductInspectionSummary` — product inspection summary from `Production.Product`. **View 2:** `vw_PendingInspections` — pending inspection requests JOINed to products. Both use `CREATE OR ALTER VIEW`. |
| **L4-T7** | CTE Quality Statistics Report | A **Common Table Expression (CTE)** report that calculates per subcategory: product count and average list price, sorted by average price descending. |
| **L5 support** | Reporting Validation (not a lab task number) | After Sahil's full deploy on Day 11, **re-run** the views and CTE report to confirm they still work. Also satisfies the Lab 5 reporting requirements **L5-T8** (statistics) and **L5-T9** (view) — already built in L4-T6/L4-T7, so no new scripts needed. |

---

### Lien — `L4-T4, L5-T12`

| Task Code | Full Name | What You Actually Build |
|-----------|-----------|-------------------------|
| **L4-T4** | Table-Valued Function (TVF) | `ProductionOps.fn_GetProductInspectionData(@ProductSubcategoryID INT)` — an **inline table-valued function** returning ProductID, ProductName, ListPrice, SafetyStockLevel filtered by subcategory. Test with 2+ subcategory IDs. |
| **L5-T12** | Product Release Review Table | `ProductionOps.ProductReleaseReview` table — stores review decisions after failed inspections. **DDL only** (structure, no data). Dhruv's cursor (L5-T11) inserts rows into this table. |

---

### Kelvin — `L4-T8, L5-T7, L5-T13`

| Task Code | Full Name | What You Actually Build |
|-----------|-----------|-------------------------|
| **L4-T8** | Window Function Ranking Report | A report using **`RANK()` or `DENSE_RANK()`** window functions to rank products by `ListPrice` within each subcategory. Output: SubcategoryName, ProductName, ListPrice, PriceRank. |
| **L5-T7** | Inspection Category Table Variable | A script using a **table variable** `@InspectionCategories` with 4 predefined risk categories: Critical, High Risk, Standard, Low Risk. |
| **L5-T13** | Notification System (Table + Cursor) | Two deliverables: (1) `ProductionOps.NotificationLog` **table**, and (2) a **cursor** that reads `ProductReleaseReview` for Reject/Rework decisions and inserts notification messages. Requires Dhruv's cursor (L5-T11) to run first. Must include `CLOSE` and `DEALLOCATE`. |

---

### Dhruv — `L4-T9, L5-T11`

| Task Code | Full Name | What You Actually Build |
|-----------|-----------|-------------------------|
| **L4-T9** | Subquery Safety Stock Report | A report using a **subquery** (correlated, `IN`, or `EXISTS`) to find products where `SafetyStockLevel < 500`. Demonstrates subquery-based filtering and reporting. |
| **L5-T11** | Failed Product Review Cursor | A **cursor** that processes every row in `FailedInspectionQueue` where `ProcessingStatus = 'Pending'`. For each row: reads the score, looks up the product name, assigns a review decision (below 50 → Reject; 50–69 → Rework Required), inserts into `ProductReleaseReview`, and updates the queue to `Processed`. Requires Hassana's queue (L5-T10) and Lien's table (L5-T12). |

---

### Sahil — `L4-T12–14, L5-T14`

| Task Code | Full Name | What You Actually Build |
|-----------|-----------|-------------------------|
| **L4-T12** | Mid-Project Deployment Script | `deploy_lab4.sql` — a **SQLCMD master script** using `:r` includes to run all Phase 1 scripts in the correct order. Runs on **Day 4**. Phase 2 cannot start until this passes. |
| **L4-T13** | Phase 1 Validation Script | `validate_lab4_results.sql` — validation queries confirming schema exists, all tables/views/functions/procedures exist, and InspectionRequests has 10+ rows. |
| **L4-T14** | Phase 1 Documentation | README section for Phase 1 reporting components + compile Phase 1 screenshots. Part of the joined project README. |
| **L5-T14** | Final Deployment + Submission | Three deliverables: (1) `deploy_all.sql` — full SQLCMD deploy of **all** Lab 4 + Lab 5 scripts, (2) `validate_lab5_results.sql` — full project validation, (3) final **README** with all 9 member names, student numbers, Data Mapping, 22 screenshots, QA sign-off, and **GitHub link submitted to professor**. This is the **LAST task** of the entire project. |

---

### Tasks Covered by Other Members (No Separate Owner)

These Lab 5 task numbers appear in the course handout but are **already satisfied** by Phase 1 work — no extra scripts needed:

| Task Code | Satisfied By | Owner |
|-----------|--------------|-------|
| **L5-T2** | Same table as L4-T2 | Hassana (built in Phase 1) |
| **L5-T8** | Same report as L4-T7 (CTE statistics) | Josovo (built in Phase 1) |
| **L5-T9** | Same view as L4-T6 (product summary view) | Josovo (built in Phase 1) |

---

### Quick Task Lookup by Member

| Member | Task Codes | Count |
|--------|------------|-------|
| Hassana | L4-T1, L4-T2, L5-T10 | 3 |
| Sahashri | L4-T10, L5-T6 | 2 |
| Brain | L4-T3, L5-T3, L5-T4 | 3 |
| Parth | L4-T5, L5-T5 | 2 (L5-T5 = table + script) |
| Josovo | L4-T6, L4-T7, L5 support | 3 |
| Lien | L4-T4, L5-T12 | 2 |
| Kelvin | L4-T8, L5-T7, L5-T13 | 3 (L5-T13 = table + cursor) |
| Dhruv | L4-T9, L5-T11 | 2 |
| Sahil | L4-T12, L4-T13, L4-T14, L5-T14 | 4 task codes (multiple scripts) |

---

*Aligned with `work_allocated.md` and `TEAM_WORK_ALLOCATION.xlsx`. Replace TBD student numbers before submission.*
