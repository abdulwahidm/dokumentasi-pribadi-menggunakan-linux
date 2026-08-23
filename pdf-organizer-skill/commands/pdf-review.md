---
description: Second-pass consistency & risk review of the classification before execution (read-only).
agent: build
---

Load and strictly follow the `pdf-organizer` skill.

Execute the **/pdf-review** phase on the current working directory (the PDF collection root):

1. Read `_ai-organizer/manifests/inventory.json` and `_ai-organizer/manifests/classification.json`. If missing, tell the user to run `/pdf-inventory` and `/pdf-classify` first and stop.
2. Inspect: low-confidence classifications, suspicious ebook classifications (work/technical docs misclassified as ebooks), duplicate candidates, destination collisions, inconsistent subcategories, insufficient evidence, filename/content mismatches.
3. For each suspicious case, re-examine actual PDF evidence (metadata + sampled text) and either confirm or downgrade to REVIEW_REQUIRED / UNKNOWN.

STRICTLY READ-ONLY: no filesystem mutations, do not force classification.

Update `_ai-organizer/manifests/classification.json` with review results and create `_ai-organizer/reports/review.md`.

Finish with an updated statistics summary and what remains ambiguous. $ARGUMENTS
