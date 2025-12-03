# Repository Guidelines

## Runtime & Build Commands
- **Install**: `cd project && bun install` (use Bun, never npm/yarn/pnpm)
- **Run**: `cd project && bun run index.ts` or `bun --hot index.ts` for hot reload
- **Test**: `bun test` to run all tests, `bun test <file.test.ts>` for a single test file
- **Build**: `bun build <file.html|file.ts|file.css>` (no webpack/vite needed)

## Code Style & TypeScript Guidelines
- **Strict mode enabled**: Use explicit types, no implicit any; leverage `noUncheckedIndexedAccess`, `noImplicitOverride`
- **Imports**: Use `.ts`/`.tsx` extensions (allowed via `allowImportingTsExtensions`); prefer named exports
- **Formatting**: 2-space indentation, use ESNext features (target: ESNext, module: Preserve)
- **Naming**: camelCase for variables/functions, PascalCase for types/components, kebab-case for files
- **Error handling**: Use type-safe error returns or try-catch; avoid throwing strings

## Bun-Specific APIs (from .cursor/rules)
- Use `Bun.serve()` for servers (not Express), `Bun.file` over `node:fs`, `bun:sqlite` over better-sqlite3
- Use `Bun.$\`cmd\`` for shell commands, `Bun.sql` for Postgres, `Bun.redis` for Redis
- `.env` loads automatically (no dotenv package needed)
- Import HTML directly in TypeScript; HTML can import `.tsx`/`.jsx` with auto-bundling

## Testing
- Use `bun:test` framework: `import { test, expect } from "bun:test"`
- Name test files `<module>.test.ts`, colocate with source when appropriate
- Aim for one happy-path and one error-path test per module

## Security & Configuration
- Never commit `.env` files; use `.env.example` with placeholders
- Follow Conventional Commits for changelog consistency
