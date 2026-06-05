#!/bin/bash

ENV="$1"
AWS_PROFILE="$2"
AWS_REGION="$3"
DEV_ID="dev-cognito-client-id"
QA_ID="qa-cognito-client-id"
PROD_ID="prod-cognito-client-id"
DEV_POOL="dev-cognito-user-pool"
QA_POOL="qa-cognito-user-pool"
PROD_POOL="prod-cognito-user-pool"

if [ "$1" = "dev" ]; then
	CLIENT_ID=$DEV_ID
	USER_POOL=$DEV_POOL
elif [ "$1" = "qa" ]; then
	CLIENT_ID=$QA_ID
	USER_POOL=$QA_POOL
elif [ "$1" = "prod" ]; then
	CLIENT_ID=$PROD_ID
	USER_POOL=$PROD_POOL
else
	echo "invalid environment specified!"
	CLIENT_ID="null"
	USER_POOL="null"
fi

SSO=$(aws sts get-caller-identity --profile $AWS_PROFILE);
if [ -n "$SSO" ]; then
	echo "profile $AWS_PROFILE authenticated";
else
	aws sso login --profile $AWS_PROFILE;
fi

USERS=$(aws cognito-idp list-users --profile $AWS_PROFILE --region $AWS_REGION --user-pool-id $USER_POOL --limit 60)

jq '.' <(echo $USERS) > full_users.json

jq --indent 4 '[.Users[] | {Username, Email: .Attributes[2].Value, UserCreateDate, UserLastModifiedDate, Enabled, UserStatus}]' < full_users.json > users-$1.json

rm full_users.json
