# DATA_MODEL.md — Current Data Model (Completed)

Status: **✅ Complete.** Objects live in the org and in `force-app`. Apex/LWC/Flow/trigger exist separately (see `ARCHITECTURE.md`).

Every decision below is classified as:
- **Confirmed** — reasoned through, implemented, and understood well enough to defend.
- **Requires validation** — implemented, but worth re-testing understanding of, or reconsidering technically.
- **Not yet decided** — genuinely open.

---

## Property__c

**Purpose:** Central object of the application — represents a rentable property.
**Type:** Custom object. Allow Reports ✅, Allow Activities ✅ (needed for the auto-created Task on tenant assignment), Track Field History ❌.
**Record Name:** `Property Name` — Text. *(Confirmed — reasoning: natural human-typed name.)*

| Field (API Name) | Type | Required | Notes |
|---|---|---|---|
| Name | Text | — | Record Name |
| Address__c | Text(255) | Yes | Considered Text Area for multi-line; rejected since City/State/Postal/Country are already separate fields — Address only needs street-level text. |
| City__c | Text(255) | Yes | |
| State__c | Text(255) | Yes | |
| Postal_Code__c | Text(20) | Yes | **Confirmed** — Text, not Number, to preserve leading zeros and support alphanumeric postal codes (e.g. Canadian format). |
| Country__c | Text(255) | Yes | |
| Type__c | Picklist: Residential, Commercial | Yes | Per-field values (not global value set — not reused elsewhere). |
| Furnishing_Status__c | Picklist: Furnished, Semi-Furnished, Unfurnished | Yes | Per-field values. |
| Status__c | Picklist: Occupied, Available | Yes | Per-field values. Drives the Occupancy Rate report. |
| Rent__c | Currency | Yes | |
| Description__c | Long Text Area | N/A (see below) | Cannot use Required checkbox — enforced via Validation Rule `Description_Required` (`ISBLANK(Description__c)`). |
| Tenant__c | Lookup → Tenant__c | No | See Relationship section below. |

**Images:** Standard Salesforce Files. **D010:** `createProperty` throws if no files, then inserts Property + ContentVersion (`FirstPublishLocationId`). Enforced on the LWC path only — standard New does not require Files.

---

## Tenant__c

**Purpose:** Represents a tenant who may rent one or more properties.
**Record Name:** `Tenant Name` — Text. *(Confirmed.)*

| Field | Type | Required |
|---|---|---|
| Name | Text | — (Record Name) |
| Phone_Number__c | Phone | Yes |
| Email__c | Email | Yes — **Confirmed reasoning:** Email type gives built-in format validation, mailto link, and mass-email integration for free; plain Text would accept any string. |

---

## Vendor__c

**Purpose:** Represents a vendor who services maintenance requests.
**Record Name:** `Vendor Name` — Text.

| Field | Type | Required |
|---|---|---|
| Name | Text | — (Record Name) |
| Phone_Number__c | Phone | Yes |
| Email__c | Email | Yes |

---

## Lease_Agreement__c

**Purpose:** Represents a lease contract tied to exactly one property.
**Record Name:** `Lease Agreement Number` — Auto Number, format `LEASE-{0000}`. **Confirmed reasoning:** a single property can have multiple lease agreements over its lifetime (renewals, new tenants); using the property's name as the record name would produce duplicate, non-unique labels in list views.

| Field | Type | Required |
|---|---|---|
| Name | Auto Number | — (Record Name) |
| Terms__c | Long Text Area | N/A — enforced via Validation Rule `Terms_Required` (`ISBLANK(Terms__c)`) |
| Agreed_Monthly_Rent__c | Currency | Yes |
| Start_Date__c | Date | Yes |
| End_Date__c | Date | Yes — will be used for the 30-day-prior email logic (`End_Date__c - TODAY()` style comparison) |
| Property__c | **Master-Detail** → Property__c | Yes (implicit — Master-Detail requires a parent at creation) |

---

## Maintenance_Request__c

**Purpose:** Represents a maintenance issue tied to one property, serviced by one vendor.
**Record Name:** `Maintenance Request Number` — Auto Number, format `MR-{00000}`. **Confirmed reasoning:** same rationale as Lease Agreement — many requests possible per property, no natural unique human name.

| Field | Type | Required |
|---|---|---|
| Name | Auto Number | — (Record Name) |
| Status__c | Picklist: Open, In Progress, Completed, Cancelled | Yes |
| Description__c | Long Text Area | N/A — enforced via Validation Rule `Description_Required` (`ISBLANK(Description__c)`) |
| Property__c | **Master-Detail** → Property__c | Yes (implicit) |
| Vendor__c | **Lookup** → Vendor__c | No |

**Confirmed business rule (implemented in `MaintenanceRequestTriggerHandler`, tests not green):** For vendor auto-assignment, only **Open** and **In Progress** count. Tie-break: Vendor Name alphabetical.

---

## Relationship Summary & Reasoning

| Relationship | Type | Parent | Delete Behavior | Classification |
|---|---|---|---|---|
| Property__c → Tenant__c | Lookup | — | Clear the value of this field | **Confirmed.** A property can exist with no tenant (vacancy); a tenant can have many properties, so the lookup lives on the "many" side (Property). Clearing on delete lets the property become vacant/reassignable rather than either cascading a delete or permanently blocking tenant deletion. |
| Lease_Agreement__c → Property__c | Master-Detail | Property | N/A (cascading delete is inherent) | **Confirmed.** A lease record has no independent meaning without its property; cascading delete on property removal is acceptable. Also correctly reasoned: Master-Detail causes the child to inherit the parent's sharing rules (avoids a lease being visible/invisible independently of its property), and unlocks future Roll-Up Summary fields on Property (e.g., total lease value) — not chosen yet, see Open Questions. |
| Maintenance_Request__c → Property__c | Master-Detail | Property | N/A | **Confirmed.** No reason to preserve maintenance history if the property itself is gone. |
| Maintenance_Request__c → Vendor__c | Lookup | — | Clear the value of this field | **Confirmed.** Maintenance history should be preserved even if a vendor is removed from the system — ruled out Master-Detail specifically because cascading delete would destroy that history, which was deemed undesirable independent of any other consideration (e.g., trigger-timing arguments were raised and correctly dismissed as not the deciding factor). |

### Correction made during original data-model design (worth keeping, not re-teaching from scratch)
An early framing suggested trigger-timing ("if a trigger assigns the vendor after creation, can the field be required-at-save Master-Detail?") was the deciding factor for the Vendor relationship type. This was **correctly challenged by the developer** — a `before insert` trigger actually *can* populate a field before save, so trigger timing alone doesn't rule out Master-Detail. The **actual** deciding factor was the "preserve history on delete" business requirement, not trigger timing. This is a good example of the developer's reasoning catching a flawed premise — see `LEARNING_PROFILE.md`.

---

## Validation Rules (Built)

| Object | Rule Name | Formula | Error Message | Location |
|---|---|---|---|---|
| Property__c | Description_Required | `ISBLANK(Description__c)` | "Description is required." | Field: Description |
| Lease_Agreement__c | Terms_Required | `ISBLANK(Terms__c)` | "Terms is required." | Field: Terms |
| Maintenance_Request__c | Description_Required | `ISBLANK(Description__c)` | "Description is required." | Field: Description |

**Confirmed reasoning for why Validation Rules (not page-layout-required) were used:** Validation Rules run on every save path (UI, Apex DML, API, bulk loads); page-layout "required" only applies to that specific layout, and would be silently bypassed by Apex-driven inserts (relevant since the Property Create flow will insert via Apex, not the standard UI).

---

## Formula Fields / Roll-Up Summaries — Not Yet Decided

Master-Detail relationships (Lease Agreement, Maintenance Request → Property) technically enable Roll-Up Summary fields on Property (e.g., "Active Lease Count," "Total Lease Value," "Open Maintenance Request Count"). **These have not been created and no decision has been made on whether they're needed.** This should be revisited when the Reporting/Dashboard phase is reached — it may reduce the amount of custom Apex/SOQL needed for the dashboard.

## Formula Fields for Lease Expiry — Not Yet Decided

No formula field currently calculates "days until lease expiry." The 30-day email is **D019/D020** Scheduled Apex: `End_Date__c = TODAY()+30`. Roll-ups for dashboards still open.
