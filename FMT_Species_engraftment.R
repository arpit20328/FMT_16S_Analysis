#!/usr/bin/env Rscript

# ---- Libraries ----
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(readr)))

# ---- Input Arguments ----
args <- commandArgs(trailingOnly = TRUE)

if(length(args) != 4) {
  stop("Usage: Rscript FMT_species_analysis.R <donor.tsv> <baseline.tsv> <day15.tsv> <day28.tsv>")
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

# ---- Extract Unique Species ----
donor_species    <- unique(donor_df$species)
baseline_species <- unique(baseline_df$species)
day15_species    <- unique(day15_df$species)
day28_species    <- unique(day28_df$species)

# ---- Identify Species X (Donor but not Baseline) ----
species_X <- setdiff(donor_species, baseline_species)

# ---- Build Result Table ----
df <- data.frame(
  Species = species_X,
  Present_Day15 = species_X %in% day15_species,
  Present_Day28 = species_X %in% day28_species,
  stringsAsFactors = FALSE
)

# ---- Save Output ----
output_file <- "FMT_species_X_table.tsv"
write.table(df, file = output_file, sep = "\t", row.names = FALSE, quote = FALSE)
cat("✅ Output written to:", output_file, "\n")
