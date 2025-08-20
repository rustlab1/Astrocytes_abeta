#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Activate conda environment
# -----------------------------
cd /Users/ruslanrust/Dropbox/SEPAL_AI/3_Astrocytes_abeta
source /Users/ruslanrust/miniconda3/etc/profile.d/conda.sh
conda activate rnaseq_tools

# -----------------------------
# Configuration
# -----------------------------
INPUT_DIR="fastq"
OUTPUT_DIR="fastq_downsampled"
TARGET_SIZE_MB=200
THREADS=16

mkdir -p "$OUTPUT_DIR"

# -----------------------------
# Loop through paired-end files
# -----------------------------
for fq1 in ${INPUT_DIR}/*_1.fastq.gz; do
  base=$(basename "$fq1" _1.fastq.gz)
  fq2="${INPUT_DIR}/${base}_2.fastq.gz"

  if [[ ! -f "$fq2" ]]; then
    echo "❌ Skipping $base — missing pair"
    continue
  fi

  echo "🔧 Trimming $base with fastp..."

  trimmed1="${OUTPUT_DIR}/${base}_1.trimmed.fastq.gz"
  trimmed2="${OUTPUT_DIR}/${base}_2.trimmed.fastq.gz"
  subsampled1="${OUTPUT_DIR}/${base}_1.subsampled.fastq.gz"
  subsampled2="${OUTPUT_DIR}/${base}_2.subsampled.fastq.gz"
  log="${OUTPUT_DIR}/${base}.fastp.log"

  # Step 1: Trim with fastp
  fastp \
    -i "$fq1" -I "$fq2" \
    -o "$trimmed1" -O "$trimmed2" \
    -w "$THREADS" -q 20 -u 30 -n 5 -l 30 \
    --detect_adapter_for_pe \
    --compression 6 \
    > "$log" 2>&1

  echo "📉 Estimating downsampling fraction for $base..."

  total_reads=$(gzip -cd "$trimmed1" | awk 'NR % 4 == 1' | wc -l)
  if [[ "$total_reads" -lt 10000 ]]; then
    echo "⚠️ Too few reads ($total_reads), skipping downsampling"
    mv "$trimmed1" "$subsampled1"
    mv "$trimmed2" "$subsampled2"
    continue
  fi

  size1=$(gzip -cd "$trimmed1" | wc -c)
  avg_read_size=$(( size1 / total_reads ))
  target_reads=$(( (TARGET_SIZE_MB * 1024 * 1024) / avg_read_size ))
  target_reads=$(( target_reads < total_reads ? target_reads : total_reads ))

  echo "🎯 Target: ~$TARGET_SIZE_MB MB — keeping ~$target_reads of $total_reads reads"

  # Step 2: Subsample using reformat.sh
  echo "🚀 Running reformat.sh on $base..."
  if reformat.sh \
    in1="$trimmed1" in2="$trimmed2" \
    out1="$subsampled1" out2="$subsampled2" \
    samplereadstarget="$target_reads" \
    overwrite=t >> "$log" 2>&1; then
      echo "✅ Finished $base — output saved in $OUTPUT_DIR/"
      rm -f "$trimmed1" "$trimmed2"
  else
      echo "❌ reformat.sh failed for $base. See log: $log"
      continue
  fi
done

echo "🎉 All FASTQ files trimmed and downsampled."
