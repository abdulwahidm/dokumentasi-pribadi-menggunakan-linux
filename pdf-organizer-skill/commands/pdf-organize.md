---
description: Execute ONLY approved AUTO moves from the classification manifest, with SHA256 verification.
agent: build
---

Load and strictly follow the `pdf-organizer` skill.

Execute the **/pdf-organize** phase on the current working directory (the PDF collection root):

1. Read `_ai-organizer/manifests/classification.json`. If missing, tell the user to run `/pdf-inventory` and `/pdf-classify` first and stop.
2. Only process entries with status `AUTO` (confidence ≥ 0.95). NEVER process `UNKNOWN`, `REVIEW_REQUIRED`, or `CONFLICT` unless $ARGUMENTS contains explicit approval for those specific files. If $ARGUMENTS is empty, confirm with the user before proceeding: show the count of pending AUTO operations.
3. For each approved file, in order:
   - Verify source exists.
   - Recalculate source SHA256; abort that operation if it differs from the manifest.
   - Check destination; never overwrite. Same hash at destination → skip as `DUPLICATE_EXACT`; different content → mark `CONFLICT`.
   - Create `category/subcategory/` directory, move the file preserving its original filename.
   - Recalculate destination SHA256; confirm it matches the source hash, else report verification failure.
4. Record every operation (original path, destination path, both SHA256 hashes, timestamp, status) in `_ai-organizer/manifests/execution.json` — this is the rollback record, never delete it.

Create `_ai-organizer/reports/execution.md`: moved / skipped / duplicates / conflicts / failures / verification failures / remaining unorganized files.

$ARGUMENTS
