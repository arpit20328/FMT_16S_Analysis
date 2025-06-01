#!/usr/bin/env Rscript

# ---- Libraries ----
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(readr)))

# ---- Input Arguments ----
args <- commandArgs(trailingOnly = TRUE)

if(length(args) != 4) {
  stop("Usage: Rscript FMT_family_analysis.R <donor.tsv> <baseline.tsv> <day15.tsv> <day28.tsv>")
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

# ---- Extract Unique Families ----
donor_family    <- unique(donor_df$family)
baseline_family <- unique(baseline_df$family)
day15_family    <- unique(day15_df$family)
day28_family    <- unique(day28_df$family)

# ---- Identify Family X (Donor but not Baseline) ----
family_X <- setdiff(donor_family, baseline_family)

# ---- Build Result Table ----
df <- data.frame(
  Family = family_X,
  Present_Day15 = family_X %in% day15_family,
  Present_Day28 = family_X %in% day28_family,
  stringsAsFactors = FALSE
)

# ---- Filter: Only families that appear in Day15 or Day28 ----
df_filtered <- df %>% filter(Present_Day15 | Present_Day28)

# ---- Save Output ----
output_file <- "FMT_family_X_table.tsv"
write.table(df_filtered, file = output_file, sep = "\t", row.names = FALSE, quote = FALSE)
cat("✅ Output written to:", output_file, "\n")
