# q1: Number of genes represented in GSM8268694 (non-zero counts before filtering)
q1 <- sum(tbl[ , "GSM8268694"] > 0)
cat("q1 - Genes in GSM8268694:", q1, "\n")

# q2: Variance of log10 normalized expression in GSM8268707
q2 <- var(dat[ , "GSM8268707"])
cat("q2 - Variance in GSM8268707:", round(q2, 4), "\n")

# q3: Number of significantly differentially expressed genes (FDR < 0.05)
q3 <- sum(r$padj < 0.05, na.rm = TRUE)
cat("q3 - DE genes (FDR < 0.05):", q3, "\n")

# q4: Most upregulated gene by lowest FDR
q4 <- tT_all[tT_all$log2FoldChange > 0, ][1, "Symbol"]
cat("q4 - Most upregulated gene:", q4, "\n")

# q5: Most downregulated gene by lowest FDR
q5 <- tT_all[tT_all$log2FoldChange < 0, ][1, "Symbol"]
cat("q5 - Most downregulated gene:", q5, "\n")