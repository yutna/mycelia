# Contributing

Thanks for your interest. This project has a single maintainer, so the process
is small and the same for every change.

## What belongs here

Mycelia is a specification repository. Changes are normative documents,
schemas, examples, OpenCode configuration, and audit records. Product code,
plugins, and CLI implementations are out of scope.

## How a change gets in

1. **Issue first.** Open or find an issue that describes the change. The
   maintainer triages it into a version milestone (`vX.Y.Z`) or `Backlog`.
2. **Branch** from `main` as `<type>/<issue>-<slug>`, for example
   `feat/12-login`.
3. **Open a draft pull request early.** CI runs on drafts too. Mark it
   *Ready for review* when the work is done.
4. **Title the pull request in Conventional Commits form:**
   `<type>(<scope>)!: <summary>`, where type is one of `feat`, `fix`, `docs`,
   `chore`, `refactor`, `test`, `ci`, `build`, `perf`, `style`, `revert`. The
   scope is optional and lower-case; `!` marks a breaking change. The title
   becomes the commit on `main`.
5. **Link the issue** with `Closes #N`. The pull request takes the issue's
   milestone, and it can only be merged while it is in a version milestone.
6. **CI must pass**: the `ci-ok` and `pr-check / check` checks.
7. **Squash merge only.** The branch is deleted after the merge.

A release is made when its version milestone is complete: closing the
milestone creates the GitHub Release with generated notes.

## Local checks

Requires [mise](https://mise.jdx.dev/). Then:

```sh
mise install
npm ci
mise run lint
```

Individual checks:

```sh
mise run lint
mise run lint:config
mise run lint:schemas
mise run lint:actions
```

## Markdown style

- Wrap prose at 120 columns. Tables and code blocks are exempt.
- One H1 per file; headings are sentence case.
- Use fenced code blocks with a language.
- Keep repository links relative; use `<...>` for bare URLs.

The repository configuration is in `.markdownlint-cli2.jsonc`. Overrides are
deliberate and documented there.

## The operating contract

`AGENTS.md` is the machine-facing contract for OpenCode and other agents.
`CONTRIBUTING.md` is the human-facing version. If a rule changes, update both
in the same pull request.

## OpenCode

The repository dogfoods the OpenCode profile it specifies:

- `opencode.jsonc` is the runtime configuration.
- `.opencode/agents/` defines roles and permissions.
- `.opencode/commands/` defines the issue, draft, verify, review, accept, and
  assess commands.
- `.opencode/skills/` defines the spec-writing, audit, and adoption playbooks.

Do not add a `CLAUDE.md`: OpenCode V2 reads `AGENTS.md` only.
