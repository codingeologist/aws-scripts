#!/bin/bash

ENV="$1"
AWS_PROFILE="$2"
AWS_REGION="$3"
DEV_ID="dev-cognito-client-id"
QA_ID="qa-cognito-client-id"
PROD_ID="prod-cognito-client-id"


if [ "$1" = "dev" ]; then
	CLIENT_ID=$DEV_ID
elif [ "$1" = "qa" ]; then
	CLIENT_ID=$QA_ID
elif [ "$1" = "prod" ]; then
	CLIENT_ID=$PROD_ID
else
	echo "invalid environment specified!"
	CLIENT_ID="null"
fi

USERNAME="$4"
PASSWORD="$5"

SSO=$(aws sts get-caller-identity --profile $AWS_PROFILE);
if [ -n "$SSO" ]; then
	echo "profile $AWS_PROFILE authenticated";
else
	aws sso login --profile $AWS_PROFILE;
fi

AUTH=$(aws cognito-idp initiate-auth --client-id $CLIENT_ID --auth-flow USER_PASSWORD_AUTH --auth-parameters USERNAME=$USERNAME,PASSWORD=$PASSWORD --region $AWS_REGION)

ID_TOKEN=$(echo "$AUTH" | jq -r ".AuthenticationResult.IdToken")
TOKEN_TYPE=$(echo "$AUTH" | jq -r ".AuthenticationResult.TokenType")
EXPIRY=$(echo "$AUTH" | jq -r ".AuthenticationResult.ExpiresIn")
TOKEN="${TOKEN_TYPE} ${ID_TOKEN}"

echo "TOKEN: $TOKEN"
echo "Expires in (s): $EXPIRY"
