#!/bin/bash

AWS_REGION="$1"      # target aws-region
OUTPUT_LOCATION="$2" # athena output data-sink
$GLUE_DATABASE="$3"  # aws glue data-source database name
$GLUE_TABLE="$4"     # aws glue data-source database table

start_query() {

	QUERY="$1"
	DATABASE="$2"
	OUTPUT_FILENAME="$3"
	DB_TYPE="$4"
	echo "starting query: $QUERY"

	QUERY_EXECUTION_ID=$(aws athena start-query-execution \
		--region "$AWS_REGION" \
		--query-string "$QUERY" \
		--result-configuration "OutputLocation=$OUTPUT_LOCATION" \
		--query QueryExecutionId \
		--output text
	)

	echo "query execution id: $QUERY_EXECUTION_ID"

	while true; do
		STATUS=$(aws athena get-query-execution \
			--region="$AWS_REGION" \
			--query-execution-id "$QUERY_EXECUTION_ID" \
			--query "QueryExecution.Status.State" \
			--output text
		)
		if [[ $STATUS != "RUNNING" ]]; then
			break
		else
			sleep 5
		fi
	done

	if [[ $STATUS = 'SUCCEEDED' ]]; then
		RESULT_LOCATION=$(aws athena get-query-execution \
			--region "$AWS_REGION" \
			--query-execution-id "$QUERY_EXECUTION_ID" \
			--query QueryExecution.ResultConfiguration.OutputLocation \
			--output text)
		aws s3 cp "$RESULT_LOCATION" "${DATABASE}/${DB_TYPE}/${DATABASE}_${OUTPUT_FILENAME}.csv" 
	else
		REASON=$(aws athena get-query-execution \
			--region "$AWS_REGION" \
			--query-execution-id "$QUERY_EXECUTION_ID" \
			--query QueryExecution.Status.StateChangeReason \
			--output text)
		echo "Query $QUERY_EXECUTION_ID failed: $REASON" 1>&2
		exit 1
	fi

}

query_gen() {

	DATABASE="$1"
	TABLE="$2"
	TYPE="$3"
	QUERY="SELECT * FROM ${DATABASE}.${TABLE}"
	start_query "$QUERY" "$DATABASE" "$TABLE" "$TYPE"

}

query_gen "$GLUE_DATABASE" "$GLUE_TABLE" "table"
query_gen "$GLUE_DATABASE" "$GLUE_TABLE" "view"
