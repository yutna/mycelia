---
name: Mycelia audit
description: Audit a Mycelia specification change for completeness, consistency, and evidence.
---

# Mycelia audit

Use this skill before marking a specification change ready for review.

## Checklist

- Every requirement has an ID, evidence, verification, and failure mode.
- Every control has an owner and an escalation path.
- No requirement contradicts another; the glossary is consistent.
- Cross-references resolve.
- The change is in scope for the issue and milestone.
- Markdownlint and link checks pass.
- The change has an audit note in the pull request.

## Adversarial questions

- How could an agent satisfy the letter but not the intent?
- What evidence could be fabricated, stale, or self-certified?
- Which failure would be silent?
- Which human intervention is still required, and why?
