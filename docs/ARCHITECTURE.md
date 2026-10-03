# ARCHITECTURE.md — Current and Planned Technical Architecture

## Current State

The data model, Apex, LWC, Flow, trigger, tests, reports, and dashboard are in this repo. Org-wide Apex coverage on the project classes was **93%** as of October 2026. Roll-up summaries were not added (standard reports instead).

## Guiding Principle

Prefer the simplest maintainable Salesforce solution. Do not introduce Batch/Queueable/Platform Events/Custom Metadata unless the problem actually needs them.

## Decision matrix

| Need | Candidate Solutions | Chosen | Why | Alternative | Why not |
|---|---|---|---|---|---|
| CRUD pages for Tenant/Vendor/Lease (basic) | Standard Record Pages vs. custom LWC | **Standard Record Pages** | No extra filter/pagination/file logic — standard pages are enough. | Custom LWC for everything | Extra code with no functional gain. |
| Property List (pagination + filters) | LWC+Apex vs. Standard List View w/ filters | **LWC + Apex** | Server-side pagination (25/page) and combined filters need custom SOQL. | Standard List View | Cannot do that query pattern cleanly. |
| Property Create (mandatory image) | LWC+Apex vs. standard New button + Validation Rule | **LWC + Apex** | Files have no Required checkbox and cannot be checked by a Validation Rule. | Standard New page | Cannot enforce the file check. |
| Auto-create Task on tenant assignment | Record-Triggered Flow vs. Apex Trigger | **Record-Triggered Flow** | Single-object, single create — Flow is the default for this class of problem. | Apex Trigger | Valid, but more code and tests than needed. |
| Vendor auto-assignment (least workload) | Apex Trigger + Handler vs. Flow | **Apex Trigger + Handler** | Aggregate count per vendor and pick the minimum is cleaner in Apex, including bulk. | Flow | Awkward for aggregate/min selection and harder to bulkify. |
| Lease reminder email (30 days prior) | Scheduled Apex vs. Scheduled Flow | **Scheduled Apex** | Bulk query + email, easy to unit-test without waiting for the clock. | Scheduled Flow | Also valid; more declarative. |
| Reporting/Dashboard | Standard Reports & Dashboards vs. custom LWC dashboard | **Standard Reports & Dashboards** | Leases in 30 days, maintenance by status, occupancy — no custom UI needed. | Custom LWC | No real-time interactivity required. |
| Testing | Apex Test Classes | **Apex Test Classes** | Salesforce coverage on deploy; project classes are at 93%. | — | Not optional if you ship Apex. |
| Trigger code organization | Logic in the trigger vs. Handler class | **Trigger Handler** | Thin trigger, testable logic. | Logic in trigger body | Harder to test and maintain. |

## Ruled out unless a real need appears
- Platform Events — no genuine pub/sub or external-system-integration need identified.
- Batch Apex — this org’s data volume does not need it; a bulk-safe scheduled query is enough.
- Queueable Apex — no async chaining requirement identified yet.
- Custom Metadata Types — no configuration-driven behavior identified that would need this yet.

## Decisions already made
1. Tenant Task — Flow (D018).
2. Lease email — Scheduled Apex (D019).
3. Roll-up summaries — not added (D022); occupancy uses Property Status reports.
4. Sharing — Public Read/Write on independent objects; Controlled by Parent on master-detail children. No custom profiles or sharing rules.
