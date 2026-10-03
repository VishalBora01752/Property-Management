# REQUIREMENTS.md — Product scope

What this app is meant to do. Implementation choices live in `ARCHITECTURE.md` and the data model in `DATA_MODEL.md`. Product decisions that were not obvious from the feature list are at the bottom.

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

### Product rule
> A tenant can rent multiple properties.

### Behavior
- List view for tenants.
- **When a property is assigned to a tenant, automatically create a Task to generate the lease agreement.**

---

## 3. Lease Agreement Management

### Fields
- Terms
- Agreed Monthly Rent
- Start Date
- End Date

### Product rule
> A lease agreement is related to only one property.

### Behavior
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

### Behavior
- **When a maintenance request is created, automatically assign it to the vendor with the least assigned workload.**

---

## 6. Reporting / Dashboard

Generate a dashboard showing:
1. Lease agreements expiring in the next 30 days.
2. Number of maintenance requests, grouped by status.
3. Occupancy rate.

---

## 7. Quality bar

1. Automation should be bulk-safe.
2. Apex covered by unit tests (target at least 80% on project classes).
3. Source lives in Git.

---

## Assumptions

These needed a product decision (see the data model and architecture docs):

- Whether a Property can exist without a Tenant assigned (vacancy).
- What "least assigned workload" means for vendor auto-assignment (e.g. all requests ever vs currently active).
- What should happen to a Maintenance Request if its Vendor is deleted.
- What should happen to a Property's Lease Agreements / Maintenance Requests if the Property itself is deleted.
- Who receives the lease-expiry reminder (this app emails the tenant).

## Later decisions

- Occupancy and maintenance-by-status use standard reports; roll-up summaries were not added.
- Lease reminder email goes to the tenant on the related Property.
