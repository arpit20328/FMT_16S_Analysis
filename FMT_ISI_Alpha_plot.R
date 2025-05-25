library(ggplot2)
library(dplyr)

# Prompt for number of patients
cat("Enter number of patients:\n")
num_patients <- as.integer(readLines("stdin", n = 1))

# Initialize lists
subject_names <- character(num_patients)
donor_names <- character(num_patients)
donor_isi <- numeric(num_patients)

isi_values <- list()
alpha_values <- list()

# Collect input for each patient
for (i in 1:num_patients) {
  cat(paste0("Enter patient ", i, " name:\n"))
  subject_names[i] <- readLines("stdin", n = 1)

  cat(paste0("Enter donor name for ", subject_names[i], ":\n"))
  donor_names[i] <- readLines("stdin", n = 1)

  cat(paste0("Enter donor ISI for ", subject_names[i], ":\n"))
  donor_isi[i] <- as.numeric(readLines("stdin", n = 1))

  cat(paste0("Enter ISI values for ", subject_names[i], " at pre fmt, day15, day28 (use NA if not present):\n"))
  isi_values[[i]] <- as.numeric(strsplit(readLines("stdin", n = 1), "\\s+")[[1]])

  cat(paste0("Enter Alpha diversity values for ", subject_names[i], " at pre fmt, day15, day28 (use NA if not present):\n"))
  alpha_values[[i]] <- as.numeric(strsplit(readLines("stdin", n = 1), "\\s+")[[1]])
}

# Create combined data frames
timepoints <- factor(c("pre fmt", "day15", "day28"), levels = c("pre fmt", "day15", "day28"))

df_patient <- data.frame()
df_alpha <- data.frame()
legend_labels_isi <- character()
legend_labels_alpha <- character()

for (i in 1:num_patients) {
  temp_df_isi <- data.frame(
    Subject = subject_names[i],
    Timepoint = timepoints,
    ISI = isi_values[[i]]
  )
  df_patient <- rbind(df_patient, temp_df_isi)

  temp_df_alpha <- data.frame(
    Subject = subject_names[i],
    Timepoint = timepoints,
    Alpha = alpha_values[[i]]
  )
  df_alpha <- rbind(df_alpha, temp_df_alpha)

  legend_labels_isi[i] <- paste0(subject_names[i], " (Donor ISI: ", donor_isi[i], ")")
  legend_labels_alpha[i] <- paste0(subject_names[i], " (Donor: ", donor_names[i], ", α=", alpha_values[[i]][1], ")")
}

# Update factor levels for Subject
df_patient$Subject <- factor(df_patient$Subject, levels = subject_names, labels = legend_labels_isi)
df_alpha$Subject <- factor(df_alpha$Subject, levels = subject_names, labels = legend_labels_alpha)

# Plot ISI
ggplot(df_patient, aes(x = Timepoint, y = ISI, group = Subject, color = Subject)) +
  geom_line(size = 1.2, na.rm = TRUE) +
  geom_point(size = 3, na.rm = TRUE) +
  geom_text(aes(label = ifelse(!is.na(ISI), round(ISI, 2), "")), 
            vjust = -1.2, size = 3) +
  geom_hline(yintercept = 2, linetype = "dotted", color = "red") +
  annotate("text", x = 1, y = 2.15, label = "ISI = 2", hjust = 0, vjust = -0.2, size = 3.5, color = "red") +
  labs(title = "FMT ISI Trends (Patients Only)",
       x = "Time Point",
       y = "ISI Value",
       color = "Subjects (Donor ISI)") +
  theme_minimal()

# Plot Alpha
ggplot(df_alpha, aes(x = Timepoint, y = Alpha, group = Subject, color = Subject)) +
  geom_line(size = 1.2, na.rm = TRUE) +
  geom_point(size = 3, na.rm = TRUE) +
  geom_text(aes(label = ifelse(!is.na(Alpha), Alpha, "")), 
            vjust = -1.2, size = 3) +
  labs(title = "FMT Alpha Diversity Trends (Patients Only)",
       x = "Time Point",
       y = "Alpha Diversity",
       color = "Subjects (Donor α-value)") +
  theme_minimal()

