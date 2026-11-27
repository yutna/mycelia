# ADR-0001: Scope boundary: control-plane specification and reference runtime

Status: Accepted

Date: 2026-11-27

Issue: [#101](https://github.com/yutna/mycelia/issues/101), part of
[#99](https://github.com/yutna/mycelia/issues/99)

## Context

Up to `v1.0.0`, [SCOPE.md](../../../SCOPE.md) placed "product code, runtime
implementation, plugins, CLIs, dashboards, and hosted services" out of scope.
At the same time the repository defined a runtime contract, a CLI contract, an
autonomous loop, and conformance profiles whose autonomy levels depend on a
runtime.

Implementation feedback from a real OpenCode-based repository (#99) showed the
cost of that ambiguity:

- A reader could not tell whether `mycelia run` is required or only proposed,
  or whether the runtime contract is normative or descriptive.
- Nothing stated which runtime capabilities must exist before a repository
  claims a level that runs the loop without a human at each step.
- A third party had no way to prove that an implementation conforms.
- The failures that stopped the loop in practice (no-progress pauses on blocked
  work, guard bypasses, stale bases) were runtime behaviors that the
  specification did not bind.

Forces:

- Portability argues for a specification that does not ship code.
- Testability argues for an executable path from the specification to a running
  factory.
- The autonomy levels already assume a runtime from L2, where the agent runs the
  loop in a sandbox.

## Decision

1. Mycelia has two parts:
   - the **control-plane specification**: the normative documents, schemas,
     examples, and the OpenCode profile; and
   - a **reference runtime**: one implementation of the runtime contract, kept
     in its own top-level folder, `runtime/`, in this repository.
2. The runtime is **required** for a repository that claims L2 or higher. It is
   not optional. This is `MYC-CORE-013` in [SPEC.md](../../../SPEC.md).
3. The reference runtime is not the only allowed runtime. Any implementation may
   claim conformance by passing the conformance kit for the claimed profile. The
   kit contract and its fixtures are part of the specification; the executable
   kit ships with the reference runtime.
4. Delivery is staged:
   - `v2.0.0` makes the runtime contract normative, adds the conformance kit
     contract and fixtures, and changes this scope. It ships no runtime code.
   - From `v2.1.0`, the reference runtime and the executable kit are built in
     `runtime/`.
5. One version line covers both parts. Release notes list specification changes
   and runtime changes in separate sections. A change to a normative requirement
   follows [GOVERNANCE.md](../../../GOVERNANCE.md) whatever part it touches.
6. Dashboards, hosted services, and harnesses other than OpenCode remain out of
   scope.

## Consequences

Easier:

- A reader can tell what must exist for each autonomy level.
- Conformance becomes testable: a runtime passes the kit or it does not.
- Runtime failures found in practice can be bound by requirements and fixtures.

Harder:

- The repository now holds code from `v2.1.0`. It needs code checks, a stack
  decision (ADR-0002), and review rules for code as well as documents.
- An adopter that claimed L2 under `v1.0.0` without a conformant runtime no
  longer meets L2 under `v2.0.0`. The assessor lowers its ceiling to L1 until
  the runtime evidence exists. This is a breaking change and needs a major
  version.
- Until a kit implementation exists (planned for `v2.1.0`), no repository can
  show the conformance result, so the ceiling under `v2.0.0` is L1 for every
  repository.
- The reference runtime can be mistaken for the specification. The specification
  stays normative; where the runtime disagrees with it, the runtime has a bug.

## Related documents

- [SCOPE.md](../../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../../SPEC.md) — `MYC-CORE-013`
- [autonomy-levels.md](../autonomy-levels.md) — level preconditions
- [opencode-runtime-contract.md](../../30-execution/opencode-runtime-contract.md) — the runtime contract
- [GOVERNANCE.md](../../../GOVERNANCE.md) — decision records and versioning
