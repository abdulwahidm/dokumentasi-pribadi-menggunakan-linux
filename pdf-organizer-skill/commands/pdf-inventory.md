---
description: Read-only discovery & inventory of all PDFs in the current directory (no classification, no file moves).
agent: build
---

Load and strictly follow the `pdf-organizer` skill.

Execute the **/pdf-inventory** phase on the current working directory (the PDF collection root):

1. Recursively discover all PDFs (skip `_ai-organizer/`, `backup/`, and non-PDF files like .odt/.pptx/.docx/.djvu/.xlsx).
2. Collect metadata (`pdfinfo`): title, author, page count, creation date.
3. Calculate SHA256 for every PDF (`sha256sum`).
4. Test text extraction (`pdftotext`), detect likely scanned PDFs (OCR candidates) and unreadable/corrupt files.
5. Detect exact duplicates via identical SHA256 — mark `DUPLICATE_EXACT`, never delete.

STRICTLY READ-ONLY: do not move, rename, delete, overwrite, or modify any PDF. Do not classify yet.

Create `_ai-organizer/manifests/inventory.json` and `_ai-organizer/reports/inventory.md`.

Finish with a summary report: total PDFs, total size, duplicate count, OCR candidates, corrupt candidates. $ARGUMENTS
