# ADR-0002: Runtime stack and OpenCode baseline

Status: Accepted

Date: 2026-11-27

Issue: [#102](https://github.com/yutna/mycelia/issues/102), follows
[ADR-0001](0001-scope-boundary.md)

## Context

[ADR-0001](0001-scope-boundary.md) adds a reference runtime in `runtime/` from
`v2.1.0`. Up to `v1.0.0` the specification names no implementation language,
no design rules for code, and a minimum OpenCode version of 2.2.6.

Facts from the OpenCode study in
[opencode-reference-notes.md](../../30-execution/opencode-reference-notes.md):

- OpenCode plugins, the in-process SDK (`@opencode/sdk`), and the HTTP client
  (`@opencode/client`) are TypeScript packages. A plugin must be TypeScript or
  JavaScript.
- The server API is described by `packages/protocol/openapi.json` in the
  OpenCode repository. The study read the `dev` branch, which is newer than any
  release.
- The Claude Agent provider exists from 2.2.3. Its `configDir` setting, which
  moves a session to the next account when one reaches its usage limit, exists
  from 2.4.0. Running Claude-model heads on more than one account needs it.
- OpenCode 2.4.0 also fixes Claude Agent process leaks and model renames.
- The OpenCode on the maintainer's server is 2.2.6. Upgrading it touches other
  projects on the same host and needs a separate, planned window.

Forces:

- The runtime must load as OpenCode plugins and call the OpenCode API with as
  little glue as possible.
- A weak implementer model writes most of the code, so the code rules must be
  written down and loaded as skills, not assumed.
- A version claim must match what was tested.

## Options considered

Language:

1. **TypeScript.** Native to OpenCode plugins, SDK, and client. One language for
   plugins, CLI, and kit.
2. Go or Rust. Single static binary, but plugins would still need a TypeScript
   shim, so the runtime would have two languages. The design skill pack has no
   Go or Rust skills.
3. Python. Common for tooling, but it has the same shim problem as Go and no
   in-process plugin path.

Design rules:

1. **Vendor a pinned copy of `yutna/object-oriented-design-skills` into the
   repository.** Reviewable, reproducible, works without network access.
2. Install the skills globally on the host. Not reproducible, and it breaks the
   host isolation the runtime contract asks for.
3. Write no design rules. A weak model then follows no stated rules.

OpenCode client:

1. **Generate the client from the pinned release's `openapi.json`.** Types match
   the server the runtime runs against.
2. Use the published `@opencode/client` at a matching version. Acceptable
   alternative when its version equals the pinned server version.
3. Hand-write HTTP calls. Drifts silently when the API changes.

## Decision

1. The reference runtime, its plugins, its CLI, and the executable conformance
   kit are written in **TypeScript** and live under `runtime/`.
2. Code under `runtime/` follows the vendored
   [object-oriented design skills](https://github.com/yutna/object-oriented-design-skills):
   - upstream release `v1.0.1`, commit
     `d78a95f03cb8bfefadb13ef487d23bc74d7a9fc5`;
   - packs `core` and `typescript` from the upstream `plugins/` folder;
   - copied to `runtime/.opencode/skills/`, with the version, commit, and MIT
     notice recorded next to them when they are vendored in `v2.1.0`. OpenCode
     finds project skills on the path from the repository root to the working
     directory, so the runtime either runs OpenCode inside `runtime/` or lists
     the folder in the `skills` configuration.

   The skills are advice. Where they conflict with this specification or the
   runtime's own written conventions, those win.
3. The **minimum OpenCode version is 2.4.0** for every repository that uses
   Mycelia. The `OC-01` check tests it.
4. The runtime's OpenCode client is generated from the `openapi.json` of the
   **tagged OpenCode release** it pins, not from a development branch. A
   published `@opencode/client` of the same version may be used instead.
5. The version the specification was **tested with** is stated separately from
   the minimum. Until the maintainer's server is upgraded, the tested version is
   2.2.6. The upgrade and a test on 2.4.x happen before the `v2.0.0` release
   ([#111](https://github.com/yutna/mycelia/issues/111)); the release states the
   tested version.

## Consequences

Easier:

- Plugins, CLI, and kit share one language and one type set with OpenCode.
- A weak implementer model gets written design rules as skills.
- Claude-model heads can fail over between accounts.

Harder:

- `runtime/` needs TypeScript checks (lint, type check, tests) in CI from
  `v2.1.0`.
- A repository on OpenCode 2.2.x that met the `v1.0.0` version check (`OC-01`)
  no longer meets it. It must upgrade to claim conformance.
- Until the server upgrade, the stated minimum (2.4.0) is newer than the tested
  version (2.2.6). The release is blocked until they agree.
- The vendored skills need a refresh procedure when upstream releases.

## Related documents

- [ADR-0001](0001-scope-boundary.md) — scope boundary
- [opencode-reference-notes.md](../../30-execution/opencode-reference-notes.md) — OpenCode study
- [opencode-runtime-contract.md](../../30-execution/opencode-runtime-contract.md) — runtime contract
- [opencode-conformance.md](../../70-adoption/opencode-conformance.md) — `OC-01` version check
