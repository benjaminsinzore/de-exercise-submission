# Decisions

## Pushing enterprise_client_id back to the core banking system

**Decision: no.**

The pipeline is read-only against `source/` and against the CBS. Rule 1 forbids
writing anything back to a source system, and the crosswalk is built from CSVs,
not from the CBS API. Pushing an ID would also make our derived identifier a
system of record for the CBS, which we cannot support: the match can change
nightly as new data arrives, and a bad match would silently propagate to loan
officers.

**What we will do instead.** Publish `dim_enterprise_client` and
`fct_loan.enterprise_client_id` as a nightly read-only extract in the marts
schema. Loan officers consume it via the reporting layer they already use.
If a client is mis-merged, the A2 review queue and `dq3_identity_conflicts`
surface it, and a human resolves it — no write-back is involved.

**Revisit if** the CBS exposes a supported write API for client metadata and
finance signs off on the audit trail. 