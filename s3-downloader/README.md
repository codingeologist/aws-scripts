# AWS S3 File Search

---

This script searches an AWS S3 bucket for a provided filename and downloads it locally.

---

## Usage

```bash
BUCKET="$1"  # target aws s3 bucket name
JSON="$2"    # local json file with filenames to search for
OUTDIR="$3"  # local outdir to save files to
```

```
