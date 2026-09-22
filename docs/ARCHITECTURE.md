# ARCHITECTURE.md — Current and Planned Technical Architecture

## Current State

The **data model**, Apex, LWC, Flow, trigger, tests, and **standard reports/dashboard** are in the org and (except recording/zip) in Git. **Org-wide coverage 93%** (2026-09-17 run). **Open:** Phase 10 bulk write-up; sharing; zip; recording; defense. Roll-ups **not used** (D022).

## Guiding Principle

Prefer the simplest maintainable solution that demonstrates appropriate Salesforce knowledge. Do not introduce advanced features (Queueable/Batch Apex, Platform Events, Custom Metadata) merely to look impressive — only where the requirement genuinely needs it.

## Architectural Decision Matrix (Planned)

| Requirement | Candidate Solutions | Recommended | Why | Alternative | Why Not |
|---|---|---|---|---|---|
| CRUD pages for Tenant/Vendor/Lease (basic) | Standard Record Pages vs. custom LWC | **Standard Record Pages** | No filtering/pagination/file-validation complexity here — standard pages satisfy the requirement with zero code, which is appropriate for a junior-dev assessment (demonstrates knowing when *not* to write code). | Custom LWC for everything | Unnecessary complexity/time cost for no functional gain; risks looking like code-for-code's-sake in review. |
| Property List (pagination + filters) | LWC+Apex vs. Standard List View w/ filters | **LWC + Apex** | Spec explicitly requires **server-side** pagination (25/page) and multi-field filtering passed to the query — this needs custom SOQL logic a standard list view can't provide. | Standard List View | Cannot do true server-side pagination with custom filter combination logic. |
| Property Create (mandatory image) | LWC+Apex vs. standard New button + Validation Rule | **LWC + Apex** | Files have no Required checkbox and can't be checked by a Validation Rule (Files live outside the record's own field values) — enforcing "must have ≥1 image" requires Apex logic in the save transaction, paired with `lightning-file-upload` in a custom form. | Standard New page | Physically cannot enforce the file requirement this way. |
| Auto-create Task on tenant assignment | Record-Triggered Flow vs. Apex Trigger | **Record-Triggered Flow** (default recommendation — reconsider if project needs bulk-complex logic later) | Simple, single-object, single-action automation — Flow is the Salesforce-recommended default for this class of problem and demonstrates appropriate judgment about when *not* to reach for code. | Apex Trigger | Valid alternative, not wrong — but adds unnecessary code/test surface for a requirement Flow handles natively. **Open for discussion with the developer before building — see Open Questions.** |
| Vendor auto-assignment (least workload) | Apex Trigger + Handler vs. Flow | **Apex Trigger + Handler** | Requires an aggregate SOQL query (grouped count of active requests per vendor) and picking the minimum — this kind of computation is significantly cleaner and more testable in Apex than in Flow. | Flow | Technically possible but awkward for aggregate/min-selection logic; harder to bulkify correctly. |
| Lease reminder email (30 days prior) | Scheduled Apex vs. Scheduled Flow | **Scheduled Apex** (default recommendation, open for discussion) | Gives more control over bulk querying and email construction; easier to unit test deterministically. | Scheduled Flow | Also valid, more declarative — worth the developer trying both approaches conceptually to understand the tradeoff, since this is exactly the kind of "why Flow vs Apex" defense question the assessment likely probes. |
| Reporting/Dashboard | Standard Reports & Dashboards vs. custom LWC dashboard | **Standard Reports & Dashboards** | All three required metrics (leases expiring in 30 days, maintenance grouped by status, occupancy rate) are achievable with standard Report Types + a Dashboard, no code needed. | Custom LWC | Unnecessary — would only be justified if requirements needed real-time custom interactivity, which they don't. |
| Testing | Apex Test Classes (required regardless) | **Apex Test Classes**, with a shared `TestDataFactory` | Spec explicitly requires ≥80% coverage; TestDataFactory avoids duplicated record-creation boilerplate across test classes. | — | Not optional — Salesforce requires deploy-time test coverage regardless of design choice. |
| Trigger code organization | Logic directly in trigger vs. Trigger Handler pattern | **Trigger Handler pattern** (Trigger → Handler class → Helper methods) | Keeps triggers thin, logic testable and reusable, follows established Salesforce best practice. | Logic in trigger body | Harder to test/maintain, considered poor practice at any experience level. |

## Explicitly Ruled Out (Do Not Introduce Without New Justification)
- Platform Events — no genuine pub/sub or external-system-integration need identified.
- Batch Apex — data volumes for a portfolio assessment don't warrant it; Scheduled Apex with a bulk-safe SOQL query for the lease-reminder job is sufficient at this scale. If real production-scale volumes were a stated concern, this should be revisited.
- Queueable Apex — no async chaining requirement identified yet.
- Custom Metadata Types — no configuration-driven behavior identified that would need this yet.

## Open Architectural Questions (Not Yet Decided — Do Not Assume)
1. **Flow vs Apex Trigger for tenant Task** — **decided D018 Flow.** Do not re-open unless they ask.
2. **Scheduled Apex vs Scheduled Flow for lease email** — **decided D019 Apex.**
3. **Roll-Up Summaries for reporting** — **decided D022: not added.** Occupancy uses Property Status reports.
4. **Sharing model** — still a full gap (OWD, sharing rules, profiles/FLS).
