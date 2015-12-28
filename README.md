docker-postgres-backups
=======================

Uses `pg_dumpall` to dump a linked postgres container, encrypts with PGP and
uploads to S3. Runs every 6 hours via cron.

Example docker-compose declaration
----------------------------------

Paste this into your `compose.yaml` file.

```yaml
postgres_backups:
  image: getsiphon/postgres-backups:latest
  environment:
    AWS_ACCESS_KEY_ID: my-aws-key
    AWS_SECRET_ACCESS_KEY: my-aws-secret
    S3_BUCKET_NAME: my-backups
    GPG_PUBKEY_ID: A1234567 # PGP public key fingerprint
    PREFIX: postgres-backup # S3 key prefix to save with
  links:
    - postgres:postgres
```
