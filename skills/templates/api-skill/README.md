# skill: api-skill

## Description

Template for skills that interact with external APIs.

## When to Use

- Third-party API integrations
- Webhook handlers
- OAuth flows
- Data fetching from external services

## Template Structure

```markdown
# skill: service-api

## Description
Brief description of the API integration.

## Prerequisites
- API credentials/keys
- Required permissions
- Environment setup

## Configuration
Environment variables and setup steps.

## Usage
How to use the API integration.

## Endpoints
Available endpoints and their usage.

## Examples
Code examples for common operations.

## Error Handling
Common errors and how to handle them.

## Rate Limits
API rate limits and best practices.
```

## Creating from Template

```bash
cp -r skills/templates/api-skill skills/your-api-integration
```

## Common Patterns

```typescript
// API Client Setup
class ApiClient {
  constructor(private baseUrl: string, private apiKey: string) {}

  private async request<T>(endpoint: string, options?: RequestInit): Promise<T> {
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      ...options,
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
        ...options?.headers,
      },
    });

    if (!response.ok) {
      throw new ApiError(response.status, await response.text());
    }

    return response.json();
  }
}
```

## Tips

- Always handle errors gracefully
- Implement retry logic for transient failures
- Cache responses when appropriate
- Respect rate limits
- Never log sensitive credentials
