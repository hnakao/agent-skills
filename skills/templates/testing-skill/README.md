# skill: testing-skill

## Description

Template for skills related to testing patterns and practices.

## When to Use

- Writing unit tests
- Setting up test infrastructure
- Creating test utilities
- Test coverage analysis

## Template Structure

```markdown
# skill: testing-pattern

## Description
What this testing pattern covers.

## When to Use
When to apply this testing pattern.

## Setup
Required test dependencies and configuration.

## Pattern
The testing pattern with implementation.

## Examples
Real-world test examples.

## Best Practices
Tips for effective testing.

## Common Mistakes
Pitfalls to avoid.
```

## Creating from Template

```bash
cp -r skills/templates/testing-skill skills/your-testing-pattern
```

## Common Test Patterns

### Arrange-Act-Assert

```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a user with hashed password', async () => {
      // Arrange
      const dto = { email: 'test@example.com', password: 'plain123' };
      
      // Act
      const user = await service.createUser(dto);
      
      // Assert
      expect(user.password).not.toBe(dto.password);
      expect(await bcrypt.compare(dto.password, user.password)).toBe(true);
    });
  });
});
```

### Given-When-Then

```typescript
describe('OrderProcessor', () => {
  given('an unpaid order', () => {
    const order = createOrder({ status: 'pending' });
    
    when('processPayment is called', () => {
      const result = processor.processPayment(order);
      
      then('order status should be updated', () => {
        expect(result.status).toBe('paid');
      });
    });
  });
});
```

## Tips

- One assertion concept per test
- Use descriptive test names
- Keep tests isolated
- Follow the DRY principle within reason
- Mock external dependencies
