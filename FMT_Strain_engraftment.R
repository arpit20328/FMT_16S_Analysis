#!/usr/bin/env Rscript

# ---- Libraries ----
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(readr)))

# ---- Input Arguments ----
args <- commandArgs(trailingOnly = TRUE)

if(length(args) != 4) {
  stop("Usage: Rscript FMT_strain_engraftment.R <donor.tsv> <baseline.tsv> <day15.tsv> <day28.tsv>")
}

donor_file    <- args[1]
baseline_file <- args[2]
day15_file    <- args[3]
day28_file    <- args[4]

# ---- Read Input Files ----
read_strains <- function(file) {
  read_tsv(file, col_names = c("Strain", "Abundance"), show_col_types = FALSE) %>%
    filter(!is.na(Strain) & Abundance > 0)
}

donor_df    <- read_strains(donor_file)
baseline_df <- read_strains(baseline_file)
day15_df    <- read_strains(day15_file)

# Handle optional day28
if (tolower(day28_file) == "na") {
  day28_df <- data.frame(Strain = character(), Abundance = numeric(), stringsAsFactors = FALSE)
} else {
  day28_df <- read_strains(day28_file)
}

# ---- Identify Strain X (in donor but not in baseline) ----
strain_X <- setdiff(donor_df$Strain, baseline_df$Strain)

# ---- Check presence in Day15 and Day28 ----
strain_presence <- data.frame(
  Strain = strain_X,
  Present_Day15 = strain_X %in% day15_df$Strain,
  Present_Day28 = strain_X %in% day28_df$Strain,
  stringsAsFactors = FALSE
)

# ---- Filter strains present in Day15 or Day28 ----
strain_filtered <- strain_presence %>% filter(Present_Day15 | Present_Day28)

# ---- Save Output ----
output_file <- "FMT_strain_X_table.tsv"
write.table(strain_filtered, file = output_file, sep = "\t", row.names = FALSE, quote = FALSE)
cat("✅ Output written to:", output_file, "\n")
