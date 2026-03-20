# skill: api-design

## Description

REST API design guidelines for consistent, scalable, and maintainable backend services.

## When to Use

- Designing new API endpoints
- Structuring request/response formats
- Defining error responses
- Setting up versioning
- Documenting API contracts

## Instructions

### URL Structure

```
https://api.example.com/v1/{resource}/{id}/{sub-resource}
```

**Rules:**
- Use lowercase and hyphens: `/user-profiles`
- Plural nouns for collections: `/users`, not `/user`
- Nest resources max 2 levels deep
- Use nouns, not verbs: `/users`, not `/getUsers`

**Examples:**
```
GET    /users           # List users
POST   /users           # Create user
GET    /users/:id       # Get user
PUT    /users/:id       # Update user
DELETE /users/:id       # Delete user
GET    /users/:id/orders  # User's orders
```

### HTTP Methods

| Method | Usage | Idempotent | Safe |
|--------|-------|------------|------|
| GET | Retrieve resource | Yes | Yes |
| POST | Create resource | No | No |
| PUT | Replace resource | Yes | No |
| PATCH | Partial update | No | No |
| DELETE | Remove resource | Yes | No |

### Request Format

```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "age": 30
}
```

**Rules:**
- Use camelCase for field names
- Use appropriate data types
- Validate required fields
- Support partial updates with PATCH

### Response Format

**Success:**
```json
{
  "data": {
    "id": "123",
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2024-01-15T10:30:00Z"
  },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```

**Collection Response:**
```json
{
  "data": [
    { "id": "1", "name": "Item 1" },
    { "id": "2", "name": "Item 2" }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

### Status Codes

| Code | Usage |
|------|-------|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No Content (DELETE) |
| 400 | Bad Request (validation error) |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict (duplicate) |
| 422 | Unprocessable Entity |
| 429 | Too Many Requests |
| 500 | Internal Server Error |

### Error Response

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "path": "/api/v1/users"
}
```

### Pagination

```
GET /users?page=1&limit=20
GET /users?cursor=abc123&limit=20
```

```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "hasNext": true,
    "hasPrev": false
  }
}
```

### Versioning

```
/api/v1/users
/api/v2/users
```

- Add version in URL path
- Maintain backwards compatibility
- Deprecate old versions with headers:
  ```
  Deprecation: true
  Sunset: Sat, 01 Jan 2025 00:00:00 GMT
  ```

### Authentication

```http
Authorization: Bearer <token>
X-API-Key: <api-key>
```

### Filtering & Sorting

```
GET /users?status=active&role=admin
GET /users?sort=createdAt:desc&sort=name:asc
GET /users?fields=id,name,email
```

### Rate Limiting

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642248000
```

## Examples

### CRUD Endpoints

```typescript
// Create
POST /users
Body: { name, email, password }
Response: 201 { data: { id, name, email } }

// Read
GET /users/:id
Response: 200 { data: { id, name, email, createdAt } }

// Update (full)
PUT /users/:id
Body: { name, email }
Response: 200 { data: { id, name, email } }

// Update (partial)
PATCH /users/:id
Body: { name }
Response: 200 { data: { id, name, email } }

// Delete
DELETE /users/:id
Response: 204
```

### NestJS Implementation

```typescript
@Controller('users')
export class UsersController {
  @Get()
  async findAll(@Query() dto: FindUsersDto) {
    return this.usersService.findAll(dto);
  }

  @Post()
  async create(@Body() dto: CreateUserDto) {
    return this.usersService.create(dto);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  @Patch(':id')
  async update(@Param('id') id: string, @Body() dto: UpdateUserDto) {
    return this.usersService.update(id, dto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    await this.usersService.remove(id);
  }
}
```

## Notes

- Always return consistent response format
- Use appropriate HTTP status codes
- Validate input early
- Log errors but don't expose internals
- Document with OpenAPI/Swagger
