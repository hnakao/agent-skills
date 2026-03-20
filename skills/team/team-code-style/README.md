# skill: team-code-style

## Description

Coding standards and style guidelines for the team.

## When to Use

- Writing new code
- Code reviews
- Onboarding new team members
- Enforcing consistency

## TypeScript Guidelines

### Naming

```typescript
// Variables & Functions: camelCase
const userName = 'John';
function getUserById(id: string) {}

// Classes & Types & Interfaces: PascalCase
class UserService {}
interface UserDto {}
type ApiResponse<T> = {}

// Constants: SCREAMING_SNAKE_CASE
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = 'https://api.example.com';

// Files: kebab-case
// user-service.ts, auth-middleware.ts, user-dto.ts
```

### Imports

```typescript
// 1. Node built-ins
import { readFile } from 'fs/promises';

// 2. External packages
import { Injectable } from '@nestjs/common';
import { ClassValidator } from 'class-validator';

// 3. Internal modules
import { UserRepository } from '../repositories/user.repository';
import { UserDto } from '../dto/user.dto';

// 4. Relative imports
import { Helper } from './helper';

// 5. Type imports
import type { Config } from '../config';
```

### Functions

```typescript
// Prefer async/await over .then()
// ✓ Good
async function getUser(id: string): Promise<User> {
  return this.repository.findById(id);
}

// ✗ Avoid
function getUser(id: string): Promise<User> {
  return this.repository.findById(id);
}

// Max function length: ~50 lines
// Extract complex logic to helper functions
```

### Error Handling

```typescript
// ✓ Good
try {
  const user = await this.userService.findById(id);
  if (!user) {
    throw new NotFoundException(`User ${id} not found`);
  }
  return user;
} catch (error) {
  this.logger.error('Failed to get user', { id, error });
  throw error;
}

// ✗ Avoid - swallowing errors
try {
  // ...
} catch (error) {
  // do nothing
}
```

### Async Patterns

```typescript
// Always handle promise rejections
// ✓ Good
await promise.catch(err => {
  this.logger.error(err);
});

// Better - use try/catch
try {
  await promise;
} catch (err) {
  this.logger.error(err);
}
```

## NestJS Guidelines

### Modules

```typescript
// One class per file
// File name matches class name (PascalCase)
// user.module.ts contains class UserModule

@Module({
  imports: [ConfigModule],
  controllers: [UserController],
  providers: [UserService, UserRepository],
  exports: [UserService],
})
export class UserModule {}
```

### DTOs

```typescript
// Create DTO
export class CreateUserDto {
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;
}

// Update DTO
export class UpdateUserDto {
  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  name?: string;
}
```

### Services

```typescript
@Injectable()
export class UserService {
  constructor(
    private readonly userRepository: UserRepository,
    private readonly configService: ConfigService,
  ) {}

  async create(dto: CreateUserDto): Promise<User> {
    const user = this.userRepository.create(dto);
    return this.userRepository.save(user);
  }
}
```

## File Organization

```
src/
├── controllers/     # HTTP layer
├── services/         # Business logic
├── repositories/     # Data access
├── dto/             # Data transfer objects
├── entities/        # Database entities
├── modules/         # Feature modules
├── guards/          # Auth guards
├── decorators/      # Custom decorators
├── interceptors/    # Nest interceptors
├── filters/         # Exception filters
├── common/          # Shared utilities
└── config/          # Configuration
```

## Git Commit Style

```
feat(auth): add password reset
fix(users): handle null email
docs(api): update endpoint docs
refactor(orders): extract validator
test(checkout): add payment tests
chore(deps): update nestjs to 10.0
```

## Code Review Checklist

- [ ] No console.log/debugger
- [ ] Error handling in place
- [ ] Types are explicit
- [ ] Tests added/updated
- [ ] No commented-out code
- [ ] Follows naming conventions
- [ ] No TODO/FIXME without ticket
- [ ] Sensitive data not exposed
