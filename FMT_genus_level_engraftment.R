#!/usr/bin/env Rscript

# ---- Libraries ----
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(readr)))

# ---- Input Arguments ----
args <- commandArgs(trailingOnly = TRUE)

if(length(args) != 4) {
  stop("Usage: Rscript FMT_genus_analysis.R <donor.tsv> <baseline.tsv> <day15.tsv> <day28.tsv>")
}

donor_file    <- args[1]
baseline_file <- args[2]
day15_file    <- args[3]
day28_file    <- args[4]

# ---- Read Input Files ----
donor_df    <- read_tsv(donor_file, show_col_types = FALSE)
baseline_df <- read_tsv(baseline_file, show_col_types = FALSE)
day15_df    <- read_tsv(day15_file, show_col_types = FALSE)
day28_df    <- read_tsv(day28_file, show_col_types = FALSE)

# ---- Extract Unique Genera ----
donor_genus    <- unique(donor_df$genus)
baseline_genus <- unique(baseline_df$genus)
day15_genus    <- unique(day15_df$genus)
day28_genus    <- unique(day28_df$genus)

# ---- Identify Genera X (Donor but not Baseline) ----
genus_X <- setdiff(donor_genus, baseline_genus)

# ---- Build Result Table ----
df <- data.frame(
  Genus = genus_X,
  Present_Day15 = genus_X %in% day15_genus,
  Present_Day28 = genus_X %in% day28_genus,
  stringsAsFactors = FALSE
)

# ---- Filter: Only genera that appear in Day15 or Day28 ----
df_filtered <- df %>% filter(Present_Day15 | Present_Day28)

# ---- Save Output ----
output_file <- "FMT_genus_X_table.tsv"
write.table(df_filtered, file = output_file, sep = "\t", row.names = FALSE, quote = FALSE)
cat("✅ Output written to:", output_file, "\n")
