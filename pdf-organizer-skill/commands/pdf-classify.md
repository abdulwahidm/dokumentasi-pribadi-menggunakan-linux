---
description: Classify every inventoried PDF into category/subcategory with confidence & evidence (read-only).
agent: build
---

Load and strictly follow the `pdf-organizer` skill.

Execute the **/pdf-classify** phase on the current working directory (the PDF collection root):

1. Read `_ai-organizer/manifests/inventory.json`. If missing, tell the user to run `/pdf-inventory` first and stop.
2. For each PDF, analyze in evidence order: PDF metadata → document structure → extracted content (sample first/middle/last pages with `pdftotext`) → title → author → filename → directory context. Never classify by filename alone.
3. Apply deterministic rules first (ISBN, publisher, edition, TOC, chapter structure = strong ebook indicators), then LLM semantic classification.
4. Assign category + subcategory using the taxonomy from the skill (ebook, work, technical, documentation, course, research, finance, legal, reference, personal, unknown). Prefer subcategories.
5. Assign a confidence score: 0.95–1.00 AUTO, 0.85–0.94 REVIEW_OPTIONAL, 0.70–0.84 REVIEW_REQUIRED, <0.70 UNKNOWN. Record concrete evidence for every classification.
6. Recommend destination `category/subcategory/original-filename.pdf` (preserve filenames).
7. Detect duplicate candidates (similar title/author/page count/text but different SHA256).

STRICTLY READ-ONLY: no filesystem mutations.

Create `_ai-organizer/manifests/classification.json` and `_ai-organizer/reports/classification.md`.

Then STOP at the approval gate — print statistics (Total / AUTO / REVIEW_OPTIONAL / REVIEW_REQUIRED / UNKNOWN / DUPLICATE_EXACT) and "READY FOR APPROVAL - No filesystem mutations have been performed." Wait for explicit user approval before any move. $ARGUMENTS
