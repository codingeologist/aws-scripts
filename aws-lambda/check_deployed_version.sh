#!/bin/bash

# --- Local file ---
echo -e "\n=== LOCAL ENVIRONMENT ==="
LOCAL_FILE="~/[path-to-file]/lambda_handler.py"
echo "=== Local File SHA256 ==="
sha256sum "$LOCAL_FILE"

# --- aws env ---
echo -e "\n=== AWS ENVIRONMENT ==="
ZIP_URL=$(aws lambda get-function --function-name [lambda-function-name] --profile [aws-profile] --region [aws-region] --query "Code.Location" --output text)
curl -s -L -o /tmp/lambda.zip "$ZIP_URL"
unzip -q -o /tmp/lambda.zip -d /tmp/lambda
sha256sum ~/[path-to-file]/lambda_handler.py

# --- cleanup ---
rm -rf /tmp/lambda /tmp/lambda.zip
