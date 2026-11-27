# Guard design

Status: Draft

## 1. Purpose

A guard that an agent can step around is worse than no guard: it reports green
while the risk it names is open. Audits of a real factory kept finding the
same class of bypass in its custom lint rules: a leading `::` on a constant,
safe navigation (`Current&.`), look-alike paths such as `*upstream_client.rb`,
and canaries that only asserted "the rule name appears", so a regression in one
form stayed green. This document defines how a guard is built and proven so
that this class of failure is caught by the guard's own tests, not by the next
audit.

## 2. Scope

A **guard** is any automated rule that blocks or flags an action or a change.
This standard applies to:

- linters and custom lint rules (for example RuboCop cops or ESLint rules)
- CI checks that pass or fail a change on a rule
- OpenCode `policies` statements and `permissions` rules
- plugin guards that block a tool call (on OpenCode 2.x,
  `ctx.tool.hook("execute.before")` or `ctx.permission.hook("evaluate")`)
- the test-diff guard
  ([test-integrity.md](../40-assurance/test-integrity.md) §4)
- runtime guards such as the no-progress guard
  ([failure-and-ambiguity.md](../30-execution/failure-and-ambiguity.md) §11)

Product tests are out of scope; they prove behavior, not a boundary.

The requirement IDs `MYC-CTL-001` to `MYC-CTL-006` in §5 are specification
requirements. They are not the readiness controls `CTL-01` to `CTL-24` in
[readiness-assessment.md](../70-adoption/readiness-assessment.md) §3, which
score a repository; §5 names the controls each requirement feeds.

## 3. Terms

- A **rule** (guard rule) is one named check inside a guard. It has a
  machine-readable rule name. A **registry rule** is a factory rule in the rule
  registry ([rule-lifecycle.md](../60-evolution/rule-lifecycle.md) §10); a
  guard rule may enforce it.
- An **offense** is one match of a rule against an input.
- **Normalization** turns every spelling of the same thing into one canonical
  form before a rule matches it.
- A **bypass** is an input that has the effect a rule forbids but that the rule
  does not match.
- A **bypass corpus** is the set of fixtures, per rule, that each try a known
  bypass form and must be caught.
- A **guard canary** is a fixture with a known input and an exact expected
  result: offense count, findings status, and rule name. It is not a release
  canary ([release-and-rollback.md](../40-assurance/release-and-rollback.md)).
- The **effective rule set** is the set of rules the guard actually enforces at
  run time, which may differ from its configuration file. Where the guard can
  list its loaded rules, the list is the effective rule set. Where it cannot,
  as for OpenCode policies (no API lists loaded statements, and an invalid
  statement is dropped with only a server-log warning), the effective rule set
  is the configured statements that pass the load check in §6.
- A **meta-check** is a check over the guard itself: it compares the effective
  rule set with the fixtures.
- **Loosening** a guard is any change that lets through an input the guard
  blocked before: removing or narrowing a rule, adding an exemption, raising a
  limit, lowering a severity, or disabling or soft-failing a check.

## 4. Bypass catalog

The bypass corpus of a rule MUST cover every form below that applies to the
rule's input kind. The examples are illustrative; the input kinds and the forms
are normative.

| Input kind | Bypass forms | Examples |
| --- | --- | --- |
| Identifiers and constants | Root-qualified name; alias or re-export; dynamic dispatch; safe navigation; string or symbol form; frozen or interpolated string | `::Current`, `Current&.user`, `send(:delete_all)`, `public_send`, `const_get("Current")` |
| Paths | Look-alike suffix or prefix; `..` segments; absolute versus relative; symlink; case on a case-insensitive filesystem; trailing slash; glob that also matches elsewhere | `lib/x/upstream_client.rb` versus `upstream_client.rb`, `a/../secret`, `SECRET.env` |
| Shell commands | Wrapper shells; environment or `command` prefix; absolute binary path; quoting and escaping; substitution; chaining; the same effect through another binary | `sh -c 'git push'`, `env X=1 git push`, `/usr/bin/git push`, `g''it push`, `$(echo git) push`, `sed -i` instead of an edit tool |
| Tool calls (OpenCode) | The same effect through `shell` instead of the dedicated tool; an MCP tool with the same effect (`<server>_<tool>` action); a subagent with its own permissions (a custom subagent's rules are not a subset of its parent's); Code Mode `execute`; a resource field that is not the path (for `grep` the resource is the pattern); rule order (last match wins); whole-value wildcard semantics (`*` also matches `/`); the default when nothing matches (the permissions base is `* * allow`, an unmatched permission evaluates to `ask`, and an unmatched policy allows) | `read` denied on `*/.ssh/*` but `shell` runs `cat ~/.ssh/id_ed25519`; a deny placed before a broader allow |

The OpenCode forms come from the
[OpenCode reference notes](../30-execution/opencode-reference-notes.md)
(permissions and plugin pages). Whether MCP and shell calls reach a plugin's
tool hook is an open item there; a plugin guard MUST NOT rely on it until a
canary proves it on the pinned version.

## 5. Requirements

These requirements use the fields in [SPEC.md](../../SPEC.md) §5. They refine
`MYC-CORE-003` (policy enforced by the runtime) and `MYC-CORE-009` (no merge
without the required gates).

### `MYC-CTL-001` Normalize before matching

- **Statement:** A guard MUST normalize each input with one shared
  normalization for its input kind before any rule matches it: identifiers
  resolved to their canonical name, paths made canonical relative to the
  repository root, and shell commands parsed into argument vectors. A rule
  MUST NOT match raw source text where a parser or syntax tree for the input
  exists.
- **Rationale:** Each spelling a rule does not normalize is a bypass. One
  shared normalization fixes a form once for every rule.
- **Applies to:** L2-L4; all risk tiers. Recommended at L1.
- **Evidence:** The normalization function or configuration each rule uses;
  bypass corpus results (`MYC-CTL-003`).
- **Verification:** Assessor check that rules share the normalization; bypass
  corpus run.
- **Failure mode:** The rule is unproven (§7).

### `MYC-CTL-002` Exact allow-lists

- **Statement:** An exemption MUST name exact normalized paths or identifiers.
  Suffix, substring, and unanchored pattern exemptions MUST NOT be used. A
  glob exemption MUST be anchored at the repository root and MUST have a
  fixture showing that a look-alike outside it is still caught.
- **Rationale:** `*upstream_client.rb` exempts every file that ends that way,
  including the one an agent creates to get past the rule.
- **Applies to:** L2-L4; all risk tiers. Recommended at L1.
- **Evidence:** Exemption lists; look-alike fixtures for each glob.
- **Verification:** Assessor check of every exemption; look-alike fixture run.
- **Failure mode:** The rule is unproven (§7).

### `MYC-CTL-003` Bypass corpus per rule

- **Statement:** Every rule MUST have a bypass corpus that covers each form in
  §4 that applies to its input kind, and each fixture MUST be caught. When a
  form does not apply, the corpus MUST record why, and the independent
  reviewer MUST check that reason. When an audit, review, or incident finds a
  bypass, a fixture for it MUST be added and shown to go uncaught before the
  rule is fixed.
- **Rationale:** A rule tested only on the obvious form is tested on the form
  no agent will use to get past it. A bypass that is fixed without a fixture
  comes back.
- **Applies to:** L2-L4; all risk tiers. Recommended at L1.
- **Evidence:** Bypass corpus fixtures and their results; recorded reasons for
  forms that do not apply; for each fixed bypass, the commit or CI run that
  shows its fixture uncaught before the fix.
- **Verification:** Meta-check (`MYC-CTL-005`); review of the reasons.
- **Failure mode:** The rule is unproven (§7).

### `MYC-CTL-004` Exact-count guard canaries

- **Statement:** Every rule MUST have guard canaries that run against the
  effective rule set and assert, for a known input, the exact offense count,
  the guard's documented findings status, and the machine-readable rule name.
  At least one canary MUST assert zero offenses for an allowed input. The
  findings status MUST differ from the guard's error status. An error status, a
  crash, a timeout, or a rule that is not in the effective rule set MUST fail
  the canary, never pass it. A guard MAY document an error as a fail-closed
  block (for example the OpenCode shell scanner error for a command it cannot
  analyze when a shell deny rule applies); a bypass fixture MAY expect that
  documented error. The expected result for each guard kind is in §6.
- **Rationale:** A canary that only checks "the rule name appears" stays green
  when one form regresses. A guard that crashes or does not load reports no
  offenses, which looks like a pass.
- **Applies to:** L2-L4; all risk tiers. Recommended at L1.
- **Evidence:** Canary fixtures and their results, with the guard version.
- **Verification:** CI run of the canaries on every change to the guard or its
  configuration.
- **Failure mode:** The guard fails closed: the change it gates is `rejected`.
  The rule is unproven until the canaries pass (§7).

### `MYC-CTL-005` Meta-check

- **Statement:** A meta-check MUST run in CI on every change to a guard, its
  configuration, or its fixtures. It MUST read the rule inventory from the
  effective rule set (for OpenCode policies, the statements that pass the load
  check in §6), not from a hand-written list or the configuration file alone.
  It MUST fail when a rule has no guard canary, no bypass corpus, or a missing
  form without a recorded reason, and when a fixture names a rule that is not
  in the effective rule set.
- **Rationale:** Without a meta-check, a new rule ships without tests, and a
  dropped rule keeps passing tests that no longer reach it.
- **Applies to:** L2-L4; all risk tiers. Recommended at L1.
- **Evidence:** Meta-check output listing each rule with its fixtures.
- **Verification:** Seed a rule with no fixture; the meta-check fails.
- **Failure mode:** The guard is unproven (§7); the change is `rejected`.

### `MYC-CTL-006` Loosening a guard

- **Statement:** A change that loosens a guard MUST carry proof that it is
  needed (a fixture that shows the false positive, or the identifier and
  approver of a policy decision record) and MUST be approved by a human other
  than its author. This is stricter than the author and approver split in
  [decision-rights.md](decision-rights.md) §10, which applies to R3 and R4
  only: an agent never approves a guard loosening. The change MUST follow the
  rule lifecycle ([rule-lifecycle.md](../60-evolution/rule-lifecycle.md) §5).
  A disabled or soft-failed check MUST be either a time-bound, owned exception
  (`MYC-CORE-011`) or removed through the rule lifecycle; it MUST NOT stay
  disabled without an expiry. A red-line check MUST NOT be disabled by an
  exception ([policy-as-code.md](policy-as-code.md) §10); only a policy change
  can alter it.
- **Rationale:** The author of a change is the one who wants it green. A check
  that is disabled "for now" stops guarding every case and is rarely
  re-enabled.
- **Applies to:** L1-L4; all risk tiers.
- **Evidence:** The approval record by a human other than the author; the
  proof fixture or decision record; the exception record for a disabled check.
- **Verification:** Audit sample of guard changes; assessor check that every
  disabled check has an unexpired exception.
- **Failure mode:** The loosening is reverted; the rule is unproven until it is
  restored or properly retired (§7).

## 6. Canary forms and the OpenCode load check

| Guard kind | A guard canary expects |
| --- | --- |
| Linter or custom lint rule | The exact offense count, the documented findings status, and the rule name. For example RuboCop and ESLint exit `1` for offenses and `2` for an error, so the canary expects `1`. |
| CI check | A failing status, with the rule name in the machine-readable output. |
| OpenCode policy | For each statement, a probe action that only that statement denies, denied with `Blocked by configuration policy`. The error does not name the statement, so one probe per statement identifies it. |
| OpenCode permission rule | For each role's effective permission set, the probe evaluates to `deny`, not `ask` or `allow`. |
| Plugin guard | The hook throws and the tool call is blocked, and the plugin is `active` in the plugin list (a plugin that failed to load blocks nothing). |
| Runtime guard | The expected trace event and outcome, for example a "No progress" count. |

The Mycelia CLI uses its own status codes
([cli-contract.md](../80-interface/cli-contract.md) §5).

The OpenCode policy load check, required at start by `MYC-EXE-013`, has three
steps; any failure stops the run before the first prompt:

1. Validate every red-line statement against the configuration schema before
   the server starts.
2. After start, check the server log: no statement may have been dropped.
3. Run the probe of every red-line statement; each must be denied as the table
   above states.

The statements that pass all three steps are the effective rule set of the
policy guard.

## 7. Unproven guards

A rule that does not meet `MYC-CTL-001` to `MYC-CTL-006` is **unproven**.
Under the readiness model a control needs evidence, and self-report is not
evidence ([readiness-assessment.md](../70-adoption/readiness-assessment.md) §4).
In the terms of [SPEC.md](../../SPEC.md) §10, an unproven red-line rule lowers
the autonomy ceiling (outcome 4); any other unproven rule affects scoring:

- An unproven rule is not evidence for the control it serves. The assessor
  scores `CTL-08` least privilege, `CTL-10` policy red lines, and `CTL-20` test
  integrity without it, so the score cannot reach 3 ("automated and
  evidenced") on that rule.
- An unproven red-line rule (a hard deny in
  [policy-as-code.md](policy-as-code.md) §8) fails the L2 gate in
  [readiness-assessment.md](../70-adoption/readiness-assessment.md) §5, so the
  autonomy ceiling is L1 until the rule is proven.

## 8. Enforcer register

Every registry rule
([rule-lifecycle.md](../60-evolution/rule-lifecycle.md) §10) names its
enforcer: the guard and guard rule that blocks it, or "instruction only" when
no guard exists. The format of the enforcer field is defined with the schemas
in #109. An instruction-only registry rule that an audit or incident shows was
broken twice SHOULD get a guard. A registry rule enforced by a guard SHOULD NOT
also be restated as instruction text that can drift from the guard.

## 9. Anti-patterns

- Matching raw source text when a parser exists.
- Exempting by suffix or substring.
- A canary that checks only that the rule name appears.
- Treating a guard crash or an unloaded rule as zero offenses.
- Fixing a bypass without first adding the fixture that shows it.
- Disabling a check "for now".
- A guard whose rule inventory is a hand-written list.

## 10. Related documents

- [SPEC.md](../../SPEC.md) — normative core
- [policy-as-code.md](policy-as-code.md) — policy model and red lines
- [roles-and-permissions.md](roles-and-permissions.md) — permission rules
- [test-integrity.md](../40-assurance/test-integrity.md) — test-diff guard
- [rule-lifecycle.md](../60-evolution/rule-lifecycle.md) — rule changes and
  registry
- [opencode-runtime-contract.md](../30-execution/opencode-runtime-contract.md)
  — policy load check (`MYC-EXE-013`)
- [readiness-assessment.md](../70-adoption/readiness-assessment.md) — control
  scoring
- [docs/README.md](../README.md) — documentation map
