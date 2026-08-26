# REQUIREMENTS.md — Business Requirements Only

**Rule for this document:** this file contains *only* what the assessment explicitly requires. It does not contain how we chose to implement anything — see `ARCHITECTURE.md` and `DECISION_LOG.md` for that. Where the assessment doesn't specify something, it is marked as an **Assumption** or **Open Question**, not silently decided here.

---

## 1. Property Management

### Fields
- Property Name
- Address (Required)
- City (Required)
- State (Required)
- Postal Code (Required)
- Country (Required)
- Type — Residential / Commercial (Required)
- Furnishing Status — Furnished / Semi-Furnished / Unfurnished (Required)
- Status — Occupied / Available (Required)
- Image (Required, can attach multiple documents)
- Rent (Required)
- Description (Required)

### List view
- List of properties, with pagination: **25 records per page, server-side**.
- Filters: **Price, Availability Status, Furnishing Status**.

### Create
- Must allow uploading multiple property images.
- **Must not allow creating a property without an image.**

---

## 2. Tenant Management

### Fields
- Name
- Phone Number
- Email

### Assumption (stated in original spec)
> A tenant can rent multiple properties.

### Requirements
- List view for tenants.
- **When a property is assigned to a tenant, automatically create a Task to generate the lease agreement.**

---

## 3. Lease Agreement Management

### Fields
- Terms
- Agreed Monthly Rent
- Start Date
- End Date

### Assumption (stated in original spec)
> A lease agreement is related to only one property.

### Requirements
- Provision to list and create lease agreements.
- **Send an automated email 1 month before the lease agreement's end date, to the tenant.**

---

## 4. Vendor Management

### Fields
- Name
- Phone Number
- Email

---

## 5. Maintenance Requests

### Fields
- Property
- Vendor
- Status — Open / In Progress / Completed / Cancelled
- Description

### Requirements
- **When a maintenance request is created, automatically assign it to the vendor with the least assigned workload.**

---

## 6. Reporting / Dashboard

Generate a dashboard showing:
1. Lease agreements expiring in the next 30 days.
2. Number of maintenance requests, grouped by status.
3. Occupancy rate.

---

## 7. Non-Functional Requirements

1. The system should handle bulk data efficiently.
2. All functionality should be covered by unit tests with a minimum of 80% coverage.
3. Commit changes to version control and share a zip of the repository.
4. Share a screen recording of the working app.

---

## Assumptions Not Explicitly Stated by the Assessment

These are things the business requirements don't specify, which the project has needed to decide on independently (see `DECISION_LOG.md` for the actual decisions made):

- Whether a Property can exist without a Tenant assigned (vacancy).
- What "least assigned workload" means precisely for vendor auto-assignment (e.g., does it count all requests ever, or only currently active ones?).
- What should happen to a Maintenance Request if its Vendor is deleted.
- What should happen to a Property's Lease Agreements / Maintenance Requests if the Property itself is deleted.
- Who the lease-expiry reminder email is sent to (assumed: the tenant, but this is not explicitly stated in the spec and should be confirmed/flagged during defense).

## Open Questions (Not Yet Decided)

- Should Roll-Up Summary fields (e.g., total lease value, count of active leases per property) be added to support the dashboard/reporting requirements, or will reports/SOQL alone suffice?
- Exact recipient(s) of the lease-expiry email — tenant only, or also an internal user/queue?
