# skill: git-best-practices

## Description

Git workflow, branching strategies, and commit conventions for consistent project history.

## When to Use

- Creating feature branches
- Committing code changes
- Merging or rebasing branches
- Resolving conflicts
- Tagging releases

## Instructions

### Branch Naming

```
feature/JIRA-123-add-user-auth
fix/JIRA-456-login-redirect
chore/update-dependencies
docs/add-api-docs
refactor/extract-service-layer
```

### Commit Messages

Follow Conventional Commits:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Formatting
- `refactor` - Code restructure
- `test` - Adding tests
- `chore` - Maintenance

**Examples:**
```
feat(auth): add JWT token refresh
fix(api): handle null response from service
docs(readme): update installation steps
refactor(users): extract validation logic
test(orders): add unit tests for service
```

### Workflow

```bash
# 1. Sync with main
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/JIRA-123-add-auth

# 3. Work and commit
git add .
git commit -m "feat(auth): add login endpoint"

# 4. Keep updated with main
git fetch origin
git rebase origin/main

# 5. Push and create PR
git push -u origin feature/JIRA-123-add-auth
```

### Merging vs Rebasing

**Use rebase for:**
- Updating feature branches with main
- Cleaning up commits before PR

**Use merge for:**
- Combining main into long-lived branches
- Final PR merge (or squash)

```bash
# Rebase (preferred for clean history)
git rebase main

# Merge (preserves history)
git merge main --no-ff
```

### Conflict Resolution

```bash
# During rebase
git rebase main
# Resolve conflicts, then:
git add .
git rebase --continue

# Abort if needed
git rebase --abort
```

### Tags

```bash
# Annotated tag for release
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0

# Lightweight for milestones
git tag v1.0.0-beta
```

### Undo Changes

```bash
# Unstage file
git restore --staged file.txt

# Discard local changes
git restore file.txt

# Revert commit (safe)
git revert abc123

# Reset (destructive)
git reset --soft HEAD~1  # keep changes staged
git reset --hard HEAD~1  # discard changes
```

### Useful Commands

```bash
# Interactive rebase (clean up commits)
git rebase -i HEAD~5

# Stash changes
git stash
git stash pop

# Check differences
git diff main
git diff --staged

# Short status
git status -sb

# Pretty log
git log --oneline --graph --all
```

## Examples

### Feature Branch Lifecycle

```bash
# Start
git checkout main && git pull
git checkout -b feature/add-export

# Work
git add src/export.service.ts
git commit -m "feat(export): add CSV export"

# Update
git fetch origin
git rebase origin/main

# Push
git push -u origin feature/add-export
```

### Hotfix Process

```bash
git checkout main
git pull
git checkout -b hotfix/JIRA-789-critical-bug
# Fix...
git commit -m "fix(critical): urgent fix"
git checkout main && git merge hotfix/JIRA-789-critical-bug --no-ff
git tag -a v1.2.1 -m "Hotfix v1.2.1"
git push origin main --tags
git branch -d hotfix/JIRA-789-critical-bug
```

## Notes

- Never force push to main/master
- PRs require review before merge
- Keep commits atomic (one logical change each)
- Write commit messages that explain WHY, not just WHAT
