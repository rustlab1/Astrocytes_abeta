# Astrocytic autophagy and Aβ clearance RNA-seq preprocessing and analysis

**paper_title**: *Astrocytic autophagy plasticity modulates Aβ clearance and cognitive function in Alzheimer’s disease*  
**journal**: Molecular Neurodegeneration  
**publication_date**: "2024-07-23"  
**doi**: [10.1186/s13024-024-00739-w](https://doi.org/10.1186/s13024-024-00739-w)

This repository provides an end-to-end workflow for RNA-seq analysis of human astrocytes treated with Aβ versus untreated controls. It includes both preprocessing and analysis steps, using publicly available data from GEO and a reproducible command-line and R-based pipeline.

---

## Data sources

- **Public GEO Series**: [GSE267554](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE267554)  
- **Model**: Human astrocyte culture  
- **Groups used**: Control vs Aβ-treated for 12h  
- **Reference genome**: *Homo sapiens*, GRCh38 (platform: GPL11154)

---

## How to download

1. Install `fastp`, `BBMap`, `HISAT2`, `samtools`, and `subread` (for `featureCounts`)
2. Install R (≥ 4.2.2) with `DESeq2`, `BiocManager`, and other required packages
3. Download FASTQ files and GTF annotation from GEO and GENCODE

---

## Preprocessing

Preprocessing includes trimming, subsampling, alignment, and read quantification:

- **Read trimming**: Performed using `fastp` with quality and adapter trimming
- **Subsampling**: Done using `BBMap reformat.sh` to ~200MB per sample
- **Alignment**: Done with `HISAT2` to the GRCh38 genome
- **Quantification**: Carried out using `featureCounts` with GENCODE v43

---

## How the workflow works

### Step 1: Quality control
- **Purpose**: Assess read quality and expression distribution  
- **Tools**: `fastp`, `wc`, `awk`  
- **Outputs**: Trimmed, downsampled FASTQ files and read summaries

### Step 2: Reference setup
- **Purpose**: Download genome index and GTF annotation  
- **Tools**: `HISAT2` index (GRCh38), GENCODE v43  
- **Outputs**: Indexed genome and GTF file

### Step 3: Alignment
- **Purpose**: Map reads to the genome  
- **Tools**: `HISAT2`, `samtools`  
- **Outputs**: Sorted BAM files and BAM indexes

### Step 4: Quantification
- **Purpose**: Count reads per gene  
- **Tools**: `featureCounts`  
- **Outputs**: Raw and clean gene-level count matrices

### Step 5: Differential expression
- **Purpose**: Identify Aβ-regulated genes  
- **Tools**: `DESeq2`  
- **Outputs**: DESeq2 results with padj/log2FC, normalized counts

### Step 6: Visualization & summary
- **Purpose**: Visualize and report results  
- **Tools**: `DESeq2` plotting, R base plotting  
- **Outputs**: Volcano plot, MD plot, summary answer sheet

---

## Notes

- Subsampling to 200MB per sample was done to reduce compute load
- Default DESeq2 settings (Wald test, FDR < 0.05) were used
- Compatible with macOS and Linux; tested with R 4.2.2 and Bioconductor 3.16
