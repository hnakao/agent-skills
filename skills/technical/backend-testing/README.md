# skill: backend-testing

## Description

NestJS backend testing patterns and best practices for unit, integration, and e2e tests.

## When to Use

- Writing unit tests for services/controllers
- Setting up integration tests with database
- Creating e2e test scenarios
- Mocking dependencies
- Testing async operations

## Instructions

### Testing Stack
- **Framework**: Jest
- **Testing**: @nestjs/testing
- **E2E**: @nestjs/testing with supertest
- **Coverage**: expect jest thresholds

### File Naming
```
*.spec.ts  # Unit tests
*.integration-spec.ts  # Integration tests
*.e2e-spec.ts  # E2E tests
```

### Service Testing Pattern

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { MyService } from './my.service';
import { MyRepository } from './my.repository';

describe('MyService', () => {
  let service: MyService;
  let repository: MyRepository;

  const mockRepository = {
    find: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MyService,
        { provide: MyRepository, useValue: mockRepository },
      ],
    }).compile();

    service = module.get<MyService>(MyService);
    repository = module.get<MyRepository>(MyRepository);
  });

  afterEach(() => jest.clearAllMocks());

  describe('findAll', () => {
    it('should return an array of items', async () => {
      const expected = [{ id: 1, name: 'Test' }];
      mockRepository.find.mockResolvedValue(expected);

      const result = await service.findAll();

      expect(result).toEqual(expected);
      expect(repository.find).toHaveBeenCalled();
    });
  });
});
```

### Controller Testing Pattern

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { MyController } from './my.controller';
import { MyService } from './my.service';
import { CreateDto } from './dto/create.dto';

describe('MyController', () => {
  let controller: MyController;
  let service: MyService;

  const mockService = {
    create: jest.fn(),
    findAll: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [MyController],
      providers: [{ provide: MyService, useValue: mockService }],
    }).compile();

    controller = module.get<MyController>(MyController);
    service = module.get<MyService>(MyService);
  });

  describe('create', () => {
    it('should create a new item', async () => {
      const dto: CreateDto = { name: 'Test' };
      const expected = { id: 1, ...dto };
      mockService.create.mockResolvedValue(expected);

      const result = await controller.create(dto);

      expect(result).toEqual(expected);
      expect(service.create).toHaveBeenCalledWith(dto);
    });
  });
});
```

### Repository Testing Pattern

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MyEntity } from './my.entity';
import { MyRepository } from './my.repository';

describe('MyRepository', () => {
  let repository: MyRepository;
  let ormRepo: Repository<MyEntity>;

  const mockOrmRepo = {
    find: jest.fn(),
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    delete: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MyRepository,
        { provide: getRepositoryToken(MyEntity), useValue: mockOrmRepo },
      ],
    }).compile();

    repository = module.get<MyRepository>(MyRepository);
    ormRepo = module.get<Repository<MyEntity>>(getRepositoryToken(MyEntity));
  });

  describe('findAll', () => {
    it('should call find with empty options', async () => {
      const items = [{ id: 1, name: 'Test' }];
      mockOrmRepo.find.mockResolvedValue(items);

      const result = await repository.findAll();

      expect(result).toEqual(items);
      expect(ormRepo.find).toHaveBeenCalledWith({});
    });
  });
});
```

### E2E Testing Pattern

```typescript
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('MyController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  describe('/GET items', () => {
    it('should return an array', () => {
      return request(app.getHttpServer())
        .get('/items')
        .expect(200)
        .expect(Array);
    });
  });

  describe('/POST items', () => {
    it('should create an item', () => {
      return request(app.getHttpServer())
        .post('/items')
        .send({ name: 'Test' })
        .expect(201)
        .expect((res) => {
          expect(res.body).toHaveProperty('id');
          expect(res.body.name).toBe('Test');
        });
    });
  });
});
```

### Common Mocks

```typescript
// Date
jest.spyOn(Date, 'now').mockImplementation(() => new Date('2024-01-01').getTime());

// ConfigService
const mockConfigService = {
  get: jest.fn((key: string) => {
    const config = {
      JWT_SECRET: 'test-secret',
      DATABASE_URL: 'test-url',
    };
    return config[key];
  }),
};

// Logger
const mockLogger = {
  log: jest.fn(),
  error: jest.fn(),
  warn: jest.fn(),
  debug: jest.fn(),
};
```

### Test Coverage Requirements

```json
{
  "collectCoverageFrom": [
    "src/**/*.ts",
    "!src/main.ts",
    "!src/*.module.ts",
    "!src/*.interface.ts"
  ],
  "coverageThreshold": {
    "global": {
      "branches": 70,
      "functions": 70,
      "lines": 70,
      "statements": 70
    }
  }
}
```

## Examples

### Testing with TypeORM

```typescript
// Use TypeORM's createTestingConnections
import { createTestingConnections, closeConnections } from '@test/utils';

beforeAll(() => createTestingConnections({ entities: [MyEntity] }));
afterAll(() => closeConnections());
```

### Testing Guards/Decorators

```typescript
const mockAuthGuard = { canActivate: jest.fn().mockReturnValue(true) };
// In module
{ provide: APP_GUARD, useValue: mockAuthGuard }
```

## Notes

- Always use `TestingModule` for DI
- Clear mocks in `afterEach`
- Use `jest.fn()` for simple mocks
- Prefer `toHaveBeenCalledWith` over `toHaveBeenCalled`
- Test error cases too
