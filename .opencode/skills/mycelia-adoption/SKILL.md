---
name: Mycelia adoption
description: Apply the Mycelia profile and readiness model to another repository.
---

# Mycelia adoption

Use this skill when applying the profile to another repository.

## Steps

1. Run the readiness assessment and record the baseline.
2. Copy `opencode.json`, `AGENTS.md`, and `.opencode/`.
3. Set the risk tiers and the autonomy ceiling.
4. Add the evidence manifest and the CI gates.
5. Run one low-risk change through the full loop.
6. Raise the autonomy level only after the evidence is stable.

## Boundaries

- Do not copy the repository's specifications into the adopter.
- Keep the adopter's policies in its own `opencode.json`.
- Record deviations in the readiness report.
