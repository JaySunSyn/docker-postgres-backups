# Credit for lots of this goes to: https://github.com/siomiz/PostgreSQL-S3
set -e # stop if any of these commands fail

if [[ "$RUN_BACKUP" != "TRUE" ]]; then
  echo 'Will not run backups according to RUN_BACKUP env var. Exiting.';
  exit 1;
fi

echo "*** Starting run-backup.sh ***"

DATE=$(date +%Y%m%d_%H%M%S)
FILE="/tmp/$PREFIX-$DATE.sql"
GPG_FILE="/tmp/$PREFIX-$DATE.sql.gpg"
S3_URI="s3://$S3_BUCKET_NAME/$PREFIX-$DATE.sql.gpg.gz"

echo "> Running pg_dump"
PGPASSWORD="$POSTGRES_PASSWORD" pg_dumpall -h "$POSTGRES_HOST" -U "$POSTGRES_USER" > $FILE

echo "> Downloading public key: ${GPG_PUBKEY_ID}"

( gpg --keyserver ${KEY_SERVER} --recv-keys ${GPG_PUBKEY_ID} \
  || gpg --keyserver ha.pool.sks-keyservers.net --recv-keys ${GPG_PUBKEY_ID} \
  || gpg --keyserver pgp.mit.edu --recv-keys ${GPG_PUBKEY_ID} \
  || gpg --keyserver keyserver.pgp.com --recv-keys ${GPG_PUBKEY_ID} )

echo "> Encrypting dump file using gpg"
gpg --always-trust -v -e -r ${GPG_PUBKEY_ID} -o $GPG_FILE $FILE

echo "> Zipping dump file"
gzip -9 $GPG_FILE

echo "> Uploading to S3"
AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" aws s3 cp "$GPG_FILE.gz" "$S3_URI" --region "$AWS_DEFAULT_REGION"

# Clean up
rm $FILE
rm "$GPG_FILE.gz"

echo "Done."
