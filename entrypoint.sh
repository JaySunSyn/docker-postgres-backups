set -e # stop if any of these commands fail

: ${GPG_PUBKEY_ID:?"-e GPG_PUBKEY_ID is not set"}
: ${AWS_ACCESS_KEY_ID:?"-e AWS_ACCESS_KEY_ID is not set"}
: ${AWS_SECRET_ACCESS_KEY:?"-e AWS_SECRET_ACCESS_KEY is not set"}
: ${S3_BUCKET_NAME:?"-e S3_BUCKET_NAME is not set"}
: ${PREFIX:?"-e PREFIX is not set"}

# Write out runtime ENV vars so that cron can load them in.
env > /tmp/env.sh

echo "Starting cron daemon..."
cron -f
