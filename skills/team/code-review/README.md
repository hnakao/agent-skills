# skill: code-review

## Description

Guidelines for conducting effective code reviews.

## When to Use

- Reviewing pull requests
- Submitting code for review
- Improving code quality
- Mentoring team members

## For Reviewers

### Before Starting

- [ ] Read the PR description thoroughly
- [ ] Understand the context/requirement
- [ ] Check related tickets/documentation
- [ ] Look at the test plan

### What to Check

**Correctness**
- Does the code do what it's supposed to?
- Are edge cases handled?
- Is there potential for bugs?
- Are there race conditions?

**Security**
- Is user input validated?
- Are secrets handled properly?
- Is authorization enforced?
- SQL/NoSQL injection possible?

**Performance**
- Are there N+1 queries?
- Are large datasets paginated?
- Is caching appropriate?
- Are indexes in place?

**Maintainability**
- Is the code readable?
- Are functions focused?
- Is there code duplication?
- Are variable names clear?

**Testing**
- Are tests meaningful?
- Are edge cases covered?
- Do tests actually test behavior?
- Is coverage adequate?

### Review Comments

```markdown
## Suggestion (Blocking)
This will cause issues in production when X happens.

## Suggestion (Non-blocking)
Consider using X instead for better readability.

## Question
Is this the intended behavior when Y?

## Praise
Nice solution for handling the edge case!
```

### Best Practices

1. **Be kind and constructive** - Focus on code, not person
2. **Explain the why** - Not just what needs changing
3. **Offer solutions** - Suggest how to fix, not just point out
4. **Acknowledge good work** - Positive feedback matters
5. **Ask questions** - Don't assume you understand
6. **Keep it simple** - If it can be simpler, ask for it

## For Authors

### Before Requesting Review

- [ ] Self-review your code
- [ ] Run tests locally
- [ ] Check lint/type errors
- [ ] Write/update tests
- [ ] Update documentation
- [ ] No debug code left in
- [ ] PR description complete

### PR Description Template

```markdown
## Summary
Brief description of changes.

## Changes
- Added X
- Modified Y
- Removed Z

## Motivation
Why is this change needed?

## Testing
How was this tested?

## Screenshots (if UI)
Before/after screenshots.

## Related Issues
Closes #123
```

### Responding to Feedback

1. **Don't take it personally** - Reviews are about the code
2. **Ask for clarification** - If feedback is unclear
3. **Discuss, don't argue** - Healthy debate is good
4. **Make requested changes** - Or explain why not
5. **Mark as resolved** - After addressing feedback

## Common Issues

### Blocking Issues (Must Fix)
- Security vulnerabilities
- Data loss potential
- Breaking existing functionality
- Missing error handling
- No tests for critical paths

### Non-Blocking Issues (Consider)
- Style preferences
- Minor optimizations
- Documentation improvements
- Code that could be clearer

### Never Block On
- Personal style preferences without project guidelines
- Minor formatting (use linters)
- Premature optimizations
- "I would have done it differently"

## Review Turnaround

- **First review**: Within 24 hours
- **Follow-up reviews**: Within 4 hours
- **Approve if minor changes needed**: Do so, don't block

## Tools

- ESLint / Prettier - Enforce style
- TypeScript strict mode - Catch type errors
- Jest coverage - Check test coverage
- SonarQube - Additional static analysis
