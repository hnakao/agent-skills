---
name: coding-style
description: Universal coding standards, ESLint compliance, and best practices for TypeScript and Node.js development.
---

# Coding Standards & Best Practices

Universal coding standards applicable across the project, directly aligned with the strictly typed ESLint configuration. 

## When to Activate

- Starting a new project or module.
- Reviewing code for quality and maintainability.
- Refactoring existing code to follow conventions.
- Resolving ESLint errors and warnings across the project.
- Writing or modifying classes, services, and tests.

---

## 🏗 ESLint & Formatting Compliance

The project enforces strict TypeScript checking (`recommendedTypeChecked`) and Prettier formatting. Everything you write must adhere to these structural rules.

### 1. Code Formatting (Prettier)
All code must adhere to the configured Prettier rules instead of letting ESLint auto-format indents:
- **Tab Width**: 4 spaces.
- **Print Width**: 120 characters.
- **Quotes**: Single quotes (`'`).
- **Trailing Commas**: `all`.
- **Bracket Spacing**: `true`.

### 2. Class Formatting (`lines-between-class-members`)
ESLint strictly enforces empty lines between properties and methods in classes.

```typescript
// ✅ GOOD: Empty lines between methods and properties
export class MarketService {
    private isInitialized = false;

    constructor(private readonly db: Database) {}

    public async initialize(): Promise<void> {
        this.isInitialized = true;
    }

    public async stop(): Promise<void> {
        this.isInitialized = false;
    }
}
```

### 3. No Console (`no-console: warn`)
Do not use `console.log`, `console.warn`, or `console.error` in application code (except in specific utility scripts where it's explicitly disabled). Use a dedicated logger (like NestJS `Logger`).

```typescript
import { Logger } from '@nestjs/common';

// ✅ GOOD
export class AppService {
    private readonly logger = new Logger(AppService.name);

    public doWork(): void {
        this.logger.log('Working...');
    }
}

// ❌ BAD
console.log('Working...'); // Fails ESLint
```

### 4. Floating Promises (`@typescript-eslint/no-floating-promises`)
Every asynchronous Promise must be `await`ed or explicitly marked as ignored using `void`. Never leave a promise floating/unhandled.

```typescript
// ✅ GOOD: Awaiting the promise
await this.notificationService.sendEmail(user.id);

// ✅ GOOD: Explicitly marking as void if deliberately not awaited
void this.notificationService.sendEmail(user.id);

// ❌ BAD: Floating promise
this.notificationService.sendEmail(user.id);
```

### 5. Strict Type Safety (`@typescript-eslint/no-unsafe-*`)
The ESLint configuration inherits `recommendedTypeChecked`. This means the use of `any` triggers severe warnings regarding unsafe assignment, unsafe argument, and unsafe member access. 
- **NEVER** use `any`. 
- Use `unknown` and narrow the type, or define strict interfaces.

```typescript
// ✅ GOOD: Strong typing
function getMarket(id: string): Promise<Market> { ... }

// ❌ BAD: 'any' leaks and triggers unsafe usage warnings when the return value is used
function getMarket(id: any): any { ... }
```

### 6. Unused Variables (`@typescript-eslint/no-unused-vars`)
Unused variables and arguments throw strict errors. If an argument is required by a signature but not used, prefix it with `_`. Also applies to unused Data Transfer Objects (`Dto$`).

```typescript
// ✅ GOOD: Prefix unused arguments with underscore
app.get('/health', (_req, res) => {
    res.send('OK');
});

// ❌ BAD: Unused variable
app.get('/health', (req, res) => { // 'req' triggers lint error
    res.send('OK');
});
```

---

## 🧠 Code Quality Principles

### 1. Readability First
- Code is read more than written.
- Clear variable and function names.
- Self-documenting code preferred over comments.

### 2. Variable & Function Naming
```typescript
// ✅ GOOD: Descriptive names
const marketSearchQuery = 'election';
const isUserAuthenticated = true;

// ✅ GOOD: Verb-noun pattern for functions
async function fetchMarketData(marketId: string): Promise<MarketData> { ... }
function isValidEmail(email: string): boolean { ... }

// ❌ BAD: Unclear names
const q = 'election';
async function market(id: string) { ... }
```

### 3. Immutability Pattern (CRITICAL)
```typescript
// ✅ ALWAYS use spread operator
const updatedUser = {
    ...user,
    name: 'New Name',
};

// ❌ NEVER mutate directly
user.name = 'New Name'; 
```

### 4. Async/Await Best Practices
```typescript
// ✅ GOOD: Parallel execution when possible
const [users, markets, stats] = await Promise.all([
    fetchUsers(),
    fetchMarkets(),
    fetchStats(),
]);

// ❌ BAD: Sequential when unnecessary
const users = await fetchUsers();
const markets = await fetchMarkets();
const stats = await fetchStats();
```

### 5. Deep Nesting & Early Returns
Use early returns (guard clauses) to prevent nesting deeper than 2 or 3 levels.

```typescript
// ❌ BAD: Deep nesting
if (user) {
    if (user.isAdmin) {
        if (market) {
            // Do something
        }
    }
}

// ✅ GOOD: Early returns
if (!user || !user.isAdmin || !market) {
    return;
}
// Do something
```

### 6. Magic Numbers
Extract raw numbers and strings to descriptive constant variables.
```typescript
// ✅ GOOD
const MAX_RETRIES = 3;
if (retryCount > MAX_RETRIES) { ... }
```

---

## 🧪 Testing Standards (Type-Safe Focus)

When writing unit and E2E tests, ESLint type-checking applies just as strictly:

1. **Strict Mocking**: Avoid loose objects that implicitly define `any` methods, as they will trigger `no-unsafe-call`.
```typescript
// ✅ GOOD: Strict mocked typing using @golevelup/ts-jest or jest.Mocked
const mockService = createMock<MarketService>();
mockService.getMarket.mockResolvedValue(marketData);

// ❌ BAD: Loose typing generates 'any' which triggers eslint warnings when invoked
const mockService = {
    getMarket: jest.fn(),
};
```

2. **Always Await Assertions**: If an assertion or a test framework method (like Supertest's `.expect()`) returns a Promise, it must be awaited or returned to avoid floating promises.
```typescript
// ✅ GOOD
await request(app.getHttpServer()).get('/cats').expect(200);

// ❌ BAD: Missed await leads to floating promise and unreliable tests
request(app.getHttpServer()).get('/cats').expect(200);
```

3. **Cleanup Unused Test Boilerplate**: If a test auto-generates a specific module or variable (like a controller) but doesn't test it, remove it, or ESLint will fail the test file due to unused variables.
