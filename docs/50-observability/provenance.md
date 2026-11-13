# Provenance and AI-BOM

Status: Draft

## 1. Purpose

An artifact is only trustworthy if you know what produced it. This document
defines provenance for source, builds, tests, model output, policy, and
releases, plus the AI bill of materials that inventories the factory's
dependencies.

## 2. Questions provenance answers

- Which source commit produced this artifact?
- Which builder, toolchain, and environment produced it?
- Which model, prompt, and policy version produced this output?
- Which agent role and session produced it?
- Which evidence and parent artifacts does it depend on?
- Can it be rebuilt, and if not, why?

## 3. Artifact types

| Artifact | Examples |
| --- | --- |
| Source | Commit, tag, branch head |
| Build | Package, container image, binary |
| Test evidence | Test log, mutation report, coverage report |
| Model output | Patch, plan, review, summary |
| Policy and config | `opencode.json`, `mycelia.yaml`, policy bundle |
| Agent profile | Agents, commands, skills, prompts |
| Release | Tag, release notes, published artifact |

## 4. Provenance record

Every artifact records:

| Field | Meaning |
| --- | --- |
| `artifact` | Name or path |
| `artifactHash` | SHA-256 of the artifact |
| `source` | Repository and commit |
| `builder` | Builder ID and version |
| `environment` | OS, toolchain, dependency lock |
| `model` | Provider, model ID, version |
| `agent` | Role, session, policy version |
| `timestamp` | When it was produced |
| `parents` | Hashes of parent artifacts |
| `attestation` | Link to a signed attestation, when available |
| `variance` | Why the artifact is not reproducible, when relevant |

## 5. Chain

```text
source commit -> build -> test evidence -> release artifact
             \-> model output -> patch -> review -> acceptance
```

Each link references the hash of its parent. A broken link is a provenance gap
and an incident.

## 6. AI-BOM

The AI bill of materials inventories:

- models and providers
- MCP servers
- plugins
- skills
- package dependencies
- GitHub Actions
- base images
- prompts and commands

Each entry has a version, source, hash, license, owner, trust level, data
access, review date, and status. The inventory is defined in
[supply-chain.md](../20-control/supply-chain.md).

## 7. SLSA mapping

| SLSA concern | Provenance control |
| --- | --- |
| Source integrity | Commit and tag hashes, protected branches |
| Build provenance | Builder identity, environment, attestation |
| Dependency verification | Lockfiles, hashes, AI-BOM |
| Artifact integrity | Artifact hash and signature |

The target level depends on the risk tier. R3 and R4 aim for SLSA Build L2 or
higher. The specification does not claim a level without evidence.

## 8. Reproducibility and variance

- Pin the toolchain and dependencies.
- Record the environment hash.
- Rebuild in a clean environment when possible.
- Compare the rebuilt hash with the original.
- If the artifact is not reproducible, record the variance and the reason.
- A variance without a reason is a finding.

## 9. Attestation and verification

- Sign the provenance record when the ecosystem supports it.
- Store the attestation with the release.
- Verify the hash and the signature before use.
- Optionally anchor the record in a transparency log.
- A record that cannot be verified is unproven, not trusted.

## 10. Audit queries

- Which model and prompt produced this change?
- Which policy version was active?
- Which builder and environment produced this artifact?
- Which evidence supports this release?
- Can we rebuild the artifact from source?
- What changed between two releases?
- Which component is in the AI-BOM, and who owns it?

## 11. Anti-patterns

- No source commit.
- Mutable artifacts.
- A tag with no commit.
- No environment record.
- No model or prompt version.
- No variance record when reproducibility fails.
- A hash that is never verified.
- An AI-BOM that is out of date.
- A release with no provenance link.

## 12. Data contract

- Schema: [schemas/provenance-record.schema.json](../../schemas/provenance-record.schema.json)
- Example: [examples/provenance-record.example.yaml](../../examples/provenance-record.example.yaml)

## 13. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [supply-chain.md](../20-control/supply-chain.md) — AI-BOM and trust levels
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- [trace-and-audit.md](trace-and-audit.md) — trace
- [release-and-rollback.md](../40-assurance/release-and-rollback.md) — release
- `metrics-and-health.md` — metrics (planned)
- [docs/README.md](../README.md) — documentation map
