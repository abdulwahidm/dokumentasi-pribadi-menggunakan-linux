---
name: pdf-organizer
description: Safely organize, classify, and manage a local PDF collection using an auditable pipeline with inventory, evidence-based classification, deduplication, manifests, and human approval before any file mutation. Use when the user asks to organize PDFs, classify documents, deduplicate PDFs, or build a document-management workflow.
---

# PDF Organizer Skill

Use this skill when organizing a messy local PDF collection (default target: the current working directory). The goal is not merely moving files but creating a reliable document-management pipeline:

```text
DISCOVER → INVENTORY → EXTRACT → CLASSIFY → DEDUPLICATE → REVIEW → MANIFEST → HUMAN APPROVAL → EXECUTE → VERIFY → REPORT
```

Accuracy, safety, explainability, and reversibility are more important than maximum automation.

## 1. Critical Safety Rules

The original PDF collection must remain untouched during discovery, extraction, classification, and review.

Before explicit execution approval, you MUST NOT: move, rename, delete, overwrite, or modify files/PDF contents/metadata.

When uncertain: `DO NOTHING`. Never guess merely to increase the automation rate. The manifest is the boundary between AI reasoning and filesystem mutation.

## 2. Architecture

Two logical roles — never give the classifier unrestricted filesystem mutation capability:

### Classifier (read-only)
Allowed: read files, inspect metadata, extract text, calculate hashes, classify, create reports and manifests.
Forbidden: move, rename, delete, overwrite.

### Executor
Mutation-enabled, but only operates on an approved manifest, with hash verification before/after every move.

## 3. Project Structure

```text
koleksi-pdf/   # your collection folder
├── _ai-organizer/
│   ├── config/categories.yaml
│   ├── manifests/{inventory,classify,execution}.json
│   ├── reports/{inventory,classification,review,execution}.md
│   ├── quarantine/
│   └── backups/
├── ebook/ ├── work/ ├── technical/ ├── documentation/ ├── course/
├── research/ ├── finance/ ├── legal/ ├── reference/ ├── personal/ └── unknown/
```

Do not create category directories until classification is ready.

## 4. Taxonomy (configurable via categories.yaml)

Top-level categories: `ebook`, `work`, `technical`, `documentation`, `course`, `research`, `finance`, `legal`, `reference`, `personal`, `unknown`.

Prefer subcategories over new top-level categories. Suggested subcategories:

```yaml
categories:
  ebook: [programming, business, science, mathematics, philosophy, literature, technology, other]
  work: [report, proposal, project, meeting, correspondence, specification, other]
  technical: [programming, linux, networking, cybersecurity, devops, database, infrastructure, other]
  documentation: [software, api, system, manual, installation, configuration, other]
  course: [programming, cybersecurity, devops, mathematics, business, other]
  research: [computer-science, engineering, mathematics, physics, social-science, other]
  finance: [invoice, receipt, report, tax, other]
  legal: [contract, agreement, regulation, certificate, other]
  reference: [standard, specification, cheatsheet, catalog, other]
  personal: [identity, correspondence, other]
  unknown: [unclassified]
```

Do not hard-code assumptions throughout the implementation.

## 5. Evidence Hierarchy

Do not classify using filename alone. Use evidence in this order:
1. PDF metadata
2. Document structure
3. Extracted content
4. Title
5. Author
6. Filename
7. Original directory context

Example: `React.pdf` could be an ebook, course document, software documentation, research paper, project report, or cheat sheet.

## 6. Extraction Strategy

Do not send entire large PDFs to the LLM unnecessarily. First inspect metadata, page count, title, author, creation date, text extractability, first pages, table of contents, representative middle content, final pages.

Tools: `pdfinfo`, `pdftotext` (`| head -n 200` / `| tail -n 200` for sampling).

Scanned PDFs = OCR candidates; OCR is only a fallback when text extraction fails. Do not OCR every PDF automatically.

Apply deterministic rules before LLM: ISBN detected, publisher metadata, edition info, chapter structure, table of contents, book-like page structure are strong ebook indicators. Preferred flow: `Metadata + Rules + Content samples → Candidate evidence → LLM → Classification`.

## 7. Confidence Policy

Every classification MUST have a confidence score:

```text
0.95–1.00  AUTO
0.85–0.94  REVIEW_OPTIONAL
0.70–0.84  REVIEW_REQUIRED
< 0.70     UNKNOWN
```

Never automatically organize `REVIEW_REQUIRED`, `UNKNOWN`, or `CONFLICT` unless the user explicitly approves them.

## 8. Duplicate Detection

Calculate SHA256 for every PDF (`sha256sum`). Identical hashes → `DUPLICATE_EXACT` (do not delete either). Semantically similar but different hashes → `DUPLICATE_CANDIDATE` (require review). Evidence: same title, author, page count, similar extracted text/metadata, different filename.

## 9. Destination & Collision Rules

Destination format: `category/subcategory/`. Preserve original filenames by default — do not translate, abbreviate, normalize, or rename unless explicitly requested.

Never overwrite an existing destination:
- Same SHA256 at destination → `DUPLICATE_EXACT`, keep both.
- Different SHA256 → `CONFLICT`, do not overwrite, no silent random suffixes unless explicitly configured and approved.

## 10. Manifest Format

Every proposed filesystem operation MUST be in a manifest BEFORE any mutation:

```json
{
  "source": "old-folder/react.pdf",
  "source_sha256": "abc123",
  "destination": "ebook/programming/react.pdf",
  "category": "ebook",
  "subcategory": "programming",
  "confidence": 0.97,
  "status": "AUTO",
  "action": "MOVE",
  "evidence": ["book metadata detected", "ISBN detected", "publisher detected", "table of contents detected"]
}
```

## 11. Workflow Commands

### /pdf-inventory (read-only)
Recursively discover PDFs → collect metadata → count pages → SHA256 → test text extraction → detect scanned PDFs → detect exact duplicates → generate `_ai-organizer/manifests/inventory.json` + `_ai-organizer/reports/inventory.md`. Never classify or move files here.

### /pdf-classify (read-only)
Read inventory → analyze metadata/structure/text → apply deterministic evidence → LLM semantic classification → assign category/subcategory/confidence/evidence/destination → detect duplicate candidates → output `_ai-organizer/manifests/classification.json` + `_ai-organizer/reports/classification.md`.

### /pdf-review (read-only)
Second-pass consistency/risk review: low-confidence classifications, suspicious ebook classifications, duplicate candidates, destination collisions, inconsistent subcategories, insufficient evidence, filename/content mismatches. Output `_ai-organizer/reports/review.md`. Ambiguous cases stay `REVIEW_REQUIRED` or `UNKNOWN` — do not force classification.

### /pdf-organize (mutation, approved manifest only)
For each file: verify source exists → recalculate SHA256 → compare against manifest → abort if hash differs → check destination/prevent overwrite → create directory → move → verify destination exists → recalculate destination SHA256 → confirm match. Outputs `_ai-organizer/manifests/execution.json` + `_ai-organizer/reports/execution.md`. Never process `UNKNOWN` / `REVIEW_REQUIRED` / `CONFLICT` without explicit approval.

## 12. Approval Gate

After classification, STOP and report statistics:

```text
Total PDFs:        2431
AUTO:              1982
REVIEW_OPTIONAL:    241
REVIEW_REQUIRED:    167
UNKNOWN:             41
DUPLICATE_EXACT:     73
READY FOR APPROVAL - No filesystem mutations have been performed.
```

Only after explicit user approval may execution begin.

## 13. Rollback / Reporting

Keep execution records with original path, destination path, original/destination SHA256, timestamp, status — so rollback can reconstruct original locations. Never delete the execution manifest.

Reports must cover: inventory (total, size, distribution, duplicates, OCR candidates), classification (per category/subcategory, confidence distribution, unknown/review counts), review (ambiguous/suspicious/duplicates/conflicts), execution (moved/skipped/duplicates/conflicts/failures/verification failures).

## 14. Success Criteria

1. Every discovered PDF has an inventory record.
2. Every classification has evidence and a confidence score.
3. Every mutation is represented in a manifest.
4. No file is overwritten or deleted automatically.
5. SHA256 is verified before and after movement.
6. Ambiguous documents remain untouched.
7. Exact duplicates are reported rather than deleted.
8. Execution is auditable and reversible.
9. The taxonomy can be changed without rewriting the entire system.
10. Repeated runs do not corrupt or duplicate the collection.

**Core principle: Let AI reason about documents. Let deterministic code control the filesystem.**
