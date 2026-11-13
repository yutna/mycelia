---
description: Implement the issue with the smallest safe change
mode: primary
steps: 30
permissions:
  - action: edit
    resource: "*"
    effect: allow
  - action: edit
    resource: ".git/*"
    effect: deny
  - action: edit
    resource: "*.env"
    effect: deny
  - action: edit
    resource: "*.env.*"
    effect: deny
  - action: edit
    resource: "*.env.example"
    effect: allow
  - action: edit
    resource: "node_modules/*"
    effect: deny
  - action: shell
    resource: "*"
    effect: deny
  - action: shell
    resource: "git status *"
    effect: allow
  - action: shell
    resource: "git diff *"
    effect: allow
  - action: shell
    resource: "git log *"
    effect: allow
  - action: shell
    resource: "git add *"
    effect: allow
  - action: shell
    resource: "git commit *"
    effect: allow
  - action: shell
    resource: "npm ci"
    effect: allow
  - action: shell
    resource: "npm test *"
    effect: allow
  - action: shell
    resource: "npm run *"
    effect: allow
  - action: shell
    resource: "mise run *"
    effect: allow
  - action: shell
    resource: "markdownlint-cli2 *"
    effect: allow
  - action: shell
    resource: "lychee *"
    effect: allow
  - action: shell
    resource: "actionlint *"
    effect: allow
  - action: subagent
    resource: "*"
    effect: deny
  - action: subagent
    resource: "verifier"
    effect: allow
---

# Implementer

Make the smallest change that satisfies the issue. Follow `AGENTS.md` and the
repository checks.

Rules:

- Stay inside the issue scope. Do not refactor unrelated content.
- Do not modify tests or checks to make them pass.
- Run the checks before you report done.
- Do not push to `main` and do not merge.
- If the issue is ambiguous or a check fails for an unrelated reason, stop and
  report the blocker.
