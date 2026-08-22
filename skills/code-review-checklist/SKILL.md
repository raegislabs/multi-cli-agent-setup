---
name: code-review-checklist
description: Structured code review with security, performance, and maintainability checks
---

# Code Review Checklist

When asked to review code (PR, diff, or file), work through each section below. Report only genuine issues — skip sections where everything looks good.

## 1. Security
- [ ] No hardcoded secrets, API keys, or credentials
- [ ] User inputs are validated and sanitized
- [ ] SQL queries use parameterized statements (no string concatenation)
- [ ] File paths are validated (no path traversal)
- [ ] Authentication/authorization checks are present where needed
- [ ] No sensitive data in logs or error messages

## 2. Correctness
- [ ] Logic handles edge cases (empty arrays, null values, zero, negative numbers)
- [ ] Error handling is present and doesn't swallow exceptions silently
- [ ] Async operations have proper error handling (try/catch, .catch())
- [ ] State mutations are intentional and don't cause race conditions
- [ ] Return types match function signatures

## 3. Performance
- [ ] No N+1 query patterns in database access
- [ ] Large collections are paginated, not loaded entirely into memory
- [ ] Expensive operations aren't inside loops unnecessarily
- [ ] Indexes exist for frequently queried database columns

## 4. Maintainability
- [ ] Functions do one thing and are reasonably sized (<50 lines)
- [ ] Variable and function names are descriptive
- [ ] No dead code or commented-out blocks
- [ ] Complex logic has comments explaining *why*, not *what*
- [ ] No magic numbers — use named constants

## 5. Testing
- [ ] New logic has corresponding test coverage
- [ ] Tests cover both happy path and error cases
- [ ] Test names describe the behavior being tested
- [ ] No flaky patterns (sleep, random, time-dependent)

## Output Format

For each issue found:
```
**[SECTION] Severity: HIGH|MEDIUM|LOW**
File: path/to/file.ts:42
Issue: Description of the problem
Suggestion: How to fix it
```

End with a summary: total issues by severity, and whether the code is ready to merge.
