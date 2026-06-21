# Simulation 4-5 — Production Quality Inspection Processing System

**Course:** SQL Server Developer  
**Project:** Simulation 4-5 (Lab 4 + Lab 5 — one joined project)  
**Database:** AdventureWorks2022  
**Schema:** ProductionOps  
**Timeline:** 14 Days  

**GitHub Repository:** [SQL-SERVER-SIMULATION-4-5](https://github.com/sahilmaniya92/SQL-SERVER-SIMULATION-4-5)

---

## Team Members

| # | Name | Role | Tasks Owned | Total Hrs | Student No. |
|---|------|------|-------------|-----------|-------------|
| 1 | Hassana | Schema & Foundation Lead | L4-T1, L4-T2, L5-T10 | 20 | _TBD_ |
| 2 | Sahashri | Report & Batch Developer | L4-T10, L5-T6 | 12 | _TBD_ |
| 3 | Brian | UDF & black-box test | TDD 4.1 (scalar UDF), TDD 10.1 | 6 | N10003819 |
| 4 | Parth | Stored Proc & Error Handling | L4-T5, L5-T5 | 11 | _TBD_ |
| 5 | Joshua | Views & Analytics Developer | L4-T6, L4-T7, L5 support | 6 | _TBD_ |
| 6 | Lien | TVF & Table Developer | TDD 4.1 (TVF), TDD 3.1 | 6 | _TBD_ |
| 7 | Kelvin | Window Reports & Notification | L4-T8, L5-T7, L5-T13 | 6 | _TBD_ |
| 8 | Dhruv | Subquery & Cursor Developer | L4-T9, L5-T11 | 11 | _TBD_ |
| 9 | Sahil | Final Deployment (**LAST**) | L4-T12–14, L5-T14 | 11 | _TBD_ |

> Each task is owned by **one person only**. Sahil owns the **LAST task** (final deploy + submission).

---

## Repository Structure

```
SQL-SERVER-SIMULATION-4-5/
│
├── scripts/
│   ├── setup/                  ← Hassana (L4-T1)
│   ├── tables/                 ← Hassana, Parth, Lien, Kelvin
│   ├── functions/              ← Brian, Lien
│   ├── procedures/             ← Parth
│   ├── views/                  ← Joshua
│   ├── reporting/              ← Joshua, Sahashri, Kelvin, Dhruv
│   ├── controlflow/            ← Brian
│   ├── errorhandling/          ← Parth
│   ├── temporary_objects/      ← Sahashri, Kelvin
│   ├── cursors/                ← Dhruv, Kelvin
│   ├── deployment/             ← Sahil (LAST)
│   └── validation/             ← Sahil (LAST)
│
├── screenshots/
│   ├── Hassana/                ← screenshots #1–3
│   ├── Sahashri/               ← screenshots #4–5
│   ├── Brian/                  ← screenshots #6–8
│   ├── Parth/                  ← screenshots #9–10
│   ├── Joshua/                 ← screenshots #11–12
│   ├── Lien/                   ← screenshots #13–14
│   ├── Kelvin/                 ← screenshots #15–17
│   ├── Dhruv/                  ← screenshots #18–20
│   └── Sahil/                  ← screenshots #21–22 + final compile
│
├── README.md
├── CONTRIBUTING.md
├── TEAM_PROJECT_PLAN.md
└── work_allocated.md
```

---

## Who Pushes Which Script

| Member | Task | Script File | Folder |
|--------|------|-------------|--------|
| **Hassana** | L4-T1 | `initialize_productionops_schema.sql` | `scripts/setup/` |
| | L4-T2 | `inspection_request_registration.sql` | `scripts/tables/` |
| | L5-T10 | `failed_inspection_queue.sql` | `scripts/tables/` |
| **Sahashri** | L4-T10 | `inspection_product_detail_report.sql` | `scripts/reporting/` |
| | L5-T6 | `inspection_batch_processing.sql` | `scripts/temporary_objects/` |
| **Brian** | TDD 4.1 (scalar UDF) | `fn_EffectiveUnitPrice.sql` | `scripts/functions/` |
| | TDD 10.1 | `test_functions.sql` | `scripts/tests/` |
| **Parth** | L4-T5 | `usp_GetInspectionRequests.sql` | `scripts/procedures/` |
| | L5-T5 | `error_log.sql` | `scripts/tables/` |
| | L5-T5 | `inspection_error_logging.sql` | `scripts/errorhandling/` |
| **Joshua** | L4-T6 | `vProductInspectionSummary.sql` | `scripts/views/` |
| | L4-T6 | `vw_PendingInspections.sql` | `scripts/views/` |
| | L4-T7 | `product_quality_statistics.sql` | `scripts/reporting/` |
| **Lien** | TDD 4.1 (TVF) | `tvf_PriceBreakdown.sql` | `scripts/functions/` |
| | TDD 3.1 | `table_InventoryDelta.sql` | `scripts/tables/` |
| **Kelvin** | L4-T8 | `product_ranking_report.sql` | `scripts/reporting/` |
| | L5-T7 | `inspection_category_management.sql` | `scripts/temporary_objects/` |
| | L5-T13 | `notification_log.sql` | `scripts/tables/` |
| | L5-T13 | `inspection_notification_cursor.sql` | `scripts/cursors/` |
| **Dhruv** | L4-T9 | `products_below_safety_stock_report.sql` | `scripts/reporting/` |
| | L5-T11 | `failed_product_review_cursor.sql` | `scripts/cursors/` |
| **Sahil (LAST)** | L4-T12 | `deploy_lab4.sql` | `scripts/deployment/` |
| | L4-T13 | `validate_lab4_results.sql` | `scripts/validation/` |
| | L5-T14 | `deploy_all.sql` | `scripts/deployment/` |
| | L5-T14 | `validate_lab5_results.sql` | `scripts/validation/` |
| | Final | README, screenshots, submit | `README.md` · `screenshots/` |

---

## Screenshot Ownership (GitHub Repo)

Each member uploads screenshots to their folder. **Sahil** compiles all 22 before submission.

| # | Name | Screenshot | Task | Upload to |
|---|------|------------|------|-----------|
| 1 | **Hassana** | Schema validation | L4-T1 | `screenshots/Hassana/` |
| 2 | **Hassana** | InspectionRequests data | L4-T2 | `screenshots/Hassana/` |
| 3 | **Hassana** | FailedInspectionQueue data | L5-T10 | `screenshots/Hassana/` |
| 4 | **Sahashri** | JOIN report output | L4-T10 | `screenshots/Sahashri/` |
| 5 | **Sahashri** | #InspectionBatch temp table | L5-T6 | `screenshots/Sahashri/` |
| 6 | **Brian** | Scalar UDF | TDD 4.1 | `screenshots/Brian/` |
| 7 | **Brian** | Black-box PASS/FAIL | TDD 10.1 | `screenshots/Brian/` |
| 9 | **Parth** | Stored procedure output | L4-T5 | `screenshots/Parth/` |
| 10 | **Parth** | ErrorLog contents | L5-T5 | `screenshots/Parth/` |
| 11 | **Joshua** | vProductInspectionSummary | L4-T6 | `screenshots/Joshua/` |
| 12 | **Joshua** | CTE quality statistics | L4-T7 | `screenshots/Joshua/` |
| 13 | **Lien** | TVF output | TDD 4.1 | `screenshots/Lien/` |
| 14 | **Lien** | InventoryDelta table | TDD 3.1 | `screenshots/Lien/` |
| 15 | **Kelvin** | Window function ranking | L4-T8 | `screenshots/Kelvin/` |
| 16 | **Kelvin** | @InspectionCategories | L5-T7 | `screenshots/Kelvin/` |
| 17 | **Kelvin** | NotificationLog contents | L5-T13 | `screenshots/Kelvin/` |
| 18 | **Dhruv** | Subquery report | L4-T9 | `screenshots/Dhruv/` |
| 19 | **Dhruv** | Review cursor messages | L5-T11 | `screenshots/Dhruv/` |
| 20 | **Dhruv** | ProductReleaseReview data | L5-T11 | `screenshots/Dhruv/` |
| 21 | **Sahil** | deploy_lab4.sql success | L4-T12 | `screenshots/Sahil/` |
| 22 | **Sahil** | deploy_all.sql success | L5-T14 | `screenshots/Sahil/` |

**Team:** Hassana · Sahashri · Brian · Parth · Joshua · Lien · Kelvin · Dhruv · Sahil

```powershell
git add screenshots/YourName/
git commit -m "Add screenshots (YourName)"
git push
```

---

## Clone & Push (Team Members)

```powershell
git clone https://github.com/sahilmaniya92/SQL-SERVER-SIMULATION-4-5.git
cd SQL-SERVER-SIMULATION-4-5
git checkout -b feature/yourname-task
git add scripts/your-folder/your-script.sql
git commit -m "L4-T1: add schema script (Hassana)"
git push -u origin feature/yourname-task
```



### Push order

| Day | Who pushes first |
|-----|------------------|
| 1 | **Hassana** — L4-T1, L4-T2 (blocks everyone) |
| 2 | Brian, Parth, Joshua, Lien — L4-T3–T7 |
| 3 | Kelvin, Dhruv, Sahashri — L4-T8–T10 |
| 4 | **Sahil** — L4-T12–14 mid deploy |
| 6 | Hassana, Sahashri, Lien — L5-T10, T6, T12 |
| 7 | Brian, Parth, Kelvin — L5-T3–T5, T7 |
| 9 | **Dhruv** L5-T11, then **Kelvin** L5-T13 |
| 11–12 | **Sahil** — L5-T14 final deploy + submit (**LAST**) |

---

## Deployment (Sahil — LAST)

Run with **SQLCMD Mode** in SSMS:

| Script | When |
|--------|------|
| `scripts/deployment/deploy_lab4.sql` | Day 4 — mid deploy |
| `scripts/deployment/deploy_all.sql` | Day 11 — full deploy |
| `scripts/validation/validate_lab4_results.sql` | After mid deploy |
| `scripts/validation/validate_lab5_results.sql` | After full deploy |

---

## Script Rules

- Every script starts with `USE AdventureWorks2022; GO`
- All objects in `ProductionOps` schema
- Scripts must be re-runnable (`IF NOT EXISTS`, `CREATE OR ALTER`)
- Do not edit another member's script

---

## Add Collaborators (Repo Owner)

https://github.com/sahilmaniya92/SQL-SERVER-SIMULATION-4-5/settings/access

---

## Submission Checklist

- [ ] All 25 scripts in correct folders
- [ ] `deploy_lab4.sql` runs green (Day 4)
- [ ] `deploy_all.sql` runs green (Day 11)
- [ ] 22 screenshots in `screenshots/`
- [ ] README with all 9 names + student numbers + Data Mapping
- [ ] Instructor added as GitHub collaborator
- [ ] Repository link submitted to professor

---

*Repository: https://github.com/sahilmaniya92/SQL-SERVER-SIMULATION-4-5*
