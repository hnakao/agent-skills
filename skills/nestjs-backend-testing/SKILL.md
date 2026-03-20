---
name: nestjs-backend-testing
description: Backend Testing (NestJS)
---

# Backend Testing (NestJS)

## When to use this skill

Specific situations that should trigger this skill:

- **New feature development**: Write tests first using TDD (Test-Driven Development)
- **Adding API endpoints**: Test success and failure cases for REST and GraphQL APIs
- **Bug fixes**: Add tests to prevent regressions
- **Before refactoring**: Write tests that guarantee existing behavior
- **CI/CD setup**: Build automated test pipelines
- **NestJS DI wiring**: Verify that providers, guards, interceptors and pipes are correctly composed

---

## Input Format

### Required information

- **Framework**: NestJS (primary), Express, FastAPI, Spring Boot, etc.
- **Test tool**: Jest (default for NestJS), Pytest, Mocha/Chai, JUnit, etc.
- **Test target**: API endpoints, services, guards, pipes, interceptors, DB operations

### Optional information

- **Database**: PostgreSQL, MySQL, MongoDB, SQLite (default: in-memory / mocked)
- **ORM**: TypeORM, Prisma, Mongoose, MikroORM
- **Mocking style**: Manual mocks, `jest.fn()`, `useMocker()`, `@golevelup/ts-jest`
- **Coverage target**: 80%, 90%, etc. (default: 80%)
- **E2E tool**: Supertest (default for NestJS), TestClient, RestAssured

### Input example

```
Test the user authentication module for a NestJS API:
- Framework: NestJS + TypeScript
- ORM: TypeORM + PostgreSQL
- Test tool: Jest + Supertest
- Target: AuthService, AuthController, POST /auth/register, POST /auth/login
- Coverage: 90% or above
```

---

## Instructions

### Step 1: Set up the test environment

Install dependencies and configure Jest for both unit and e2e tests.

**Install packages**:

```bash
npm install --save-dev jest ts-jest @types/jest supertest @types/supertest @nestjs/testing
# Optional but recommended:
npm install --save-dev @golevelup/ts-jest jest-mock
```

**`jest.config.js`** (unit tests):

```js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testRegex: '.*\\.spec\\.ts$',
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/main.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};
```

**`test/jest-e2e.json`** (e2e tests):

```json
{
  "moduleFileExtensions": ["js", "json", "ts"],
  "rootDir": ".",
  "testRegex": ".e2e-spec.ts$",
  "transform": { "^.+\\.(t|j)s$": "ts-jest" },
  "testEnvironment": "node"
}
```

**`package.json` scripts**:

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:e2e": "jest --config ./test/jest-e2e.json",
    "test:ci": "jest --ci --coverage --maxWorkers=2"
  }
}
```

**`.env.test`** — always separate test environment variables:

```
DATABASE_URL=postgres://localhost:5432/myapp_test
JWT_SECRET=test-secret
```

---

### Step 2: Unit Tests — Services, Guards, Pipes

Unit tests focus on one class at a time. Always use `Test.createTestingModule()` instead of manually instantiating classes — this keeps the NestJS DI system active and makes provider overriding easy.

**Decision criteria**:

- No external I/O (pure logic) → plain Jest, no module needed
- Class uses DI providers (repository, service, config) → `Test.createTestingModule()` with mocked providers
- Class has many dependencies → use `useMocker()` for auto-mocking

**Example — Service with mocked repository**:

```typescript
// src/cats/cats.service.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { CatsService } from './cats.service';
import { Cat } from './cat.entity';

const mockCatRepository = {
  find: jest.fn(),
  findOne: jest.fn(),
  save: jest.fn(),
  delete: jest.fn(),
};

describe('CatsService', () => {
  let service: CatsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CatsService,
        {
          provide: getRepositoryToken(Cat),
          useValue: mockCatRepository,
        },
      ],
    }).compile();

    service = module.get<CatsService>(CatsService);
    jest.clearAllMocks();
  });

  describe('findAll', () => {
    it('should return an array of cats', async () => {
      const cats = [{ id: 1, name: 'Tom' }];
      mockCatRepository.find.mockResolvedValue(cats);

      const result = await service.findAll();

      expect(result).toEqual(cats);
      expect(mockCatRepository.find).toHaveBeenCalledTimes(1);
    });
  });

  describe('findOne', () => {
    it('should throw NotFoundException when cat does not exist', async () => {
      mockCatRepository.findOne.mockResolvedValue(null);

      await expect(service.findOne(999)).rejects.toThrow('Cat not found');
    });
  });
});
```

**Example — Auto-mocking with `useMocker()` (for classes with many deps)**:

```typescript
import { Test } from '@nestjs/testing';
import { createMock } from '@golevelup/ts-jest';
import { CatsController } from './cats.controller';
import { CatsService } from './cats.service';

describe('CatsController', () => {
  let controller: CatsController;
  let service: CatsService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      controllers: [CatsController],
    })
      .useMocker(createMock)
      .compile();

    controller = module.get(CatsController);
    service = module.get(CatsService);
  });

  it('should call service.findAll and return result', async () => {
    const cats = [{ id: 1, name: 'Tom' }];
    jest.spyOn(service, 'findAll').mockResolvedValue(cats);

    const result = await controller.findAll();

    expect(result).toEqual(cats);
    expect(service.findAll).toHaveBeenCalled();
  });
});
```

**Example — Testing a Guard**:

```typescript
// src/auth/jwt-auth.guard.spec.ts
import { Test } from '@nestjs/testing';
import { ExecutionContext } from '@nestjs/common';
import { JwtAuthGuard } from './jwt-auth.guard';
import { JwtService } from '@nestjs/jwt';

describe('JwtAuthGuard', () => {
  let guard: JwtAuthGuard;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        JwtAuthGuard,
        { provide: JwtService, useValue: { verify: jest.fn() } },
      ],
    }).compile();

    guard = module.get(JwtAuthGuard);
  });

  it('should deny access when no token is provided', () => {
    const context = {
      switchToHttp: () => ({
        getRequest: () => ({ headers: {} }),
      }),
    } as ExecutionContext;

    expect(guard.canActivate(context)).toBe(false);
  });
});
```

**Example — Testing a Pipe**:

```typescript
// src/pipes/parse-int.pipe.spec.ts
import { ParseIntPipe, BadRequestException } from '@nestjs/common';

describe('ParseIntPipe', () => {
  let pipe: ParseIntPipe;

  beforeEach(() => {
    pipe = new ParseIntPipe();
  });

  it('should transform a numeric string to integer', async () => {
    expect(await pipe.transform('5', { type: 'param' })).toBe(5);
  });

  it('should throw BadRequestException for non-numeric string', async () => {
    await expect(pipe.transform('abc', { type: 'param' })).rejects.toThrow(
      BadRequestException,
    );
  });
});
```

---

### Step 3: Integration Tests — Feature Module Slice

Integration tests wire up a full NestJS module (with real DI) but mock infrastructure (DB, external HTTP, email, etc.). This catches wiring bugs that unit tests miss.

```typescript
// src/cats/cats.integration.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { CatsModule } from './cats.module';
import { CatsService } from './cats.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Cat } from './cat.entity';

describe('CatsModule (integration)', () => {
  let module: TestingModule;
  let service: CatsService;

  const mockRepo = { find: jest.fn().mockResolvedValue([]) };

  beforeAll(async () => {
    module = await Test.createTestingModule({
      imports: [CatsModule],
    })
      .overrideProvider(getRepositoryToken(Cat))
      .useValue(mockRepo)
      .compile();

    service = module.get(CatsService);
  });

  afterAll(() => module.close());

  it('should resolve CatsService', () => {
    expect(service).toBeDefined();
  });

  it('should return empty array from findAll', async () => {
    await expect(service.findAll()).resolves.toEqual([]);
  });
});
```

---

### Step 4: E2E Tests — Full HTTP Flow with Supertest

E2E tests spin up a real Nest application and exercise HTTP routes end-to-end. Override providers as needed to avoid real DB or external API calls.

```typescript
// test/cats.e2e-spec.ts
import * as request from 'supertest';
import { Test } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { AppModule } from '../src/app.module';
import { CatsService } from '../src/cats/cats.service';

describe('Cats (e2e)', () => {
  let app: INestApplication;
  const mockCatsService = { findAll: jest.fn(() => [{ id: 1, name: 'Tom' }]) };

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(CatsService)
      .useValue(mockCatsService)
      .compile();

    app = moduleRef.createNestApplication();
    // Apply the same global pipes/filters as production
    app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
    await app.init();
  });

  afterAll(() => app.close());

  it('GET /cats → 200 with cat array', () => {
    return request(app.getHttpServer())
      .get('/cats')
      .expect(200)
      .expect([{ id: 1, name: 'Tom' }]);
  });

  it('POST /cats with invalid body → 400', () => {
    return request(app.getHttpServer())
      .post('/cats')
      .send({}) // missing required fields
      .expect(400);
  });
});
```

> **Fastify adapter**: If using Fastify, add `await app.getHttpAdapter().getInstance().ready()` after `app.init()`.

---

### Step 5: Authentication and Authorization Tests

**Test globally registered guards using `useExisting`**:

First, update your module registration so the guard can be overridden:

```typescript
// app.module.ts
providers: [
  { provide: APP_GUARD, useExisting: JwtAuthGuard }, // NOT useClass
  JwtAuthGuard,
]
```

Then override it in tests:

```typescript
// test/auth.e2e-spec.ts
import { MockAuthGuard } from './mocks/mock-auth.guard';

const moduleRef = await Test.createTestingModule({
  imports: [AppModule],
})
  .overrideProvider(JwtAuthGuard)
  .useClass(MockAuthGuard)
  .compile();
```

**Auth flow e2e example**:

```typescript
describe('Auth (e2e)', () => {
  let app: INestApplication;
  let accessToken: string;

  beforeAll(async () => { /* init app without mocking auth */ });
  afterAll(() => app.close());

  describe('POST /auth/register', () => {
    it('should register a new user', () => {
      return request(app.getHttpServer())
        .post('/auth/register')
        .send({ email: 'test@example.com', password: 'Password123!' })
        .expect(201)
        .expect(res => {
          expect(res.body).toHaveProperty('accessToken');
          accessToken = res.body.accessToken;
        });
    });

    it('should reject duplicate email → 409', () => {
      return request(app.getHttpServer())
        .post('/auth/register')
        .send({ email: 'test@example.com', password: 'Password123!' })
        .expect(409);
    });
  });

  describe('GET /auth/me', () => {
    it('should return current user with valid token', () => {
      return request(app.getHttpServer())
        .get('/auth/me')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200)
        .expect(res => {
          expect(res.body.email).toBe('test@example.com');
        });
    });

    it('should reject request without token → 401', () => {
      return request(app.getHttpServer()).get('/auth/me').expect(401);
    });

    it('should reject invalid token → 401', () => {
      return request(app.getHttpServer())
        .get('/auth/me')
        .set('Authorization', 'Bearer invalid-token')
        .expect(401);
    });
  });
});
```

---

### Step 6: Mocking External Dependencies

Always mock external I/O: email senders, HTTP APIs, S3, queues, etc.

**Mocking an email service provider**:

```typescript
// In your test module setup:
{
  provide: MailService,
  useValue: { sendVerificationEmail: jest.fn().mockResolvedValue(undefined) },
}
```

**Mocking time-based logic**:

```typescript
beforeEach(() => jest.useFakeTimers());
afterEach(() => jest.useRealTimers());

it('should expire token after 1 hour', () => {
  const token = generateToken();
  jest.advanceTimersByTime(60 * 60 * 1000 + 1);
  expect(isTokenExpired(token)).toBe(true);
});
```

**Mocking request-scoped providers** (advanced NestJS pattern):

```typescript
import { ContextIdFactory } from '@nestjs/core';

const contextId = ContextIdFactory.create();
jest.spyOn(ContextIdFactory, 'getByRequest').mockImplementation(() => contextId);

const scopedService = await moduleRef.resolve(RequestScopedService, contextId);
```

---

### Step 7: Pure Function Unit Tests (no framework)

For utility functions with no dependencies, skip `Test.createTestingModule()` and test directly:

```typescript
// src/utils/password.util.spec.ts
import { validatePassword } from './password.util';

describe('validatePassword', () => {
  it('should accept a valid password', () => {
    expect(validatePassword('Password123!').valid).toBe(true);
  });

  it('should reject a password shorter than 8 characters', () => {
    const { valid, errors } = validatePassword('P1!');
    expect(valid).toBe(false);
    expect(errors).toContain('Password must be at least 8 characters');
  });

  it('should return multiple errors for completely invalid input', () => {
    expect(validatePassword('pass').errors.length).toBeGreaterThan(1);
  });
});
```

---

## Output Format

### Project structure

```
src/
  cats/
    cats.controller.ts
    cats.controller.spec.ts        ← unit test (controller)
    cats.service.ts
    cats.service.spec.ts           ← unit test (service)
    cats.module.spec.ts            ← integration test (module slice)
  auth/
    jwt-auth.guard.spec.ts         ← unit test (guard)
  utils/
    password.util.spec.ts          ← unit test (pure function)
test/
  cats.e2e-spec.ts                 ← e2e test
  auth.e2e-spec.ts                 ← e2e test
  jest-e2e.json                    ← e2e Jest config
jest.config.js
.env.test
```

### Test layer summary

| Layer       | What to test                        | Tools                              | File suffix    |
|-------------|-------------------------------------|------------------------------------|----------------|
| Unit        | Single class, all deps mocked       | Jest + `Test.createTestingModule`  | `.spec.ts`     |
| Integration | Full module, infra mocked           | Jest + `overrideProvider`          | `.spec.ts`     |
| E2E         | Full HTTP request/response cycle    | Jest + Supertest                   | `.e2e-spec.ts` |

### Coverage report

```
$ npm run test:coverage

--------------------------|---------|----------|---------|---------|
File                      | % Stmts | % Branch | % Funcs | % Lines |
--------------------------|---------|----------|---------|---------|
All files                 |   92.5  |   88.3   |   95.2  |   92.8  |
 auth/                    |   95.0  |   90.0   |  100.0  |   95.0  |
  auth.service.ts         |   95.0  |   90.0   |  100.0  |   95.0  |
  jwt-auth.guard.ts       |   95.0  |   90.0   |  100.0  |   95.0  |
 cats/                    |   90.0  |   85.0   |   90.0  |   90.0  |
  cats.service.ts         |   90.0  |   85.0   |   90.0  |   90.0  |
--------------------------|---------|----------|---------|---------|
```

---

## Constraints

### Required (MUST)

1. **Test isolation**: Every test must be independently runnable
   - Reset mocks with `jest.clearAllMocks()` in `beforeEach`
   - Never depend on execution order
2. **Use `Test.createTestingModule()`**: Do not manually `new` NestJS classes with DI dependencies — this bypasses the DI system and misses wiring bugs
3. **Mirror production middleware**: Apply the same `ValidationPipe`, exception filters, and interceptors in e2e test setup as in `main.ts`
4. **Clear test names using AAA intent**: Names must read as behavior specs
   - ✅ `'should reject duplicate email → 409'`
   - ❌ `'test1'` or `'it works'`
5. **Use `useExisting` for globally registered enhancers**: Required to make `overrideProvider()` work on `APP_GUARD`, `APP_PIPE`, `APP_INTERCEPTOR`, `APP_FILTER`

### Prohibited (MUST NOT)

1. **No production database**: Use in-memory SQLite, a dedicated test DB, or mocked repositories
2. **No real external API calls**: Mock all HTTP clients, email services, S3 clients, payment SDKs
3. **No `sleep()`/`setTimeout()` in tests**: Use `jest.useFakeTimers()` for time-dependent logic
4. **No hardcoded secrets**: Reference `.env.test` or inject test values via `ConfigService` mock
5. **Do not skip `app.close()` in `afterAll`**: Open handles cause Jest to hang after the test run

---

## Common Issues

### Issue 1: Test failures caused by shared state

**Symptom**: Tests pass individually but fail when run together
**Cause**: Missing `beforeEach` reset — mock state bleeds between tests
**Fix**:
```typescript
beforeEach(() => jest.clearAllMocks());
```

---

### Issue 2: "Jest did not exit one second after the test run"

**Symptom**: Process hangs after all tests finish
**Cause**: DB connections, Nest application, or HTTP server not closed
**Fix**:
```typescript
afterAll(async () => {
  await app.close(); // closes NestJS app and all its connections
});
```

---

### Issue 3: Async test timeout

**Symptom**: `"Timeout - Async callback was not invoked within the 5000ms timeout"`
**Cause**: Missing `await` on a Promise, or genuinely slow async operation
**Fix**:
```typescript
// Bad
it('should work', () => {
  request(app.getHttpServer()).get('/cats'); // Promise never awaited
});

// Good
it('should work', async () => {
  await request(app.getHttpServer()).get('/cats').expect(200);
});
```
For slow operations (e.g. DB seed), increase timeout: `jest.setTimeout(15000)`.

---

### Issue 4: `overrideProvider()` has no effect on a global guard

**Symptom**: Test still uses the real `JwtAuthGuard` even after calling `overrideProvider()`
**Cause**: Guard registered with `useClass` in `APP_GUARD` — Nest creates a hidden provider instance that isn't accessible for override
**Fix**: Change `useClass` to `useExisting` in your module and list the guard as a separate provider (see Step 5).

---

### Issue 5: `moduleRef.get()` returns wrong instance for scoped providers

**Symptom**: `moduleRef.get(MyService)` throws or returns a stale instance
**Cause**: `get()` only works for singleton-scoped providers; request/transient providers need `resolve()`
**Fix**:
```typescript
const contextId = ContextIdFactory.create();
jest.spyOn(ContextIdFactory, 'getByRequest').mockImplementation(() => contextId);
const service = await moduleRef.resolve(MyService, contextId);
```

---

## Best Practices

### Prioritization order when starting from zero

1. **Service unit tests** — highest value; business logic lives here
2. **Guard and pipe unit tests** — critical for security and data integrity
3. **Controller unit tests** — verify delegation to services
4. **Integration tests** — verify DI wiring of each feature module
5. **E2E tests for critical paths** — auth, payment, core CRUD

### TDD workflow

Write the test first, watch it fail, then implement the minimum code to make it pass:

```typescript
// 1. Write failing test
it('should hash password before saving', async () => {
  await service.createUser({ email: 'a@b.com', password: 'plain' });
  const user = await repo.findOne({ email: 'a@b.com' });
  expect(user.password).not.toBe('plain');
});

// 2. Implement feature to make it pass
// 3. Refactor with confidence
```

### Given-When-Then for readable tests

```typescript
it('should return 404 when user not found', async () => {
  // Given: a user ID that does not exist
  const nonExistentId = 'non-existent-uuid';

  // When: the endpoint is called
  const response = await request(app.getHttpServer()).get(`/users/${nonExistentId}`);

  // Then: a 404 is returned
  expect(response.status).toBe(404);
});
```

### Reusable test fixtures

```typescript
// test/fixtures/user.fixture.ts
export const validUserPayload = {
  email: 'test@example.com',
  password: 'Password123!',
};

export const adminUserPayload = {
  email: 'admin@example.com',
  password: 'Admin123!',
  role: 'admin',
};
```

### Parallel execution for speed

```bash
jest --maxWorkers=4
```

Ensure tests don't share state (separate DB schemas or transaction rollback per test) when running in parallel.

---

## References

### Official docs

- [NestJS Testing](https://docs.nestjs.com/fundamentals/testing)
- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Supertest GitHub](https://github.com/visionmedia/supertest)
- [NestJS Module Reference](https://docs.nestjs.com/fundamentals/module-ref)

### Learning resources

- [Testing JavaScript — Kent C. Dodds](https://testingjavascript.com/)
- [Test-Driven Development by Example — Kent Beck](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)

### Tools

- [`@golevelup/ts-jest`](https://github.com/golevelup/nestjs/tree/master/packages/testing) — `createMock` for auto-mocking in NestJS
- [`jest-mock`](https://www.npmjs.com/package/jest-mock) — `ModuleMocker` for `useMocker()` factory
- [Istanbul/nyc](https://istanbul.js.org/) — code coverage
- [faker.js](https://fakerjs.dev/) — test data generation
- [nock](https://github.com/nock/nock) — HTTP request mocking

---

## Metadata

### Version

- **Current version**: 2.0.0
- **Last updated**: 2026-03-19
- **Base skill**: [supercent-io/skills-template/backend-testing](https://skills.sh/supercent-io/skills-template/backend-testing) v1.0.0
- **Compatible platforms**: Claude, ChatGPT, Gemini, Copilot, Cursor, Codex

### Related skills

- `api-design` — Design APIs alongside tests
- `authentication-setup` — Test authentication systems
- `nestjs-setup` — Scaffold and configure a NestJS project

### Tags

`#testing` `#backend` `#NestJS` `#Jest` `#Supertest` `#unit-test` `#integration-test` `#e2e` `#TDD` `#API-test` `#TypeScript`