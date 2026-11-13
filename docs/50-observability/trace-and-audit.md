# Trace and audit model

Status: Draft

## 1. Purpose

If it is not observed, it cannot be audited, debugged, or improved. This
document defines the trace event model, correlation, storage, tamper evidence,
retention, redaction, and the audit queries the factory must answer.

## 2. Trace, audit log, and metrics

| Artifact | Question | Shape |
| --- | --- | --- |
| Trace | What happened in this run, in order? | Events with parent and correlation IDs |
| Audit log | Who decided what, and why? | Append-only decisions and approvals |
| Metrics | How is the system behaving over time? | Aggregated numbers |

The trace is the detailed record. The audit log is the decision record. Metrics
are derived. A metric without a trace cannot be investigated.

## 3. Event model

Every event has:

| Field | Meaning |
| --- | --- |
| `traceID` | The end-to-end correlation ID |
| `spanID` | The event or operation ID |
| `parentSpanID` | The parent operation, when nested |
| `runID` | The run that produced the event |
| `workItemID` | The work item |
| `eventType` | The category |
| `actor` | Role, actor, session, model, policy version |
| `action` | What was attempted |
| `resource` | The target |
| `inputHash` | Hash of the input |
| `outputHash` | Hash of the output |
| `costUSD` | Cost, when known |
| `result` | `ok`, `error`, `denied`, or `blocked` |
| `timestamp` | When it happened |
| `attributes` | Extra key-value data |

Hashes are SHA-256. The event may also carry `previousHash` and `hash` for a
hash chain.

## 4. Event types

| Type | Examples |
| --- | --- |
| `session` | Created, resumed, interrupted, completed |
| `tool` | Shell, edit, read, webfetch, MCP call |
| `permission` | Asked, allowed, denied |
| `policy` | Allowed, denied, escalated |
| `evidence` | Produced, verified, invalidated |
| `state` | Transition, checkpoint, terminal state |
| `review` | Finding, decision |
| `acceptance` | Sign-off, revise, block |
| `release` | Gate, canary, rollback |
| `incident` | Opened, contained, resolved |

## 5. Correlation

- One `traceID` spans a work item from intake to observation.
- One `runID` identifies one attempt.
- One `workItemID` links the trace to the issue and the pull request.
- The commit and branch are attributes on the state and release events.
- The parent span links a subagent to its parent.
- A human approval links to the policy decision and the acceptance record.

## 6. Storage and retention

- Append-only storage.
- Access control by role.
- Retention policy per data class.
- Export to JSONL or an observability backend.
- The evidence hash and the trace event are kept even when the artifact is
  external.
- Security and release events are retained longer than transient logs.
- Delete or redact personal data according to policy.

## 7. Tamper evidence

- Hash-chain events, or batch-hash them at a fixed interval.
- Optionally anchor the batch hash in an external transparency log.
- Verify the chain on read and on export.
- A gap or a broken chain is an incident.
- A trace that cannot be trusted cannot support an R3 or R4 acceptance.

## 8. OTel GenAI mapping

An OpenTelemetry exporter maps the trace to spans:

| Mycelia field | OTel GenAI attribute |
| --- | --- |
| model | `gen_ai.request.model` |
| provider | `gen_ai.system` |
| operation | `gen_ai.operation.name` |
| input tokens | `gen_ai.usage.input_tokens` |
| output tokens | `gen_ai.usage.output_tokens` |
| tool | span name and attributes |

The mapping is informative. The Mycelia trace schema remains the source of
truth for audit.

## 9. Privacy and redaction

- Never record secrets.
- Redact personal data before export.
- Record the data class on the event when relevant.
- Limit access to traces that contain confidential data.
- Keep the redaction record with the trace.
- Do not put prompt contents in a metric label.

## 10. Audit queries

The trace must answer:

- Who approved this change, and in which role?
- Which model, prompt, policy, and rule versions produced it?
- What evidence was checked, and who verified it?
- What did the run cost?
- Which tool calls were denied or blocked?
- Which exceptions are active, and when do they expire?
- What was the exact sequence for this run?
- Which human decisions were made, and on what evidence?

## 11. Failure handling

- If the trace store is unavailable, buffer locally and alert.
- If the buffer is full, stop the run rather than lose the audit.
- If a gap is detected, mark the trace unproven and stop R3/R4 work.
- If the chain is broken, open an incident.
- Never continue silently without an audit trail.

## 12. Evidence

- Trace export with a hash.
- Integrity check result.
- Retention record.
- Redaction record.
- Audit query result for the sampled runs.

## 13. Anti-patterns

- Logs only at the end of a run.
- No correlation ID.
- Mutable logs.
- Secrets or personal data in logs.
- Infinite retention with no access control.
- Metrics with no trace.
- A trace with no evidence links.
- An audit query that cannot be answered.
- Continuing after an audit gap.

## 14. Data contract

- Schema: [schemas/trace-event.schema.json](../../schemas/trace-event.schema.json)
- Example: [examples/trace-event.example.yaml](../../examples/trace-event.example.yaml)

## 15. Related documents

- [README.md](../../README.md) — project identity and map
- [SCOPE.md](../../SCOPE.md) — boundaries, claims, limitations
- [SPEC.md](../../SPEC.md) — normative core
- [threat-model.md](../00-foundations/threat-model.md) — trace tampering
- [reference-architecture.md](../00-foundations/reference-architecture.md) — observability plane
- [autonomous-loop.md](../30-execution/autonomous-loop.md) — state and checkpoint
- [opencode-runtime-contract.md](../30-execution/opencode-runtime-contract.md) — event stream
- [evidence-manifest.md](../20-control/evidence-manifest.md) — evidence
- `provenance.md` — provenance (planned)
- `metrics-and-health.md` — metrics (planned)
- [docs/README.md](../README.md) — documentation map
