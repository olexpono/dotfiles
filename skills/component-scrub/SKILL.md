---
name: component-scrub
description: Review and improve a named Alpaca component's API Doctrine scores from scripts/alpaca-static-analysis/components.json. Use when scrubbing a specific component without changing its call sites.
---

# Component Scrub

Require the user to name the component. If no component is provided, ask for it
before starting.

Review the component's entry in
`scripts/alpaca-static-analysis/components.json` and inspect the corresponding
component implementation to understand each API Doctrine score and failure.

Fix failures that can be addressed within the component without modifying call
sites. When the static analysis result does not accurately reflect the code,
adjust the component implementation so the detector can recognize the intended
API accurately; do not hide genuine failures or change the detector merely to
improve the score.

Preserve unrelated work and do not modify consumers of the component. Re-run
the relevant static analysis and focused checks after edits, then report the
score changes, fixes made, and remaining failures.

Suggest any additional score-improving changes separately rather than applying
them automatically. Get the user's confirmation before creating any new files.
