# AI use

I used an AI assistant `claude.ai` in two specific ways during this exercise.

**1. Code optimization.**
For the SQL models and the Python scripts, I asked the
assistant to review drafts I had written and suggest improvements.
Concretely, it helped with:

- restructuring the repayment deduplication and reversal-netting logic in
  `raw_cbs_repayments.sql`
- the `is_minor_expr` macro and its canonicalization across raw, prepped,
  and the DQ3 conflict model
- the `dq4_publish_manifest.gate_status` classification logic

I reviewed every suggestion and only kept changes I could justify against
the rules in the exercise. Every model and every test was run and passes.

**2. Typo correction in documentation.**
In `OPERATIONS.md`, `DATA_QUALITY.md`, `DECISIONS.md`, the contract files
under `contracts/`, and the model descriptions in the YAML files, I asked
the assistant to correct spelling, punctuation, and grammar. The content,
structure, and decisions in those documents are mine.

No part of the source data was sent to the assistant. All examples used in
prompts were synthetic or already-published artefacts of this repository.