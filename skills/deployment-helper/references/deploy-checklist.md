# Deployment Checklist

Use this checklist before every production deployment.

## Pre-Deploy
- [ ] All tests pass on CI
- [ ] Code reviewed and approved
- [ ] No pending database migrations that haven't been tested
- [ ] Environment variables verified on target
- [ ] Dependency lockfile committed (`package-lock.json`, `poetry.lock`, etc.)
- [ ] Release notes drafted
- [ ] Rollback plan documented

## During Deploy
- [ ] Maintenance mode enabled (if applicable)
- [ ] Database backup taken
- [ ] Migrations applied successfully
- [ ] Application deployed
- [ ] Health check endpoints responding

## Post-Deploy
- [ ] Smoke tests pass
- [ ] No error spikes in logs
- [ ] Performance metrics normal
- [ ] Maintenance mode disabled
- [ ] Team notified
- [ ] Release notes published

## Rollback Triggers
Deploy should be rolled back immediately if:
- Health check endpoints return non-200 for >2 minutes
- Error rate exceeds 5% of requests
- Critical functionality is broken (auth, payments, core workflows)
- Database migration cannot be reversed after failure
