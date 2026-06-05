#!/bin/bash
set -euo pipefail

BUCKET="$1"  # target aws s3 bucket name
JSON="$2"    # local json file with filenames to search for
OUTDIR="$3"  # local outdir to save files to

mkdir -p "$OUTDIR"

echo "Caching S3 keys from bucket (this may take a moment)..."

KEYCACHE="$(mktemp)"
aws s3api list-objects-v2 \
  --bucket "$BUCKET" \
  --query 'Contents[].Key' \
  --output text \
  --max-items 10000000 | tr '\t' '\n' > "$KEYCACHE"

echo "Cached $(wc -l < "$KEYCACHE") keys"
echo

# Read unique filenames from JSON array
jq -r '.[]' "$JSON" | sort -u | while read -r filename; do
  [[ -z "$filename" ]] && continue

  echo "==> $filename"

  matches=$(grep -F "/$filename" "$KEYCACHE" || true)

  if [[ -z "$matches" ]]; then
    echo "    (no match)"
    continue
  fi

  while IFS= read -r key; do
    [[ -z "$key" ]] && continue
    echo "    downloading: s3://$BUCKET/$key"
    aws s3 cp "s3://$BUCKET/$key" "$OUTDIR/$filename"
  done <<< "$matches"

done

rm -f "$KEYCACHE"
echo
echo "Done."
