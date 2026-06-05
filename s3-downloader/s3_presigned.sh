#!/bin/bash

TARGET_ENV="$1"
AWS_PROFILE="$2"
AWS_REGION="$3"
BUCKET_NAME="$4"
S3_PREFIX="$5"
TIME_PERIOD="$6"

SSO=$(aws sts get-caller-identity --profile $AWS_PROFILE);
if [ -n "$SSO" ]; then
	echo "profile $AWS_PROFILE authenticated";
else
	aws sso login --profile $AWS_PROFILE;
fi

CRED_EXP=$(aws configure export-credentials \
	--profile $AWS_PROFILE \
	--format env | grep AWS_CREDENTIAL_EXPIRATION | cut -d= -f2)

NOW=$(date -u +%s)
EXP=$(date -d "$CRED_EXP" +%s)
MAX=$(($EXP - $NOW))

if [ "$TIME_PERIOD" -gt "$MAX" ]; then
	echo "WARNING: URL expiry exceeds role credential lifetime"
	echo "maximum allowed: $MAX seconds"
fi

aws s3 presign "s3://$BUCKET_NAME/$S3_PREFIX" --expires-in $TIME_PERIOD --profile $AWS_PROFILE
