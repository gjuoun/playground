# Elysia + Bun — Advanced REST Guide (Dec 13, 2025)

This doc condenses the official Elysia and Bun documentation into a senior-friendly, execution-ready walkthrough. Primary focus: high-performance REST APIs on Bun with Elysia ≥1.2.

## 0. Stack Snapshot
- Runtime: Bun — high throughput for HTTP and streaming.
- Framework: Elysia 1.2+ (REST-first). Last doc update: 2025-12-03.
- Schema: Standard Schema (Zod/Valibot/etc.) or `Elysia.t` for validation.

## 1. Project Setup
```bash
bun create elysia my-app
cd my-app
bun install
bun dev            # hot reload
```
(Default scaffold uses TypeScript and ESM.)

## 2. Minimal REST (Express-to-Elysia translation)
```ts
import { Elysia } from 'elysia'

new Elysia()
  .get('/health', () => ({ status: 'ok' }))
  .post('/users', ({ body }) => {
    // body is already parsed (json) by default
    return { id: crypto.randomUUID(), ...body }
  })
  .listen(3000)
```
Notes:
- Route methods mirror Express (`get`, `post`, `put`, `patch`, `delete`).
- Handlers receive a single context object (`body`, `query`, `params`, `headers`, `set`, etc.).
- Responses can be plain objects (auto JSON), `Response`, `Bun.file`, streams, etc.

## 3. Validation & Types with Zod (Standard Schema)
Elysia supports **Standard Schema**, so you can drop Zod (or Valibot/Joi/etc.) schemas directly into route options—no extra plugin required.
```ts
import { Elysia } from 'elysia'
import { z } from 'zod'

const User = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  role: z.enum(['admin', 'user']).default('user')
})

new Elysia()
  .post('/users', ({ body }) => ({ id: crypto.randomUUID(), ...body }), {
    body: User,                     // request validation
    response: User.extend({ id: z.string().uuid() }) // response validation
  })
```
- Use `z.coerce.number()` for numeric params/query to mirror TypeBox coercion.
- Mix validators per part (e.g., params with Zod, query with Valibot); Standard Schema lets multiple libraries coexist in one handler.

## 4. Middleware attachment patterns (event-driven, no `next()`)
Elysia lets you hook at specific lifecycle events or scope them. Key ways:

### 4.1 Route-level (options object, per-route)
```ts
import { z } from 'zod'
new Elysia()
  .get('/private', ({ set }) => 'ok', {
    beforeHandle({ headers, set }) {
      if (headers.get('authorization') !== 'Bearer demo') {
        set.status = 401; return 'unauthorized'
      }
    },
    response: z.string()
  })
```
`beforeHandle` returns a value to skip the handler—good for auth checks.

### 4.2 Global lifecycle hooks
```ts
new Elysia()
  .onRequest(({ request }) => console.log('req', request.url))
  .onError(({ code, error, set }) => { set.status = 500; return { error: error.message } })
  .get('/', () => 'hi')
```
Hooks registered before routes apply to subsequent routes; order matters.

### 4.3 Guards (schema + hooks for many routes)
```ts
const guard = new Elysia().guard({
  params: z.object({ id: z.string().uuid() }),
  beforeHandle({ headers, set }) {
    if (!headers.get('x-tenant')) { set.status = 400; return 'missing tenant' }
  }
})

new Elysia()
  .use(guard)
  .get('/users/:id', ({ params }) => params.id)
  .get('/orders/:id', ({ params }) => params.id)
```
Everything after `.use(guard)` inherits its schemas and hooks.

### 4.4 Group + guard (prefix + bulk middleware)
```ts
import { z } from 'zod'
new Elysia()
  .group('/admin', {
    params: z.object({ id: z.string().uuid() }),
    beforeHandle({ headers, set }) {
      if (headers.get('x-role') !== 'admin') { set.status = 403; return 'forbidden' }
    }
  }, app => app
    .get('/users/:id', ({ params }) => params.id)
    .delete('/users/:id', ({ params }) => ({ deleted: params.id }))
  )
```
Schemas/hooks declared on the group apply inside the callback only.

### 4.5 derive / resolve (per-request context injection)
```ts
new Elysia()
  .derive(({ headers }) => ({ token: headers.get('authorization') }))
  .resolve(({ token }) => ({ userId: token?.slice(-6) || null })) // runs after validation
  .get('/me', ({ userId, set }) => userId ?? (set.status = 401, 'unauthenticated'))
```
Use derive for pre-validation context, resolve for post-validation context.

### 4.6 Plugins (`.use`) to package middleware
```ts
// auth-plugin.ts
export const authPlugin = () =>
  new Elysia()
    .onRequest(({ request, set }) => {
      if (!request.headers.get('authorization')) { set.status = 401; return 'no auth' }
    })

// main
import { authPlugin } from './auth-plugin'
new Elysia().use(authPlugin()).get('/secure', () => 'ok')
```
Plugins are isolated instances; hooks apply to that instance and descendants.

### 4.7 Macros (reusable route options)
```ts
import { z } from 'zod'
const authMacro = new Elysia().macro('auth', () => ({
  header: z.object({ authorization: z.string() }),
  beforeHandle({ headers, set }) {
    if (!headers.authorization.startsWith('Bearer ')) { set.status = 401; return 'bad token' }
  }
}))

new Elysia()
  .use(authMacro)
  .get('/profile', ({ headers }) => headers.authorization, { auth: true })
```
Macros inject predefined hooks/schemas when `auth: true` is set on a route.

### 4.8 Order-of-registration rule
Hooks/guards/groups/plugins affect only routes defined **after** they’re registered. Place global hooks at the top; put tight-scope guards just before the routes they should cover.

## 5. Routing patterns (path params, query, JSON)
```ts
new Elysia()
  .get('/users/:id', ({ params }) => ({ id: params.id }))
  .get('/search', ({ query: { q = '' } }) => ({ q }))
  .put('/users/:id', ({ params, body }) => ({ ...body, id: params.id }))
```

## 6. Error handling
```ts
new Elysia()
  .onError(({ code, error, set }) => {
    set.status = code === 'VALIDATION' ? 400 : 500
    return { error: error.message }
  })
```
- Codes: VALIDATION, PARSE, NOT_FOUND, INTERNAL, etc.

## 7. Structured responses & files
```ts
import { file } from 'elysia' // runtime-portable helper

new Elysia()
  .get('/logo', () => file('./public/logo.svg'))      // Bun.file under the hood
  .get('/csv', () => new Response('a,b', { headers: { 'content-type': 'text/csv' } }))
```

## 8. Performance levers for REST
- Keep middleware minimal; prefer scoped `group`/`guard` instead of global chains.
- Validate inputs (Zod/Standard Schema) to fail fast; disable if micro-optimizing hot paths.
- Use `file()`/`Bun.file` for static assets; Bun streams efficiently.
- For large JSON responses, stream with `ReadableStream` if needed.

## 9. Testing REST
```ts
import { describe, it, expect } from 'bun:test'

it('creates user', async () => {
  const res = await fetch('http://localhost:3000/users', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ name: 'Ada', email: 'ada@ex.com' })
  })
  expect(res.status).toBe(200)
  const json = await res.json()
  expect(json.name).toBe('Ada')
})
```

## 10. Deploy REST
- `bun run src/index.ts` for dev; `bun build src/index.ts --compile --outfile server` for a single binary.
- Behind proxy (NGINX/Caddy) or direct TLS via Bun.serve options (`tls: { key, cert }`).

---
## 11. Performance pointers (HTTP)
- Keep hot paths thin: minimal derives/guards on critical routes.
- Prefer streaming for large payloads (Response with ReadableStream).
- Use `precompile: false` (default); enable only if cold-start latency measured.
- Benchmark with `bombardier` / `wrk` using real payload sizes.

## 12. Deploy
- Production run: `bun run src/index.ts` or `bun build src/index.ts --compile --outfile server`.
- TLS: terminate at proxy or pass Bun.serve TLS options (`tls: { key, cert }`) directly.

---
References: Elysia docs (validation, config, quick-start) updated 2025-12-03.
