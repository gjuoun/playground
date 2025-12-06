Updated `AGENTS.md` with a full guide: definitions, agent types, config layout, run commands, best practices, code examples, troubleshooting, and pointers to related files. Next steps: 1) adjust agent type list and paths to match your actual directory structure, 2) add real config examples once the agents are implemented, 3) consider adding quick-start scripts in `package.json` to match the commands documented.
�� side effects are explicit and auditable.

## 2. Agent Types in This Project
- **Chat Agent** – conversational interface for end users; routes intents and can call tools.
- **Task Runner** – executes one-off jobs (ingest, cleanup, migrations) via CLI or scheduler.
- **Data Fetcher** – pulls data from third-party APIs and normalizes it for internal use.
- **Orchestrator** – coordinates multiple agents, handles retries, and aggregates results.
- **Webhook Agent** – receives external events and hands them to the appropriate Task Runner or Chat Agent.
- **Cron Agent** – time-based trigger that kicks off predefined tasks on a schedule.

## 3. Using and Configuring Agents
### Project Layout
- `agents/chat/` – chat agent entry points and prompt logic.
- `agents/tasks/` – task runner implementations.
- `agents/fetchers/` – data fetchers and adapters.
- `agents/orchestrator.ts` – orchestrator wiring.
- `config/agents.(ts|json)` – shared configuration surface.

### Common Setup
1. Install deps: `bun install` (or `npm install`).
2. Create a local config: copy `config/agents.example.ts` to `config/agents.local.ts`.
3. Set environment variables in `.env` for secrets (API keys, endpoints, signing secrets).

### Configuration Keys (typical)
- `name`: unique agent identifier.
- `entry`: path to the agent handler file.
- `tools`: list of tool modules the agent may call.
- `auth`: credentials or token reference (never hardcode secrets in code).
- `limits`: `{ timeoutMs, maxTokens, concurrency }`.
- `logging`: `{ level, redact }`.
- `triggers`: `cli`, `cron`, `webhook`, or `chat`.

### Running Agents
- **Chat Agent (dev)**: `bun run agents/chat/index.ts --user "hi"`  
  Supports `--model`, `--max-tokens`, `--dry-run`.
- **Task Runner**: `bun run agents/tasks/purge-cache.ts --days 30`.
- **Data Fetcher**: `bun run agents/fetchers/pull-analytics.ts --since 2024-01-01`.
- **Orchestrator**: `bun run agents/orchestrator.ts --job nightly-refresh`.
- **Webhook Agent (local)**: `bun run agents/webhook/server.ts --port 4000`.
- **Cron Agent**: configure in `config/agents.local.ts` under `cron` and run `bun run agents/cron.ts`.

## 4. Best Practices and Guidelines
- **Principle of least privilege**: scope API keys and IAM roles to the minimal resources an agent needs.
- **Deterministic inputs**: validate and coerce incoming payloads; reject unknown fields early.
- **Time-box work**: set `timeoutMs` and `maxRetries`; prefer idempotent operations with dedup keys.
- **Observability**: log structured JSON; include `agent`, `requestId`, and timing metrics.
- **Testing**: add unit tests per agent; stub external calls; include golden prompts for chat behaviors.
- **Safe tool calls**: whitelist tools per agent; never allow arbitrary shell execution from user input.
- **Secrets handling**: load via env vars or secret manager; forbid secrets in git or logs.
- **Performance**: batch API calls when possible; avoid N+1 fetches; cache stable lookups.

## 5. Usage Examples
### Chat Agent Invocation (TypeScript)
```ts
import { runChat } from "./agents/chat";
import { tools } from "./agents/tools";

await runChat({
  message: "Generate a weekly status summary",
  tools,
  limits: { maxTokens: 1024, timeoutMs: 8000 },
  context: { project: "playground" },
});
```

### Task Runner with Arguments
```ts
import { runTask } from "./agents/tasks/purge-cache";

await runTask({ daysToKeep: 30, dryRun: false });
```

### Orchestrator Chaining Multiple Agents
```ts
import { orchestrate } from "./agents/orchestrator";

await orchestrate({
  workflow: "nightly-refresh",
  steps: ["fetch-latest", "rebuild-index", "post-report"],
  onFailure: { retry: 3, backoffMs: 2000 },
});
```

## 6. Troubleshooting Common Issues
- **Agent exits immediately**: check `entry` path in config and that the file is executable (`bun run` path correct).
- **Timeouts**: raise `limits.timeoutMs` or reduce upstream batch size; confirm external API latency.
- **Unauthorized errors**: ensure env vars are loaded (`bun run --env-file .env`); verify token scopes.
- **Prompt/tool mismatch (chat)**: the requested tool not in the agent’s `tools` list; add and restart.
- **Cron not firing**: confirm local time zone and that `cron` schedule is defined in `config/agents.local.ts`.
- **Webhook 400s**: validate signature secrets and payload schema; log request body in debug mode only.
- **High cost or token overrun**: set `maxTokens` and enable summarization steps; cache intermediate results.

## 7. Further Reading
- `README.md` for project overview.
- `CLAUDE.md` for model-specific guidance if applicable.
- `tsconfig.json` and `package.json` for runtime targets and scripts.
