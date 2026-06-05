#!/bin/bash

AWS_PROFILE="$1" # aws-cli profile to authenticate session
AWS_REGION="$2"  # aws-region
BUCKET="$3"      # aws-s3 bucket name data-source
OUTDIR="$4"      # output directory data-sink

SSO=$(aws sts get-caller-identity --profile $AWS_PROFILE);
if [ -n "$SSO" ]; then
	echo "profile $AWS_PROFILE authenticated";
else
	aws sso login --profile $AWS_PROFILE;
fi

aws s3 cp --profile $AWS_PROFILE --recursive "s3://$BUCKET/" "$OUTDIR"
