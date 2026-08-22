---
name: deployment-helper
description: Guided deployment workflow with pre-flight checks and rollback plan
---

# Deployment Helper

When asked to deploy or prepare a deployment, follow this structured workflow. Read `references/deploy-checklist.md` for the full checklist.

## Pre-Flight Checks

Before any deployment:

1. **Branch status** — Is the branch up to date with the target branch?
   ```bash
   git fetch origin
   git log HEAD..origin/main --oneline  # Should be empty
   ```

2. **Tests passing** — Run the project's test suite
   ```bash
   # Detect and run the appropriate test command
   # npm test | pytest | go test ./... | cargo test
   ```

3. **Environment variables** — Verify all required env vars are set on the target
   ```bash
   # Compare local .env.example with production env
   # Flag any missing variables
   ```

4. **Database migrations** — Check for pending migrations
   ```bash
   # alembic heads | npx prisma migrate status | rails db:migrate:status
   ```

5. **Dependencies** — Verify lockfile is committed and up to date

## Deployment Steps

1. Create a git tag for the release: `v<MAJOR>.<MINOR>.<PATCH>`
2. Run migrations on the target environment
3. Deploy the application code
4. Verify health endpoints respond correctly
5. Monitor logs for errors in the first 5 minutes

## Rollback Plan

If deployment fails:
1. Revert to the previous git tag
2. Rollback database migrations if they were applied
3. Restart the service with the previous version
4. Verify health endpoints

## Post-Deployment

- Verify all health check endpoints return 200
- Check application logs for errors
- Run smoke tests if available
- Notify the team of the deployment status
