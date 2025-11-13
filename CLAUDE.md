# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---
description: Use Bun instead of Node.js, npm, pnpm, or vite.
globs: "*.ts, *.tsx, *.html, *.css, *.js, *.jsx, package.json"
alwaysApply: false
---

## Project Overview

This is a Bun-based TypeScript/JavaScript playground for experimentation with APIs and technologies. The project follows a minimal structure that grows organically while maintaining consistency with Bun tooling.

## Development Commands

```bash
# Install dependencies
cd project && bun install

# Run the main entry point
cd project && bun run index.ts

# Run with hot reload for development
cd project && bun --hot index.ts

# Run tests
cd project && bun test

# Run a specific test file
cd project && bun test path/to/test.test.ts

# Build frontend assets
cd project && bun build index.html
cd project && bun build style.css
```

## Bun-First Development

Default to using Bun instead of Node.js:

- Use `bun <file>` instead of `node <file>` or `ts-node <file>`
- Use `bun test` instead of `jest` or `vitest`
- Use `bun build <file.html|file.ts|file.css>` instead of `webpack` or `esbuild`
- Use `bun install` instead of `npm install` or `yarn install` or `pnpm install`
- Use `bun run <script>` instead of `npm run <script>` or `yarn run <script>` or `pnpm run <script>`
- Bun automatically loads .env, so don't use dotenv.

## APIs

- `Bun.serve()` supports WebSockets, HTTPS, and routes. Don't use `express`.
- `bun:sqlite` for SQLite. Don't use `better-sqlite3`.
- `Bun.redis` for Redis. Don't use `ioredis`.
- `Bun.sql` for Postgres. Don't use `pg` or `postgres.js`.
- `WebSocket` is built-in. Don't use `ws`.
- Prefer `Bun.file` over `node:fs`'s readFile/writeFile
- Bun.$`ls` instead of execa.

## Project Structure

Following the AGENTS.md guidelines adapted for TypeScript/Bun:

```
/Users/junguo/code/playground/
├── project/                # Bun project files
│   ├── api/                # API test files (.hurl files)
│   ├── src/                # Runtime code (create as needed)
│   ├── tests/              # Test files (create as needed)
│   ├── index.ts            # Main entry point
│   ├── package.json        # Bun package configuration
│   ├── tsconfig.json       # TypeScript configuration
│   └── bun.lock           # Bun dependency lockfile
├── experiments/            # Throwaway spikes with README
├── scripts/                # Reusable shell helpers
├── assets/                 # Shared fixtures and documentation
├── .env                    # Environment variables (do not commit)
├── CLAUDE.md               # Project documentation
├── dockerfile              # Docker configuration
└── README.md              # Basic setup instructions
```

## Testing

Use `bun test` to run tests. Create test files in `tests/` directory following the pattern `test_<module>.ts`.

```ts#tests/example.test.ts
import { test, expect } from "bun:test";

test("hello world", () => {
  expect(1).toBe(1);
});
```

## Frontend Development

Use HTML imports with `Bun.serve()`. Don't use `vite`. HTML imports fully support React, CSS, Tailwind.

Server:

```ts#index.ts
import index from "./index.html"

Bun.serve({
  routes: {
    "/": index,
    "/api/users/:id": {
      GET: (req) => {
        return new Response(JSON.stringify({ id: req.params.id }));
      },
    },
  },
  // optional websocket support
  websocket: {
    open: (ws) => {
      ws.send("Hello, world!");
    },
    message: (ws, message) => {
      ws.send(message);
    },
    close: (ws) => {
      // handle close
    }
  },
  development: {
    hmr: true,
    console: true,
  }
})
```

HTML files can import .tsx, .jsx or .js files directly and Bun's bundler will transpile & bundle automatically. `<link>` tags can point to stylesheets and Bun's CSS bundler will bundle.

```html#index.html
<html>
  <body>
    <h1>Hello, world!</h1>
    <script type="module" src="./frontend.tsx"></script>
  </body>
</html>
```

## API Testing

This playground includes `.hurl` files for testing various AI API endpoints in the `project/api/` directory:
- `project/api/anthropic.hurl` - Kimi API requests in Anthropic format
- `project/api/openai.hurl` - Kimi API requests in OpenAI format
- `project/api/openai-model.hurl` - Model listing API requests

These can be run with tools like [Hurl](https://hurl.dev/) for API testing.

## Environment Configuration

The `.env` file contains API configurations. Never commit credentials or tokens. Use `.env.example` with placeholders for sharing configuration templates.

## Docker Support

A `dockerfile` is provided for containerized development with Claude Code.

For more information, read the Bun API docs in `node_modules/bun-types/docs/**.md`.