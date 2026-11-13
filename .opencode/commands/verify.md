---
description: Run the repository checks and report evidence
agent: verifier
---

# Verify

Run `mise run lint`. Run `mise run lint:config` when `opencode.json` changed.
Run `mise run lint:actions` when `.github/workflows/` changed.

Report the exact command, exit status, and a short excerpt of the output. Do
not fix anything; the implementer does.
