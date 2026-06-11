# Contributing — Simulation 4-5 Team Workflow

**Repo:** https://github.com/sahilmaniya92/SQL-SERVER-SIMULATION-4-5

## File Ownership

| Member | Task(s) | Script File | Folder |
|--------|---------|-------------|--------|
| **Hassana** | L4-T1, L4-T2, L5-T10 | `initialize_productionops_schema.sql` | `scripts/setup/` |
| | | `inspection_request_registration.sql` | `scripts/tables/` |
| | | `failed_inspection_queue.sql` | `scripts/tables/` |
| **Sahashri** | L4-T10, L5-T6 | `inspection_product_detail_report.sql` | `scripts/reporting/` |
| | | `inspection_batch_processing.sql` | `scripts/temporary_objects/` |
| **Brain** | L4-T3, L5-T3, L5-T4 | `fn_InspectionScoreClass.sql` | `scripts/functions/` |
| | | `inspection_result_classification.sql` | `scripts/controlflow/` |
| | | `monthly_inspection_schedule.sql` | `scripts/controlflow/` |
| **Parth** | L4-T5, L5-T5 | `usp_GetInspectionRequests.sql` | `scripts/procedures/` |
| | | `error_log.sql` | `scripts/tables/` |
| | | `inspection_error_logging.sql` | `scripts/errorhandling/` |
| **Josovo** | L4-T6, L4-T7 | `vProductInspectionSummary.sql` | `scripts/views/` |
| | | `vw_PendingInspections.sql` | `scripts/views/` |
| | | `product_quality_statistics.sql` | `scripts/reporting/` |
| **Lien** | L4-T4, L5-T12 | `fn_GetProductInspectionData.sql` | `scripts/functions/` |
| | | `product_release_review.sql` | `scripts/tables/` |
| **Kelvin** | L4-T8, L5-T7, L5-T13 | `product_ranking_report.sql` | `scripts/reporting/` |
| | | `inspection_category_management.sql` | `scripts/temporary_objects/` |
| | | `notification_log.sql` | `scripts/tables/` |
| | | `inspection_notification_cursor.sql` | `scripts/cursors/` |
| **Dhruv** | L4-T9, L5-T11 | `products_below_safety_stock_report.sql` | `scripts/reporting/` |
| | | `failed_product_review_cursor.sql` | `scripts/cursors/` |
| **Sahil (LAST)** | L4-T12–14, L5-T14 | `deploy_lab4.sql`, `deploy_all.sql` | `scripts/deployment/` |
| | | `validate_lab4_results.sql`, `validate_lab5_results.sql` | `scripts/validation/` |

## Commit format

```
L4-T1: add schema script (Hassana)
L5-T11: add review cursor (Dhruv)
```
