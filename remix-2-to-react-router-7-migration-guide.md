# Complete Migration Guide: Remix 2 to React Router 7

> **Last Updated:** December 2025
> **React Router Version:** 7.10.1
> **Source:** Official React Router Documentation

---

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Migration Steps](#migration-steps)
   - [Step 1: Adopt Future Flags](#step-1-adopt-future-flags)
   - [Step 2: Update Dependencies](#step-2-update-dependencies)
   - [Step 3: Update Scripts](#step-3-update-scripts)
   - [Step 4: Add routes.ts File](#step-4-add-routests-file)
   - [Step 5: Add React Router Config](#step-5-add-react-router-config)
   - [Step 6: Update Vite Config](#step-6-update-vite-config)
   - [Step 7: Enable Type Safety](#step-7-enable-type-safety)
   - [Step 8: Update Entry Files](#step-8-update-entry-files)
   - [Step 9: Update AppLoadContext Types](#step-9-update-apploadcontext-types)
4. [Breaking Changes & Important Notes](#breaking-changes--important-notes)
5. [Type Safety Improvements](#type-safety-improvements)
6. [Routing Configuration](#routing-configuration)
7. [Common Issues & Troubleshooting](#common-issues--troubleshooting)
8. [Testing the Migration](#testing-the-migration)
9. [Deployment Considerations](#deployment-considerations)
10. [Additional Resources](#additional-resources)

---

## Introduction

### What is React Router 7?

React Router v7 is the next major version of Remix after v2. It represents the convergence of Remix's framework features back into React Router proper, bringing everything you love about Remix into the React Router ecosystem.

### Why Migrate?

- **Non-breaking upgrade** - If you've enabled all Remix v2 future flags, the migration is mostly dependency updates
- **Better type safety** - New `typegen` system provides first-class TypeScript support
- **Simplified packages** - Consolidated into fewer, clearer packages
- **Bridge to React 19** - Smoothest path from React 18 to React 19
- **Continued support** - React Router 7 is the maintained, forward-looking version

### What's New in React Router 7?

1. **Enhanced Type Safety** - Automatic type generation for routes, loaders, and params
2. **Improved Routing** - `routes.ts` configuration file for explicit route management
3. **Package Consolidation** - Simpler dependency tree
4. **Pre-rendering Support** - Static page generation capabilities
5. **Better Developer Experience** - Improved HMR and dev tooling

---

## Prerequisites

### Minimum Version Requirements

React Router v7 requires:
- **Node.js** >= 20
- **React** >= 18
- **React DOM** >= 18

### Before You Start

1. **Adopt all Remix v2 future flags** - This is critical for a smooth migration
2. **Commit all changes** - Ensure your git working tree is clean
3. **Test thoroughly** - Make sure your Remix v2 app works correctly
4. **Backup your project** - Create a backup or work on a separate branch

### Recommended Approach

```bash
# Create a new branch for migration
git checkout -b migrate-to-react-router-7

# Ensure all tests pass
npm test

# Commit before starting
git add .
git commit -m "Pre-migration checkpoint"
```

---

## Migration Steps

### Step 1: Adopt Future Flags

**👉 Enable all Remix v2 future flags**

Before migrating, ensure all future flags are enabled in your `vite.config.ts`:

```typescript
// vite.config.ts
import { vitePlugin as remix } from "@remix-run/dev";

export default {
  plugins: [
    remix({
      future: {
        // Adopt all v3 future flags
        v3_fetcherPersist: true,
        v3_relativeSplatPath: true,
        v3_throwAbortReason: true,
        v3_routeConfig: true,
        v3_singleFetch: true,
        v3_lazyRouteDiscovery: true,
      },
    }),
  ],
};
```

**Testing:**
After enabling flags, run your application and tests to ensure everything still works.

---

### Step 2: Update Dependencies

Most "shared" APIs that used to be re-exported through runtime-specific packages (`@remix-run/node`, `@remix-run/cloudflare`, etc.) have been consolidated into `react-router` in v7.

#### Automated Approach (Recommended)

**👉 Use the official codemod:**

```bash
npx codemod remix/2/react-router/upgrade
```

This codemod will:
- Update all package references in `package.json`
- Update import statements throughout your codebase
- Handle most of the manual work automatically

**⚠️ Important:** Commit your changes before running the codemod so you can revert if needed!

After running the codemod:

```bash
npm install
```

#### Manual Approach

If you prefer manual migration, here's the package mapping:

##### Package Mapping Table

| Remix v2 Package | → | React Router v7 Package |
|-----------------|---|------------------------|
| `@remix-run/architect` | → | `@react-router/architect` |
| `@remix-run/cloudflare` | → | `@react-router/cloudflare` |
| `@remix-run/dev` | → | `@react-router/dev` |
| `@remix-run/express` | → | `@react-router/express` |
| `@remix-run/fs-routes` | → | `@react-router/fs-routes` |
| `@remix-run/node` | → | `@react-router/node` |
| `@remix-run/react` | → | `react-router` |
| `@remix-run/route-config` | → | `@react-router/dev` |
| `@remix-run/routes-option-adapter` | → | `@react-router/remix-routes-option-adapter` |
| `@remix-run/serve` | → | `@react-router/serve` |
| `@remix-run/server-runtime` | → | `react-router` |
| `@remix-run/testing` | → | `react-router` |

##### Import Changes

**Before (Remix v2):**
```typescript
import { redirect } from "@remix-run/node";
import { useLoaderData, Form } from "@remix-run/react";
import { json } from "@remix-run/node";
```

**After (React Router v7):**
```typescript
import { redirect } from "react-router";
import { useLoaderData, Form } from "react-router";
import { json } from "react-router";
```

**⚠️ Runtime-Specific Imports:**

Only import runtime-specific APIs from their respective packages:

```typescript
// Still import from runtime-specific packages:
import { createFileSessionStorage } from "@react-router/node";
import { createWorkersKVSessionStorage } from "@react-router/cloudflare";
```

---

### Step 3: Update Scripts

**👉 Update your `package.json` scripts:**

#### Script Changes Table

| Script | Remix v2 | → | React Router v7 |
|--------|----------|---|-----------------|
| `dev` | `remix vite:dev` | → | `react-router dev` |
| `build` | `remix vite:build` | → | `react-router build` |
| `start` | `remix-serve build/server/index.js` | → | `react-router-serve build/server/index.js` |
| `typecheck` | `tsc` | → | `react-router typegen && tsc` |

#### Example package.json

```json
{
  "scripts": {
    "dev": "react-router dev",
    "build": "react-router build",
    "start": "react-router-serve build/server/index.js",
    "typecheck": "react-router typegen && tsc"
  }
}
```

---

### Step 4: Add routes.ts File

React Router v7 introduces a new `app/routes.ts` configuration file for explicit route management.

#### Option A: Config-Based Routing (New Approach)

**👉 Create `app/routes.ts`:**

```typescript
import {
  type RouteConfig,
  route,
  index,
  layout,
  prefix,
} from "@react-router/dev/routes";

export default [
  index("routes/home.tsx"),
  route("about", "routes/about.tsx"),

  layout("routes/dashboard/layout.tsx", [
    route("dashboard", "routes/dashboard/index.tsx"),
    route("dashboard/settings", "routes/dashboard/settings.tsx"),
  ]),

  // Nested routes
  route("blog", "routes/blog.tsx", [
    index("routes/blog/index.tsx"),
    route(":slug", "routes/blog/post.tsx"),
  ]),
] satisfies RouteConfig;
```

#### Option B: File-Based Routing (Remix-Compatible)

If you want to keep your existing file-based routing structure:

**👉 Install the fs-routes package:**

```bash
npm install @react-router/fs-routes
```

**👉 Create `app/routes.ts`:**

```typescript
import { type RouteConfig } from "@react-router/dev/routes";
import { flatRoutes } from "@react-router/fs-routes";

export default flatRoutes() satisfies RouteConfig;
```

This maintains Remix v2's file-based routing conventions, making migration easier.

**Custom directory:**

```typescript
export default flatRoutes({
  rootDirectory: "file-routes",
}) satisfies RouteConfig;
```

#### Route Configuration Helpers

- `route(path, file, children?)` - Define a route
- `index(file)` - Define an index route
- `layout(file, children)` - Define a layout route
- `prefix(path, routes)` - Add path prefix to multiple routes
- `relative(dir)` - Create route helpers relative to a directory

---

### Step 5: Add React Router Config

**👉 Create `react-router.config.ts` in your project root:**

```typescript
import type { Config } from "@react-router/dev/config";

export default {
  // Server-side rendering (SSR) by default
  ssr: true,

  // Optional: specify app directory
  appDirectory: "app",

  // Optional: server build target
  serverBuildFile: "index.js",

  // Optional: configure future flags
  future: {
    // Enable future features
  },
} satisfies Config;
```

**Common Configuration Options:**

```typescript
export default {
  ssr: true,  // Enable/disable SSR
  basename: "/app",  // Base path for deployment
  buildDirectory: "build",  // Output directory
  serverBuildFile: "index.js",  // Server entry filename

  // Pre-rendering for static pages
  async prerender({ getStaticPaths }) {
    return await getStaticPaths();
  },
} satisfies Config;
```

---

### Step 6: Update Vite Config

**👉 Update `vite.config.ts`:**

**Before (Remix v2):**
```typescript
import { vitePlugin as remix } from "@remix-run/dev";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [remix()],
});
```

**After (React Router v7):**
```typescript
import { reactRouter } from "@react-router/dev/vite";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [reactRouter()],
});
```

**With custom config:**

```typescript
import { reactRouter } from "@react-router/dev/vite";
import { defineConfig } from "vite";
import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig({
  plugins: [
    reactRouter(),
    tsconfigPaths(),
  ],
});
```

---

### Step 7: Enable Type Safety

React Router v7 introduces automatic type generation for route modules.

#### 7.1: Add `.react-router/` to `.gitignore`

```bash
echo ".react-router/" >> .gitignore
```

React Router generates types into this directory automatically.

#### 7.2: Update `tsconfig.json`

```json
{
  "include": [
    ".react-router/types/**/*",
    "app/**/*"
  ],
  "compilerOptions": {
    "rootDirs": [".", "./.react-router/types"],
    "types": ["@react-router/dev"],

    // Optional but recommended
    "verbatimModuleSyntax": true
  }
}
```

**Key changes:**
- `include`: Add `.react-router/types/**/*`
- `rootDirs`: Add `./.react-router/types` for type imports
- `verbatimModuleSyntax`: Auto-imports types with `type` modifier

#### 7.3: Generate Types

Types are generated automatically during development, but for CI/CD:

```bash
react-router typegen
```

**In package.json:**

```json
{
  "scripts": {
    "typecheck": "react-router typegen && tsc"
  }
}
```

#### 7.4: Using Generated Types

**In route modules:**

```typescript
import type { Route } from "./+types/my-route";

// Type-safe loader
export async function loader({ params }: Route.LoaderArgs) {
  // params are automatically typed!
  const id = params.id;  // string (inferred from route config)

  return { user: { name: "Alice" } };
}

// Type-safe component
export default function MyRoute({ loaderData }: Route.ComponentProps) {
  // loaderData.user is automatically typed!
  return <h1>{loaderData.user.name}</h1>;
}
```

---

### Step 8: Update Entry Files

#### 8.1: Update `app/entry.server.tsx`

**Before (Remix v2):**
```typescript
import { RemixServer } from "@remix-run/react";
import { renderToString } from "react-dom/server";
import type { EntryContext } from "@remix-run/node";

export default function handleRequest(
  request: Request,
  responseStatusCode: number,
  responseHeaders: Headers,
  remixContext: EntryContext
) {
  const markup = renderToString(
    <RemixServer context={remixContext} url={request.url} />
  );

  responseHeaders.set("Content-Type", "text/html");

  return new Response("<!DOCTYPE html>" + markup, {
    status: responseStatusCode,
    headers: responseHeaders,
  });
}
```

**After (React Router v7):**
```typescript
import { ServerRouter } from "react-router";
import { renderToString } from "react-dom/server";
import type { EntryContext } from "react-router";

export default function handleRequest(
  request: Request,
  responseStatusCode: number,
  responseHeaders: Headers,
  reactRouterContext: EntryContext
) {
  const markup = renderToString(
    <ServerRouter context={reactRouterContext} url={request.url} />
  );

  responseHeaders.set("Content-Type", "text/html");

  return new Response("<!DOCTYPE html>" + markup, {
    status: responseStatusCode,
    headers: responseHeaders,
  });
}
```

**Key changes:**
- `RemixServer` → `ServerRouter`
- `@remix-run/react` → `react-router`
- `remixContext` → `reactRouterContext` (parameter name)

#### 8.2: Update `app/entry.client.tsx`

**Before (Remix v2):**
```typescript
import { RemixBrowser } from "@remix-run/react";
import { startTransition, StrictMode } from "react";
import { hydrateRoot } from "react-dom/client";

startTransition(() => {
  hydrateRoot(
    document,
    <StrictMode>
      <RemixBrowser />
    </StrictMode>
  );
});
```

**After (React Router v7):**
```typescript
import { HydratedRouter } from "react-router/dom";
import { startTransition, StrictMode } from "react";
import { hydrateRoot } from "react-dom/client";

startTransition(() => {
  hydrateRoot(
    document,
    <StrictMode>
      <HydratedRouter />
    </StrictMode>
  );
});
```

**Key changes:**
- `RemixBrowser` → `HydratedRouter`
- `@remix-run/react` → `react-router/dom`

---

### Step 9: Update AppLoadContext Types

If you use custom `AppLoadContext`, you need to update type declarations.

**👉 Create or update a type declaration file (e.g., `app/types/context.d.ts`):**

**Before (Remix v2):**
```typescript
import "@remix-run/node";

declare module "@remix-run/node" {
  interface AppLoadContext {
    // Your custom context properties
    userId: string;
    cloudflare: {
      env: {
        MY_KV: KVNamespace;
      };
    };
  }
}
```

**After (React Router v7):**
```typescript
import "react-router";

declare module "react-router" {
  interface AppLoadContext {
    // Your custom context properties
    userId: string;
    cloudflare: {
      env: {
        MY_KV: KVNamespace;
      };
    };
  }
}
```

**Key change:**
- `@remix-run/node` → `react-router`

---

## Breaking Changes & Important Notes

### Package Consolidation

Most APIs now come from `react-router` instead of runtime-specific packages:

```typescript
// ✅ Import from react-router
import {
  redirect,
  json,
  useLoaderData,
  Form,
  Link,
  useNavigate,
  // ... most APIs
} from "react-router";

// ✅ Only runtime-specific APIs from adapters
import { createFileSessionStorage } from "@react-router/node";
import { createWorkersKVSessionStorage } from "@react-router/cloudflare";
```

### Import Path Changes

All `@remix-run/*` imports need updating to either:
- `react-router` (for most APIs)
- `@react-router/*` (for specific adapters/tools)

### No Breaking Changes If Future Flags Enabled

If you've enabled all Remix v2 future flags:
- Route modules work the same
- Loaders and actions have the same signature
- Components render the same way
- Navigation works identically

### Version Compatibility

React Router v7 is designed to be a non-breaking upgrade for:
- ✅ Remix v2 apps with all future flags enabled
- ✅ React Router v6 apps (with migration path)

---

## Type Safety Improvements

### What's New in React Router v7 Type Safety?

#### 1. Automatic Type Generation

React Router v7 generates route-specific types automatically:

```typescript
// Generated types in .react-router/types/
import type { Route } from "./+types/products.$id";

export async function loader({ params }: Route.LoaderArgs) {
  // params.id is typed as string (from route pattern)
  const product = await getProduct(params.id);
  return { product };
}

export default function Product({ loaderData }: Route.ComponentProps) {
  // loaderData.product is automatically typed!
  return <h1>{loaderData.product.name}</h1>;
}
```

#### 2. Type-Safe Route Params

URL parameters are inferred from your route configuration:

```typescript
// Route: "products/:id/reviews/:reviewId"

// TypeScript knows: params.id and params.reviewId are strings
export async function loader({ params }: Route.LoaderArgs) {
  params.id;  // string ✅
  params.reviewId;  // string ✅
  params.unknown;  // ❌ TypeScript error!
}
```

#### 3. Type-Safe Loader Data

```typescript
export async function loader() {
  return {
    user: { name: "Alice", age: 30 },
    posts: [{ id: 1, title: "Hello" }]
  };
}

export default function Component({ loaderData }: Route.ComponentProps) {
  loaderData.user.name;  // "Alice" - fully typed ✅
  loaderData.user.invalid;  // ❌ TypeScript error!
}
```

#### 4. Type-Safe Actions

```typescript
export async function action({ request }: Route.ActionArgs) {
  const formData = await request.formData();
  // Type-safe form handling
  return { success: true };
}
```

### Enabling Type-Only Auto-Imports

With `verbatimModuleSyntax` enabled in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "verbatimModuleSyntax": true
  }
}
```

TypeScript will auto-import with the `type` modifier:

```typescript
// Auto-imported as:
import type { Route } from "./+types/my-route";
// Instead of:
import { Route } from "./+types/my-route";
```

This helps bundlers detect type-only modules for tree-shaking.

### Benefits Over Remix v2

| Feature | Remix v2 | React Router v7 |
|---------|----------|-----------------|
| Route params typing | Manual type assertions | Automatic inference |
| Loader data typing | Manual type annotations | Automatic inference |
| Type generation | Manual setup required | Built-in typegen |
| IDE autocomplete | Limited | Full route-aware autocomplete |
| Type safety | Good | Excellent |

---

## Routing Configuration

### Config-Based vs File-Based Routing

React Router v7 supports both approaches:

#### Config-Based Routing

**Advantages:**
- Explicit route structure
- Easy to refactor
- Type-safe route helpers
- No file naming conventions to remember

**Example:**

```typescript
// app/routes.ts
import { type RouteConfig, route, index, layout } from "@react-router/dev/routes";

export default [
  index("routes/home.tsx"),

  layout("routes/auth/layout.tsx", [
    route("login", "routes/auth/login.tsx"),
    route("register", "routes/auth/register.tsx"),
  ]),

  route("products", "routes/products.tsx", [
    index("routes/products/index.tsx"),
    route(":id", "routes/products/detail.tsx"),
    route(":id/edit", "routes/products/edit.tsx"),
  ]),
] satisfies RouteConfig;
```

#### File-Based Routing

**Advantages:**
- Familiar Remix convention
- Easy migration from Remix v2
- Co-locate routes with files

**Example:**

```typescript
// app/routes.ts
import { type RouteConfig } from "@react-router/dev/routes";
import { flatRoutes } from "@react-router/fs-routes";

export default flatRoutes() satisfies RouteConfig;
```

**File structure:**

```
app/
├── routes/
│   ├── _index.tsx          → /
│   ├── about.tsx            → /about
│   ├── products._index.tsx  → /products
│   ├── products.$id.tsx     → /products/:id
│   └── dashboard/
│       ├── _layout.tsx      → layout
│       └── settings.tsx     → /dashboard/settings
└── routes.ts
```

### Migration Strategy

**Recommended approach:**

1. **Start with file-based routing** using `@react-router/fs-routes`
2. **Gradually migrate** to config-based routing as you refactor
3. **Mix both approaches** if needed - you can have some routes in config and others file-based

---

## Common Issues & Troubleshooting

### Issue 1: Codemod Doesn't Update Everything

**Problem:** Some imports or packages aren't updated by the codemod.

**Solution:**
- Manually search for remaining `@remix-run` imports:
  ```bash
  grep -r "@remix-run" app/
  ```
- Update them to `react-router` or `@react-router/*`

### Issue 2: Type Generation Fails

**Problem:** `react-router typegen` produces errors.

**Solution:**
- Ensure `routes.ts` exports a valid `RouteConfig`
- Check that all route module files exist
- Verify `tsconfig.json` includes `.react-router/types/**/*`
- Delete `.react-router/` and regenerate:
  ```bash
  rm -rf .react-router
  react-router typegen
  ```

### Issue 3: Import Resolution Errors

**Problem:** TypeScript can't find imports from `react-router`.

**Solution:**
- Run `npm install` after updating dependencies
- Ensure `node_modules` is up to date
- Restart your TypeScript server (VS Code: Cmd+Shift+P → "TypeScript: Restart TS Server")

### Issue 4: Runtime Module Not Found

**Problem:** Runtime-specific functions (like `createFileSessionStorage`) not found.

**Solution:**
- Import from adapter packages, not `react-router`:
  ```typescript
  // ❌ Wrong
  import { createFileSessionStorage } from "react-router";

  // ✅ Correct
  import { createFileSessionStorage } from "@react-router/node";
  ```

### Issue 5: Vite Plugin Error

**Problem:** Vite fails to start after updating plugin.

**Solution:**
- Clear Vite cache:
  ```bash
  rm -rf node_modules/.vite
  ```
- Ensure correct plugin import:
  ```typescript
  import { reactRouter } from "@react-router/dev/vite";
  ```

### Issue 6: Routes Not Matching

**Problem:** Routes don't match after migration.

**Solution:**
- Check `routes.ts` configuration
- Verify route paths don't have leading slashes (use `about`, not `/about`)
- Ensure nested routes are properly configured

### Issue 7: Build Fails

**Problem:** Production build fails.

**Solution:**
- Run `react-router typegen` before building
- Check for TypeScript errors: `npm run typecheck`
- Ensure all route modules export required functions
- Verify `react-router.config.ts` is valid

---

## Testing the Migration

### Step-by-Step Testing

#### 1. Development Server

```bash
npm run dev
```

**Check:**
- ✅ Server starts without errors
- ✅ Hot module replacement (HMR) works
- ✅ All routes load correctly
- ✅ Navigation between routes works
- ✅ Loaders and actions execute properly

#### 2. Type Checking

```bash
npm run typecheck
```

**Check:**
- ✅ No TypeScript errors
- ✅ Generated types exist in `.react-router/`
- ✅ Route types are correctly inferred

#### 3. Build Verification

```bash
npm run build
```

**Check:**
- ✅ Build completes without errors
- ✅ Client and server bundles created
- ✅ No warnings about missing modules

#### 4. Production Server

```bash
npm run start
```

**Check:**
- ✅ Server starts successfully
- ✅ All routes work in production mode
- ✅ SSR renders correctly
- ✅ Client-side hydration works

#### 5. Automated Tests

```bash
npm test
```

**Check:**
- ✅ All existing tests pass
- ✅ Integration tests work with new imports
- ✅ No broken dependencies

### Testing Checklist

- [ ] All pages load without errors
- [ ] Forms and actions work correctly
- [ ] Navigation (Link, useNavigate) works
- [ ] Loaders fetch data properly
- [ ] Error boundaries catch errors
- [ ] Protected routes redirect correctly
- [ ] Search params and URL state work
- [ ] File uploads still function
- [ ] Authentication/authorization works
- [ ] Third-party integrations work

---

## Deployment Considerations

### Platform-Specific Adapters

#### Cloudflare Workers

```typescript
// react-router.config.ts
import type { Config } from "@react-router/dev/config";

export default {
  ssr: true,
  serverModuleFormat: "esm",
} satisfies Config;
```

**Dependencies:**

```bash
npm install @react-router/cloudflare
```

#### Node.js with Express

```bash
npm install @react-router/express
```

#### Architect (AWS)

```bash
npm install @react-router/architect
```

### Environment Variables

No changes needed - environment variables work the same way:

```typescript
// Server-side
const apiKey = process.env.API_KEY;

// Client-side (must be exposed via build config)
const publicKey = process.env.PUBLIC_KEY;
```

### Build Output

The build output structure is similar to Remix v2:

```
build/
├── client/        # Client-side JavaScript/CSS
│   └── assets/
└── server/        # Server-side bundle
    └── index.js
```

### Deployment Scripts

Update deployment scripts if they reference `remix` commands:

```json
{
  "scripts": {
    "deploy": "npm run build && deploy-script"
  }
}
```

---

## Additional Resources

### Official Documentation

- **React Router Docs:** https://reactrouter.com
- **Upgrading from Remix:** https://reactrouter.com/upgrading/remix
- **Migration Announcement:** https://remix.run/blog/react-router-v7
- **API Reference:** https://api.reactrouter.com/v7/

### Tools & Utilities

- **Official Codemod:** https://codemod.com/registry/remix-2-react-router-upgrade
  ```bash
  npx codemod remix/2/react-router/upgrade
  ```

- **Type Generation:**
  ```bash
  react-router typegen
  ```

### Community Resources

- **GitHub Repository:** https://github.com/remix-run/react-router
- **Discord Community:** https://rmx.as/discord
- **Issue Tracker:** https://github.com/remix-run/react-router/issues

### Migration Examples

- **Official Templates:** https://github.com/remix-run/react-router-templates
- **Community Examples:**
  - [Migration Blog Post](https://dev.to/kahwee/migrating-from-remix-to-react-router-v7-4gfo)
  - [GitHub Migration Example](https://github.com/santosh-shetty/Remix-v2-to-React-Router-v7)

### Video Tutorials

- [React Router v7 File-Based Routing](https://www.youtube.com/watch?v=Nigg6w8pRow)
- [How React Router v7 Became Type-Safe](https://www.youtube.com/watch?v=ferLCqcLcGU)

### Best Practices

1. **Use the codemod** - It handles most of the tedious work
2. **Enable all future flags first** - Makes migration smoother
3. **Test incrementally** - Test after each major step
4. **Start with file-based routing** - Easier migration path
5. **Adopt typegen early** - Better developer experience
6. **Update incrementally** - Don't rush the migration

---

## Quick Reference

### Command Comparison

| Task | Remix v2 | React Router v7 |
|------|----------|-----------------|
| Dev server | `remix vite:dev` | `react-router dev` |
| Build | `remix vite:build` | `react-router build` |
| Start server | `remix-serve build/server/index.js` | `react-router-serve build/server/index.js` |
| Type generation | N/A | `react-router typegen` |

### Import Quick Reference

```typescript
// Most imports from react-router
import {
  redirect,
  json,
  useLoaderData,
  useActionData,
  Form,
  Link,
  NavLink,
  useNavigate,
  useLocation,
  useParams,
  useSearchParams,
  useFetcher,
  useRouteError,
} from "react-router";

// Server components
import { HydratedRouter } from "react-router/dom";
import { ServerRouter } from "react-router";

// Runtime-specific
import { createFileSessionStorage } from "@react-router/node";
import { createWorkersKVSessionStorage } from "@react-router/cloudflare";

// Dev tools
import { reactRouter } from "@react-router/dev/vite";
import { type RouteConfig } from "@react-router/dev/routes";
```

---

## Conclusion

Migrating from Remix v2 to React Router v7 is designed to be straightforward, especially if you've adopted all future flags. The key steps are:

1. ✅ Adopt all Remix v2 future flags
2. ✅ Run the official codemod
3. ✅ Update configuration files
4. ✅ Enable type safety
5. ✅ Test thoroughly

React Router v7 brings enhanced type safety, better tooling, and a clearer path forward for your applications.

**Need help?** Join the [React Router Discord](https://rmx.as/discord) community!

---

**Document Version:** 1.0
**Last Updated:** December 2025
**Maintained By:** Community Contributions Welcome

---

## License

This guide is based on official React Router documentation and community resources.
Documentation © React Router Team
Guide compilation © 2025