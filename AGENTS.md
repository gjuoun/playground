# Repository Guidelines

This playground starts almost empty on purpose; every contribution should leave it more structured. Treat this document as the shared contract for expanding the codebase safely.

## Project Structure & Module Organization
- Keep generated tooling files isolated: `.idea/` stores JetBrains state and `.amazonq/` keeps prompt experiments; leave them alone unless you are updating tooling.
- Place runtime code under `src/` (for example, `src/playground/example.py`), mirror tests under `tests/`, and keep throwaway spikes in `experiments/<topic>/` with a short README.
- Store reusable shell helpers in `scripts/` and document shared fixtures in `assets/README.md`.

## Build, Test, and Development Commands
- `python -m venv .venv && source .venv/bin/activate`: bootstrap an isolated Python environment.
- `pip install -e .[dev]`: install the package plus tooling; keep `pyproject.toml` in sync.
- `make lint`: wrap `ruff check` and `ruff format --check`; add the Makefile if your feature is the first to need it.
- `make test`: call `pytest` across `tests/` and fail fast on warnings.
- `make run MODULE=playground.cli`: provide an explicit entry point for demos and document required arguments.

## Coding Style & Naming Conventions
- Follow PEP 8 (4-space indentation, typed public APIs, concise module docstrings).
- Use snake_case for Python symbols, kebab-case for scripts, and UPPER_CASE for environment variables.
- Run `ruff format src tests` before opening a PR and keep linter ignores localized in `pyproject.toml`.

## Testing Guidelines
- Write unit tests with `pytest`; prefer fixtures for expensive setup and parametrize edge cases.
- Ensure every new module has at least one happy-path and one failure-path test; aim for ≥90 % coverage on changed files.
- Name test files `test_<module>.py` and document complex scenarios with concise comments.

## Commit & Pull Request Guidelines
- Follow Conventional Commits (`feat: add scheduler config`, `fix: handle empty payloads`) so changelog tooling stays consistent.
- Start each PR with a short summary, list the testing commands you ran, and link to tracked work.
- Include screenshots or terminal recordings when you touch developer workflows, and call out follow-up work in a “Next Steps” subsection.

## Security & Configuration Tips
- Never commit credentials, tokens, or `.env` files; prefer `.env.example` with placeholders.
- Review scripts for idempotency and gate destructive steps behind confirmation flags.
- Document new external service dependencies in the PR description and update onboarding notes in `README.md`.
