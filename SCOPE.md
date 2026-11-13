# Scope

Mycelia is a specification for an evidence-governed AI software factory on
OpenCode. This document defines what the project covers, what it does not, and
what it claims.

## Purpose

Give a repository a complete, auditable operating model for autonomous software
work: who may act, what they may touch, how work moves, what evidence proves it
is done, and how to tell what the repository still lacks.

## In scope

- OpenCode V2 as the only runtime, tested with version 2.2.6 or newer.
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

## Out of scope

- Harnesses other than OpenCode. A different harness needs its own adapter and
  its own conformance profile.
- Product code, runtime implementation, plugins, CLIs, dashboards, and hosted
  services. The specification defines the contract; an implementation is a
  separate project.
- Model training, fine-tuning, and distillation.
- Certification, accreditation, audit attestation, or legal advice.
- A guarantee that generated code is correct. The guarantee is about evidence
  and terminal states, not about intent.
- Regulatory approval for a specific jurisdiction or sector.

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
- The repository is a specification, not a certification. A conformant
  repository does not inherit an approval from this project.
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
- [AGENTS.md](AGENTS.md) — operating contract for agents
- [docs/README.md](docs/README.md) — reading paths and section map
