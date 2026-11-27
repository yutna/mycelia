# Scope

Mycelia is a control-plane specification for an evidence-governed AI software
factory on OpenCode, with a reference runtime planned from `v2.1.0`. This
document defines what the
project covers, what it does not, and what it claims.

## Current release

`v2.0.0`. It makes the runtime contract normative, adds the conformance kit
contract and fixtures, and moves the scope boundary
([ADR-0001](docs/00-foundations/decisions/0001-scope-boundary.md)). It ships no
runtime code. This is not a certification. The changes and the migration from
`v1.0.0` are in [CHANGELOG.md](CHANGELOG.md).

## Purpose

Give a repository a complete, auditable operating model for autonomous software
work: who may act, what they may touch, how work moves, what evidence proves it
is done, and how to tell what the repository still lacks.

## In scope

- OpenCode V2 as the only harness, version 2.4.0 or newer
  ([ADR-0002](docs/00-foundations/decisions/0002-runtime-stack.md)). This
  release was tested with 2.2.6; the 2.4.x test happens before `v2.0.0`.
- Role and permission contracts expressed through OpenCode agents, permissions,
  and policies.
- Policy-as-code, evidence manifests, and decision rights.
- The autonomous loop, failure and ambiguity handling, and multi-agent
  concurrency.
- Verification, test integrity, independent review, and human acceptance.
- Observability, provenance, metrics, and incident response.
- Evaluation of model and rule changes.
- A readiness assessment that reports the gap to the next safe autonomy level.
- Adoption guidance for greenfield and brownfield repositories.
- JSON Schema data contracts, examples, and an interface contract.
- The runtime contract that a conformant runtime implements, and the
  [conformance kit contract](docs/70-adoption/conformance-kit.md) with its
  fixtures in `conformance/fixtures/`.
- A reference runtime and the executable conformance kit, in `runtime/`, from
  `v2.1.0`.

## Out of scope

- Harnesses other than OpenCode. A different harness needs its own adapter and
  its own conformance profile.
- Product code of an adopting repository, dashboards, and hosted services.
- Runtime code outside `runtime/`. The reference runtime is one implementation;
  another runtime is a separate project that proves conformance with the kit.
- Model training, fine-tuning, and distillation.
- Certification, accreditation, audit attestation, or legal advice.
- A guarantee that generated code is correct. The guarantee is about evidence
  and terminal states, not about intent.
- Regulatory approval for a specific jurisdiction or sector.

## Specification and runtime

Mycelia has two parts. The **control-plane specification** is the normative
documents, schemas, examples, and OpenCode profile. The **reference runtime** is
one implementation of the
[runtime contract](docs/30-execution/opencode-runtime-contract.md). The
boundary is recorded in
[ADR-0001](docs/00-foundations/decisions/0001-scope-boundary.md).

| Autonomy level | Runtime required | How conformance is shown |
| --- | --- | --- |
| L0, L1 | No; a human runs the loop | Evidence produced by hand |
| L2, L3, L4 | Yes (`MYC-CORE-013`) | A conformant runtime and a passing conformance kit result for the declared profile |

The runtime is not optional from L2. A runtime other than the reference runtime
may be used if it passes the conformance kit. Until a kit implementation
exists (planned for `v2.1.0`), no repository can show this evidence, and the
ceiling under `v2.0.0` is L1. Where the reference runtime
disagrees with the specification, the specification wins and the runtime has a
bug.

## Reliability contract

Given a conformant repository, a conformant implementation, and a well-formed
work item, the factory MUST end in exactly one terminal state:

- `accepted` — the change is delivered, with complete evidence.
- `rejected` — the change is refused, with the reason and evidence.
- `blocked` — a human decision is required, with the precise question.
- `aborted` — a policy or budget stopped the work, with the cause.

Every terminal state has evidence and a trace. The factory MUST NOT report
success without satisfying the evidence manifest. This is what "reliable" means
here: no silent success, not a promise of perfect code.

## Claims and limitations

- The specification is OpenCode-specific by design. Portability to another
  harness is future work, not a current claim.
- The readiness model scores evidence, not intentions. A control without
  evidence is reported as unproven.
- The repository is a specification with a reference runtime, not a
  certification. A conformant repository does not inherit an approval from
  this project.
- The specification is versioned. A later release may tighten a requirement;
  the release notes record the change.
- The audit record describes what was checked and what remains limited. It is
  not an external attestation.

## Audiences

- Maintainers who want autonomous work without losing control.
- Platform engineers who build the repository, CI, and agent runtime.
- Reviewers and auditors who need a defensible evidence trail.
- Teams adopting the profile in an existing repository.

## Versioning

The project uses Semantic Versioning and `vX.Y.Z` milestones. A milestone
closes at 100 percent and becomes a GitHub Release. Breaking changes to the
specification use a major version.

## Related documents

- [README.md](README.md) — project identity and map
- [GLOSSARY.md](GLOSSARY.md) — shared terminology
- [CHANGELOG.md](CHANGELOG.md) — release notes and migration
- [AGENTS.md](AGENTS.md) — operating contract for agents
- [docs/README.md](docs/README.md) — reading paths and section map
