#!/bin/bash

session() {
	if [ "$#" -ne 2 ]; then
		echo "Usage: $0 <REPO> <ENV>"
		return 1
	fi
	local REPO="$1"
	local ENV="$2"
	export AWS_PROFILE="$ENV"
	cd "gitclones/$REPO" || return 1
}

aws_auth() {
	SSO=$(aws sts get-caller-identity --profile $AWS_PROFILE);
	if [ -n "$SSO" ]; then
		echo "profile $AWS_PROFILE authenticated";
	else
		aws sso login --profile $AWS_PROFILE;
	fi
}

session "$@" && aws_auth
