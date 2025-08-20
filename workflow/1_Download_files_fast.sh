

#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Create and enter output folder
# -----------------------------
cd /Users/ruslanrust/Dropbox/SEPAL_AI/3_Astrocytes_abeta
mkdir -p fastq1
cd fastq1

# -----------------------------
# List of SRR run accessions
# -----------------------------
SRRS=(
  SRR29040783
  SRR29040784
  SRR29040785
  SRR29040796
  SRR29040797
  SRR29040798
)

# Number of parallel jobs
THREADS=16

# -----------------------------
# Function to download a single SRR
# -----------------------------
download_srr () {
  SRR=$1
  echo "🔍 Resolving $SRR via ENA API..."

  # Fetch FTP links from ENA API
  URLS=$(curl -s "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${SRR}&result=read_run&fields=fastq_ftp&format=tsv" \
    | tail -n +2 | tr ';' '\n' | sed 's|^|ftp://|')

  if [[ -z "$URLS" ]]; then
    echo "❌ No FASTQ URLs found for $SRR"
    return 1
  fi

  for URL in $URLS; do
    FILE=$(basename "$URL")
    if [[ -f "$FILE" ]]; then
      echo "⚠️  Skipping existing $FILE"
    else
      echo "➡️  Downloading $FILE ..."
      wget -c "$URL"
    fi
  done

  echo "✅ Finished downloading files for: $SRR"
}

# Export function so xargs can call it
export -f download_srr

# -----------------------------
# Run all downloads in parallel
# -----------------------------
echo "🚀 Starting download of FASTQ files from ENA..."

printf "%s\n" "${SRRS[@]}" | xargs -n 1 -P "$THREADS" -I {} bash -c 'download_srr "$@"' _ {}

echo "🎉 All FASTQ files successfully downloaded to ./fastq1/"
