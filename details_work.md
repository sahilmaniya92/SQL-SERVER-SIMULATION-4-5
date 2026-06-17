# Simulation 4-5 — What Each Person Needs To Do
## Simple Guide for Every Team Member

**GitHub Repo:** https://github.com/sahilmaniya92/SQL-SERVER-SIMULATION-4-5  
**Database:** AdventureWorks2022  
**Schema:** ProductionOps (all your objects go here — NOT in dbo)  
**Timeline:** 14 days total  

---

## Read This First (Everyone)

### What is this project?

You are building a **Production Quality Inspection System** in SQL Server.  
The project has **two parts combined into ONE submission**:

| Part | Name | What you learn | Days |
|------|------|----------------|------|
| **Simulation 4** | Lab 4 | Reports, views, functions, stored procedures | Days 1–5 |
| **Simulation 5** | Lab 5 | IF/ELSE, WHILE, temp tables, cursors, error handling | Days 6–11 |

**One GitHub repo. One final submission. Sahil submits at the end.**

### Task codes — what do L4-T1, L5-T10 mean?

| Code | Meaning |
|------|---------|
| **L4** | Lab 4 task (Simulation 4 — reporting) |
| **L5** | Lab 5 task (Simulation 5 — control flow) |
| **T1, T2, T10…** | Task number from the lab handout |

Example: **L4-T1** = Lab 4, Task 1 · **L5-T10** = Lab 5, Task 10

### Rules for every script

1. Start every file with: `USE AdventureWorks2022; GO`
2. Put all tables/views/functions in schema **`ProductionOps`**
3. Script must run **twice** without error (use `IF NOT EXISTS`, `CREATE OR ALTER`)
4. **Only edit YOUR files** — do not change a teammate's script
5. Push your file to GitHub when done

### How to push your work

```powershell
git clone https://github.com/sahilmaniya92/SQL-SERVER-SIMULATION-4-5.git
cd SQL-SERVER-SIMULATION-4-5
git checkout -b feature/YourName-task
# create your .sql file in the correct folder
git add scripts/your-folder/your-file.sql
git commit -m "L4-T1: add my script (YourName)"
git push -u origin feature/YourName-task
```

Then open a **Pull Request** on GitHub. Sahil will merge it.

---

## Quick Lookup — Find Your Name

| Name | Your Tasks | How Many Scripts | Your Days | Total Hours |
|------|------------|------------------|-----------|-------------|
| **Hassana** | L4-T1, L4-T2, L5-T10 | 3 scripts | Day 1, Day 6 | 20 hrs |
| **Sahashri** | L4-T10, L5-T6 | 2 scripts | Day 3, Day 6 | 12 hrs |
| **Brain** | L4-T3, L5-T3, L5-T4 | 3 scripts | Day 2, Day 7 | 6 hrs |
| **Parth** | L4-T5, L5-T5 | 3 scripts | Day 2, Day 7 | 11 hrs |
| **Josovo** | L4-T6, L4-T7, L5 support | 3 scripts + check | Day 2, Day 11 | 6 hrs |
| **Lien** | L4-T4, L5-T12 | 2 scripts | Day 2, Day 6 | 6 hrs |
| **Kelvin** | L4-T8, L5-T7, L5-T13 | 4 scripts | Day 3, 7, 9 | 6 hrs |
| **Dhruv** | L4-T9, L5-T11 | 2 scripts | Day 3, Day 9 | 11 hrs |
| **Sahil** | L4-T12–14, L5-T14 | Deploy + submit (**LAST**) | Day 4, 11, 12 | 11 hrs |

---

## Who Waits For Who? (Very Important)

```
DAY 1:  Hassana finishes first → then everyone else can start

DAY 2-3: Most people work on Lab 4 scripts

DAY 4:  Sahil runs mid deploy (everyone must be done Lab 4 scripts first)

DAY 6:  Hassana (failed queue) + Lien (review table) must finish
        → then Dhruv can do his cursor on Day 9

DAY 9:  Dhruv finishes cursor → then Kelvin can do notifications

DAY 11-12: Sahil runs final deploy and submits to professor
```

**If you are late, you block someone else. Message the team on Teams/WhatsApp when your part is done.**

---

---

# PERSON 1 — HASSANA

## Your role
**Foundation leader** — you build the database foundation. **Nothing starts until you finish Day 1.**

## Your tasks (3 scripts)

### Task 1 — L4-T1 (Day 1) — Create the schema
| | |
|---|---|
| **File name** | `initialize_productionops_schema.sql` |
| **Folder** | `scripts/setup/` |
| **What to do** | Create the `ProductionOps` schema if it does not exist |
| **How** | Check `sys.schemas`, use `IF NOT EXISTS`, then `CREATE SCHEMA ProductionOps` |
| **Test** | Run `SELECT name FROM sys.schemas WHERE name = 'ProductionOps'` — should return 1 row |
| **Screenshot** | Save result → upload to `screenshots/Hassana/` |

### Task 2 — L4-T2 (Day 1) — Inspection requests table
| | |
|---|---|
| **File name** | `inspection_request_registration.sql` |
| **Folder** | `scripts/tables/` |
| **What to do** | Create table `ProductionOps.InspectionRequests` and insert **at least 10 rows** from `Production.Product` |
| **Columns** | InspectionRequestID (PK), ProductID, RequestDate, RequestedBy, InspectionType, Status |
| **Data rules** | See [Data Mapping](#data-mapping-help) below for InspectionType and Status |
| **Screenshot** | Table with 10+ rows → `screenshots/Hassana/` |

### Task 3 — L5-T10 (Day 6) — Failed inspection queue
| | |
|---|---|
| **File name** | `failed_inspection_queue.sql` |
| **Folder** | `scripts/tables/` |
| **What to do** | Create table `ProductionOps.FailedInspectionQueue` and insert **10+ rows** with scores **below 70 only** |
| **Columns** | QueueID (PK), ProductID, InspectionScore, InspectionDate, ProcessingStatus (default `Pending`) |
| **Important** | When done, **tell Dhruv** — he needs this data for his cursor |
| **Screenshot** | Queue data → `screenshots/Hassana/` |

## Your checklist
- [ ] L4-T1 schema script pushed to GitHub
- [ ] L4-T2 table with 10+ rows pushed
- [ ] L5-T10 failed queue pushed
- [ ] 3 screenshots uploaded to `screenshots/Hassana/`
- [ ] Told team when Day 1 work is done

## Who you block if late
**Everyone** (Day 1) · **Dhruv** (Day 6 queue)

---

# PERSON 2 — SAHASHRI

## Your role
**Report & batch developer** — you write reports that JOIN tables and a temp table script.

## Wait for
**Hassana** to finish L4-T1 (schema) and L4-T2 (InspectionRequests table) before starting L4-T10.

## Your tasks (2 scripts)

### Task 1 — L4-T10 (Day 3) — JOIN report
| | |
|---|---|
| **File name** | `inspection_product_detail_report.sql` |
| **Folder** | `scripts/reporting/` |
| **What to do** | Write a SELECT with **JOINs** across 3 tables |
| **Tables to join** | `ProductionOps.InspectionRequests` + `Production.Product` + `Production.ProductSubcategory` |
| **Rules** | Use column names (not `SELECT *`), use clear aliases, sort by RequestDate |
| **Screenshot** | Report output → `screenshots/Sahashri/` |

### Task 2 — L5-T6 (Day 6) — Temp table batch
| | |
|---|---|
| **File name** | `inspection_batch_processing.sql` |
| **Folder** | `scripts/temporary_objects/` |
| **What to do** | Create temp table `#InspectionBatch` and load products where `ListPrice > 1000` OR `SafetyStockLevel < 500` |
| **Columns** | ProductID, ProductName, ProductNumber, ListPrice, SafetyStockLevel |
| **Show** | `SELECT * FROM #InspectionBatch ORDER BY ListPrice DESC` |
| **Screenshot** | Temp table output → `screenshots/Sahashri/` |

## Your checklist
- [ ] JOIN report script pushed
- [ ] Temp batch script pushed
- [ ] 2 screenshots in `screenshots/Sahashri/`

---

# PERSON 3 — BRAIN

## Your role
**UDF & control flow developer** — you build a scoring function (Lab 4) and IF/ELSE + WHILE scripts (Lab 5).

## Wait for
**Hassana** — L4-T1 schema (Day 1)

## Your tasks (3 scripts)

### Task 1 — L4-T3 (Day 2) — Score classification function
| | |
|---|---|
| **File name** | `fn_InspectionScoreClass.sql` |
| **Folder** | `scripts/functions/` |
| **What to do** | Create function that takes a score number and returns text label |
| **Function name** | `ProductionOps.fn_InspectionScoreClass(@Score INT)` |
| **Rules** | 90–100 → `Approved` · 70–89 → `Conditional Approval` · below 70 → `Failed` |
| **Test with** | Scores **95**, **78**, **45** |
| **Screenshot** | Test output → `screenshots/Brain/` |

### Task 2 — L5-T3 (Day 7) — IF/ELSE script
| | |
|---|---|
| **File name** | `inspection_result_classification.sql` |
| **Folder** | `scripts/controlflow/` |
| **What to do** | Same classification rules as your UDF, but using **IF...ELSE** (not a function) |
| **Test with** | Scores 95, 78, 45 |
| **Screenshot** | Output → `screenshots/Brain/` |

### Task 3 — L5-T4 (Day 7) — WHILE loop schedule
| | |
|---|---|
| **File name** | `monthly_inspection_schedule.sql` |
| **Folder** | `scripts/controlflow/` |
| **What to do** | Use a **WHILE loop** to insert months 1 through 12 into table variable `@InspectionSchedule` |
| **Columns** | MonthNumber, MonthName |
| **Screenshot** | All 12 months shown → `screenshots/Brain/` |

## Your checklist
- [ ] UDF script pushed
- [ ] IF/ELSE script pushed
- [ ] WHILE script pushed
- [ ] 3 screenshots in `screenshots/Brain/`

---

# PERSON 4 — PARTH

## Your role
**Stored procedure & error handling** — you build a parameterized stored procedure and error logging.

## Wait for
**Hassana** — L4-T2 InspectionRequests must have data (for stored procedure)

## Your tasks (3 scripts)

### Task 1 — L4-T5 (Day 2) — Stored procedure
| | |
|---|---|
| **File name** | `usp_GetInspectionRequests.sql` |
| **Folder** | `scripts/procedures/` |
| **What to do** | Create stored procedure that filters inspection requests by status |
| **Name** | `ProductionOps.usp_GetInspectionRequests @Status NVARCHAR(50)` |
| **Must have** | `SET NOCOUNT ON`, JOIN to Product table, filter by `@Status` |
| **Test** | Run with at least 2 different status values (e.g. `Pending`, `Scheduled`) |
| **Screenshot** | SP output → `screenshots/Parth/` |

### Task 2 — L5-T5 part 1 (Day 7) — Error log table
| | |
|---|---|
| **File name** | `error_log.sql` |
| **Folder** | `scripts/tables/` |
| **What to do** | Create `ProductionOps.ErrorLog` table to store error details |

### Task 3 — L5-T5 part 2 (Day 7) — TRY/CATCH script
| | |
|---|---|
| **File name** | `inspection_error_logging.sql` |
| **Folder** | `scripts/errorhandling/` |
| **What to do** | Cause an intentional error (`SELECT 1/0`), catch it with **TRY...CATCH**, save error info to ErrorLog |
| **Capture** | ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), ERROR_LINE(), ERROR_MESSAGE() |
| **Screenshot** | ErrorLog table with 1 error row → `screenshots/Parth/` |

## Your checklist
- [ ] Stored procedure pushed
- [ ] ErrorLog table pushed
- [ ] TRY/CATCH script pushed
- [ ] 2 screenshots in `screenshots/Parth/`

---

# PERSON 5 — JOSOVO

## Your role
**Views & analytics** — you create 2 views and 1 CTE report. You also check they still work after final deploy.

## Wait for
**Hassana** — L4-T1 schema · L4-T2 for the pending inspections view

## Your tasks (3 scripts + 1 check)

### Task 1 — L4-T6 view 1 (Day 2)
| | |
|---|---|
| **File name** | `vProductInspectionSummary.sql` |
| **Folder** | `scripts/views/` |
| **What to do** | View showing product info from `Production.Product` |
| **Columns** | ProductID, ProductName, ProductNumber, ListPrice, SafetyStockLevel |

### Task 2 — L4-T6 view 2 (Day 2)
| | |
|---|---|
| **File name** | `vw_PendingInspections.sql` |
| **Folder** | `scripts/views/` |
| **What to do** | View showing pending inspection requests JOINed to products |
| **Filter** | `Status = 'Pending'` |

### Task 3 — L4-T7 (Day 2) — CTE report
| | |
|---|---|
| **File name** | `product_quality_statistics.sql` |
| **Folder** | `scripts/reporting/` |
| **What to do** | CTE report: count products and average list price **per subcategory** |
| **Sort** | By AverageListPrice descending |
| **Note** | This also covers Lab 5 tasks L5-T8 and L5-T9 — **no extra scripts needed** |
| **Screenshots** | View output + CTE output → `screenshots/Josovo/` |

### Task 4 — L5 support (Day 11) — Validation only
| | |
|---|---|
| **What to do** | After Sahil runs full deploy, **re-run** your views and CTE to confirm they still work |
| **No new file** | Just test and report to Sahil if something breaks |

## Your checklist
- [ ] 2 view scripts pushed
- [ ] CTE report pushed
- [ ] 2 screenshots in `screenshots/Josovo/`
- [ ] Validated reports on Day 11

---

# PERSON 6 — LIEN

## Your role
**Table-valued function & table builder** — you build a TVF (Lab 4) and an empty review table (Lab 5).

## Wait for
**Hassana** — L4-T1 schema

## Your tasks (2 scripts)

### Task 1 — L4-T4 (Day 2) — Table-valued function
| | |
|---|---|
| **File name** | `fn_GetProductInspectionData.sql` |
| **Folder** | `scripts/functions/` |
| **What to do** | Inline TVF that returns product data filtered by subcategory ID |
| **Name** | `ProductionOps.fn_GetProductInspectionData(@ProductSubcategoryID INT)` |
| **Returns** | ProductID, ProductName, ListPrice, SafetyStockLevel |
| **Test** | Call with 2 different subcategory IDs |
| **Screenshot** | TVF output → `screenshots/Lien/` |

### Task 2 — L5-T12 (Day 6) — Release review table
| | |
|---|---|
| **File name** | `product_release_review.sql` |
| **Folder** | `scripts/tables/` |
| **What to do** | Create **empty** table `ProductionOps.ProductReleaseReview` (structure only — no data) |
| **Columns** | ReviewID (PK), ProductID, ProductName, InspectionScore, ReviewDecision, ReviewDate |
| **Important** | **Tell Dhruv** when table is ready — his cursor inserts into this table |
| **Screenshot** | Table structure → `screenshots/Lien/` |

## Your checklist
- [ ] TVF script pushed
- [ ] Review table script pushed
- [ ] 2 screenshots in `screenshots/Lien/`
- [ ] Told Dhruv when table is ready

## Who you block if late
**Dhruv** (needs your table for L5-T11 cursor)

---

# PERSON 7 — KELVIN

## Your role
**Window reports & notifications** — ranking report, category table variable, and notification cursor.

## Wait for
- **Hassana** — L4-T1 schema (for Lab 4 work)
- **Dhruv** — L5-T11 cursor must run first (for notification cursor on Day 9)

## Your tasks (4 scripts)

### Task 1 — L4-T8 (Day 3) — Window ranking report
| | |
|---|---|
| **File name** | `product_ranking_report.sql` |
| **Folder** | `scripts/reporting/` |
| **What to do** | Rank products by ListPrice within each subcategory using **RANK()** or **DENSE_RANK()** |
| **Output** | SubcategoryName, ProductName, ListPrice, PriceRank |
| **Screenshot** | Report output → `screenshots/Kelvin/` |

### Task 2 — L5-T7 (Day 7) — Category table variable
| | |
|---|---|
| **File name** | `inspection_category_management.sql` |
| **Folder** | `scripts/temporary_objects/` |
| **What to do** | Table variable `@InspectionCategories` with 4 rows: Critical, High Risk, Standard, Low Risk |
| **Screenshot** | 4 categories shown → `screenshots/Kelvin/` |

### Task 3 — L5-T13 part 1 (Day 9) — Notification log table
| | |
|---|---|
| **File name** | `notification_log.sql` |
| **Folder** | `scripts/tables/` |
| **What to do** | Create `ProductionOps.NotificationLog` table |

### Task 4 — L5-T13 part 2 (Day 9) — Notification cursor
| | |
|---|---|
| **File name** | `inspection_notification_cursor.sql` |
| **Folder** | `scripts/cursors/` |
| **What to do** | Cursor reads `ProductReleaseReview` where decision is Reject or Rework Required |
| **Insert** | Notification message into NotificationLog for each row |
| **Messages** | Reject: `Product [Name] has been rejected and must not be released.` |
| | Rework: `Product [Name] requires rework before release approval.` |
| **Must include** | `CLOSE` and `DEALLOCATE` at the end |
| **Screenshot** | NotificationLog contents → `screenshots/Kelvin/` |

## Your checklist
- [ ] Window report pushed
- [ ] Category script pushed
- [ ] Notification table + cursor pushed
- [ ] 3 screenshots in `screenshots/Kelvin/`

---

# PERSON 8 — DHRUV

## Your role
**Subquery report & review cursor** — you write a subquery report and the main processing cursor.

## Wait for
- **Hassana** — L4-T1 schema (Day 3 report)
- **Hassana** — L5-T10 failed queue (Day 9 cursor)
- **Lien** — L5-T12 ProductReleaseReview table (Day 9 cursor)

## Your tasks (2 scripts)

### Task 1 — L4-T9 (Day 3) — Subquery report
| | |
|---|---|
| **File name** | `products_below_safety_stock_report.sql` |
| **Folder** | `scripts/reporting/` |
| **What to do** | Find products where `SafetyStockLevel < 500` using a **subquery** (IN, EXISTS, or correlated) |
| **Columns** | ProductName, ProductNumber, SafetyStockLevel, ListPrice |
| **Screenshot** | Report output → `screenshots/Dhruv/` |

### Task 2 — L5-T11 (Day 9) — Failed product review cursor
| | |
|---|---|
| **File name** | `failed_product_review_cursor.sql` |
| **Folder** | `scripts/cursors/` |
| **What to do** | Process every row in `FailedInspectionQueue` where `ProcessingStatus = 'Pending'` |
| **For each row** | 1) Read score · 2) Get product name · 3) Decide: below 50 = `Reject`, 50–69 = `Rework Required` · 4) INSERT into `ProductReleaseReview` · 5) UPDATE queue to `Processed` · 6) PRINT message |
| **Must include** | `CLOSE` and `DEALLOCATE` |
| **Important** | When done, **tell Kelvin** — he needs your review data for notifications |
| **Screenshots** | Cursor messages + ProductReleaseReview data → `screenshots/Dhruv/` |

## Your checklist
- [ ] Subquery report pushed
- [ ] Review cursor pushed
- [ ] 3 screenshots in `screenshots/Dhruv/`
- [ ] Told Kelvin when cursor is done

## Who you block if late
**Kelvin** (notification cursor)

---

# PERSON 9 — SAHIL (LAST — Final Deploy & Submit)

## Your role
**Deployment lead & submission** — you run deploy scripts and submit the project to the professor. **You go LAST.**

## Wait for
**Everyone else** — all scripts must be on GitHub before you deploy.

## Your tasks

### Task 1 — L4-T12 (Day 4) — Mid deploy script
| | |
|---|---|
| **File name** | `deploy_lab4.sql` |
| **Folder** | `scripts/deployment/` |
| **What to do** | SQLCMD script that runs ALL Lab 4 scripts in order using `:r` includes |
| **Gate** | Phase 2 cannot start until this runs with zero errors |

### Task 2 — L4-T13 (Day 4) — Lab 4 validation
| | |
|---|---|
| **File name** | `validate_lab4_results.sql` |
| **Folder** | `scripts/validation/` |
| **What to do** | Queries that check schema exists, all objects exist, InspectionRequests has 10+ rows |

### Task 3 — L4-T14 (Day 4) — Phase 1 docs
| | |
|---|---|
| **What to do** | Update README with Phase 1 section |

### Task 4 — L5-T14 (Day 11) — Full deploy
| | |
|---|---|
| **File name** | `deploy_all.sql` |
| **Folder** | `scripts/deployment/` |
| **What to do** | SQLCMD script that runs **ALL** Lab 4 + Lab 5 scripts in correct order |

### Task 5 — L5-T14 (Day 11) — Full validation
| | |
|---|---|
| **File name** | `validate_lab5_results.sql` |
| **Folder** | `scripts/validation/` |

### Task 6 — Final submission (Day 12)
- Collect all **22 screenshots** from team folders into `screenshots/`
- Final **README** with all 9 names + student numbers + Data Mapping
- Add **instructor** as GitHub collaborator
- Submit **GitHub link** to professor

## Deploy order for `deploy_lab4.sql`
```
1.  scripts/setup/initialize_productionops_schema.sql
2.  scripts/tables/inspection_request_registration.sql
3.  scripts/functions/fn_InspectionScoreClass.sql
4.  scripts/functions/fn_GetProductInspectionData.sql
5.  scripts/procedures/usp_GetInspectionRequests.sql
6.  scripts/views/vProductInspectionSummary.sql
7.  scripts/views/vw_PendingInspections.sql
8.  scripts/reporting/product_quality_statistics.sql
9.  scripts/reporting/product_ranking_report.sql
10. scripts/reporting/products_below_safety_stock_report.sql
11. scripts/reporting/inspection_product_detail_report.sql
12. scripts/validation/validate_lab4_results.sql
```

## After Lab 4 scripts, add for `deploy_all.sql`
```
13. scripts/tables/failed_inspection_queue.sql
14. scripts/tables/error_log.sql
15. scripts/tables/product_release_review.sql
16. scripts/tables/notification_log.sql
17. scripts/controlflow/inspection_result_classification.sql
18. scripts/controlflow/monthly_inspection_schedule.sql
19. scripts/errorhandling/inspection_error_logging.sql
20. scripts/temporary_objects/inspection_batch_processing.sql
21. scripts/temporary_objects/inspection_category_management.sql
22. scripts/cursors/failed_product_review_cursor.sql
23. scripts/cursors/inspection_notification_cursor.sql
24. scripts/validation/validate_lab5_results.sql
```

## Your screenshots
| # | What | Folder |
|---|------|--------|
| 21 | deploy_lab4.sql success | `screenshots/Sahil/` |
| 22 | deploy_all.sql success | `screenshots/Sahil/` |

---

## 14-Day Calendar (Everyone)

| Day | What happens |
|-----|--------------|
| **1** | Hassana: schema + InspectionRequests table |
| **2** | Brain, Parth, Josovo, Lien: Lab 4 scripts |
| **3** | Sahashri, Kelvin, Dhruv: Lab 4 reports |
| **4** | **Sahil: mid deploy** (Lab 4 must be complete) |
| **5** | Everyone: test your scripts |
| **6** | Hassana, Sahashri, Lien: Lab 5 tables/temp scripts |
| **7** | Brain, Parth, Kelvin: Lab 5 control flow scripts |
| **8** | Everyone: test Lab 5 scripts |
| **9** | Dhruv: review cursor → Kelvin: notification cursor |
| **10** | Everyone: push to GitHub |
| **11** | **Sahil: final deploy** · Josovo: validate reports |
| **12** | **Sahil: submit to professor** |
| **13–14** | Buffer / fix any issues |

---

## Data Mapping Help

### InspectionRequests (Hassana — L4-T2)

When inserting rows into InspectionRequests from Production.Product:

| Column | How to fill it |
|--------|----------------|
| ProductID | From `Production.Product.ProductID` |
| RequestDate | `GETDATE()` or a fixed date |
| RequestedBy | Any name, e.g. `Supervisor A` |
| InspectionType | ListPrice > 2000 → `Performance` · SafetyStockLevel < 500 → `Safety` · MakeFlag = 1 → `Assembly` · else → `Final Release` |
| Status | SafetyStockLevel < 500 → `Pending` · ListPrice > 1000 → `Scheduled` · else → `Completed` |

### FailedInspectionQueue (Hassana — L5-T10)

Calculate score from Product, then **only insert if score is below 70**:

| Product condition | Score |
|-------------------|-------|
| ListPrice > 2000 AND SafetyStockLevel < 500 | 45 |
| ListPrice > 1000 AND SafetyStockLevel < 800 | 55 |
| SafetyStockLevel < 300 | 60 |
| Otherwise | 65 |

### ProductReleaseReview (Dhruv — L5-T11 cursor)

| Inspection Score | ReviewDecision |
|------------------|----------------|
| Below 50 | `Reject` |
| 50 to 69 | `Rework Required` |

---

## Screenshot List (All 22)

| # | Owner | What to capture |
|---|-------|-----------------|
| 1 | Hassana | Schema validation query |
| 2 | Hassana | InspectionRequests table data |
| 3 | Hassana | FailedInspectionQueue data |
| 4 | Sahashri | JOIN report output |
| 5 | Sahashri | Temp batch table output |
| 6 | Brain | UDF test (3 scores) |
| 7 | Brain | IF/ELSE output |
| 8 | Brain | WHILE 12 months output |
| 9 | Parth | Stored procedure output |
| 10 | Parth | ErrorLog table |
| 11 | Josovo | View output |
| 12 | Josovo | CTE statistics output |
| 13 | Lien | TVF output |
| 14 | Lien | ProductReleaseReview table |
| 15 | Kelvin | Window ranking report |
| 16 | Kelvin | Categories table variable |
| 17 | Kelvin | NotificationLog |
| 18 | Dhruv | Subquery report |
| 19 | Dhruv | Cursor messages |
| 20 | Dhruv | ProductReleaseReview after cursor |
| 21 | Sahil | deploy_lab4.sql success |
| 22 | Sahil | deploy_all.sql success |

Upload to: `screenshots/YourName/` on GitHub

---

## Still Confused?

1. Find **your name** in the [Quick Lookup](#quick-lookup--find-your-name) table
2. Read **your section** (Person 1–9)
3. Check **Who Waits For Who** — know when you can start
4. Follow **Your checklist** before marking done
5. Ask Sahil or check `TEAM_PROJECT_PLAN.md` for task code details

**Repo:** https://github.com/sahilmaniya92/SQL-SERVER-SIMULATION-4-5
