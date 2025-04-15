library(data.table)
library(ggplot2)
library(dplyr)

# Set working directory
setwd("~/github/mpi_dogs_2.0/")

# Read the main CSV file with dog data
dt.main <- fread('data/dog_samples/R_prep/all_dogs_with_ThorA_Cami_without_Lily/R_prep_sample_vs_dog_all_dogs_with_ThorA_Cami_without_Lily_10snp.csv', na.strings = c('-', 'NA', ''))


# Read the TXT file with location categories
dt.categories <- fread('data/dog_samples/R_prep/sample_location.txt', na.strings = c('-', 'NA', ''))

# Read the new TSV file for filtering
dt.filter <- fread('data/env_samples/quicksand.v2/final_report.tsv', na.strings = c('-', 'NA', ''))


# Define the threshold for ReadsDeduped
reads_threshold <- 50  

# Filter the new TSV file based on conditions
dt.filter_valid <- dt.filter[Family == "Canidae" & ReadsDeduped >= reads_threshold]


# Get the list of sample_ids that meet the criteria
valid_samples <- dt.filter_valid$sample_id

# Filter the main data to include only valid samples
dt.main_filtered <- dt.main[sample_id %in% valid_samples]

# Define custom order for locations
custom_order <- c("Dog Office (Container)", "Dog Office (Lily/ThorA)", "Hallway (Lily/ThorA)", 
                  "Dog Office (Anda/Charlie)", "Hallway (Anda/Charlie)", "Non-Dog Office", 
                  "Elevator", "Main Entrance", "Lab (PCR Lab)", "Lab (Cleanroom)", 
                  "Negativ Control")

# Merge main data with categories
dt.combined <- merge(dt.main_filtered, dt.categories, by = "sample_id", all.x = TRUE)

# Reshape data to long format
dt.long <- melt(dt.combined, id.vars = c("sample_id", "location"), 
                variable.name = "dog", value.name = "value")

# Extract number from sample_id for sorting
dt.long[, sample_number := as.numeric(sub(".*_", "", sample_id))]

# Sort data by location and sample_number
setorder(dt.long, location, sample_number)

# Apply custom order to location factor
dt.long$location <- factor(dt.long$location, levels = custom_order)

# Create the bar plot with asterisks for NA values
p <- ggplot() +
  # Add bars only for non-NA values
  geom_bar(data = dt.long[!is.na(value)], aes(x = factor(sample_id), y = value, fill = dog), 
           stat = "identity", position = "dodge") +
  # Add asterisks for NA values (valid samples with missing data)
  geom_text(data = dt.long[is.na(value)], aes(x = factor(sample_id), y = 0, label = "*"), 
            position = position_dodge(width = 0.9), vjust = -0.5) +
  facet_grid(dog ~ location, scales = "free_x", space = "free_x") +
  theme_bw() +
  labs(title = "Dog Values by Sample and Location (Filtered)",
       x = "Sample ID", y = "Value", fill = "Dog") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        strip.text = element_text(size = 10, face = "bold"),
        legend.position = "none") 

print(p)


# Save the plot
ggsave("figures/subfig_1.png", p, width = 24, height = 20, limitsize = FALSE)


# --------------new plot with Readsdeduped -----------------

# create file for further manual modifications
dt.reads_merge <- merge(dt.combined, dt.filter_valid, by = "sample_id", all.x = TRUE)
write.csv(dt.reads_merge, "data/dog_samples/R_prep/all_dogs_with_ThorA_Cami_without_Lily/dt.reads_merge.csv") #just modify it to show ReadsDeduped in plot


dt_reads <- fread('data/dog_samples/R_prep/all_dogs_with_ThorA_Cami_without_Lily/R_prep_sample_vs_dog_all_dogs_with_ThorA_Cami_without_Lily_10snp_mod.csv', na.strings = c('-', 'NA', ''))

custom_order <- c("Dog Office (Container)", "Dog Office (Lily/ThorA)", "Hallway (Lily/ThorA)", "Dog Office (Anda/Charlie)", "Hallway (Anda/Charlie)", "Non-Dog Office", "Elevator", "Main Entrance", "Lab (PCR Lab)", "Lab (Cleanroom)", "Negativ Control")

dog_columns <- setdiff(names(dt_reads), c("sample_id", "location"))

dt_reads.long <- melt(dt_reads, id.vars = c("sample_id", "location"), 
                      variable.name = "dog", value.name = "value")

dt_reads.long[, sample_number := as.integer(sub("sample_(\\d+)\\(.*", "\\1", sample_id))]

dt_reads.long$location <- factor(dt_reads.long$location, levels = custom_order)

p_reads <- ggplot() +
  # Add bars only for non-NA values
  geom_bar(data = dt_reads.long[!is.na(value)], aes(x = factor(sample_id), y = value, fill = dog), 
           stat = "identity", position = "dodge") +
  # Add asterisks for NA values at the correct positions
  geom_text(data = dt_reads.long[is.na(value)], aes(x = factor(sample_id), y = 0, label = "*"), 
            position = position_dodge(width = 0.9), vjust = -0.5) +
  facet_grid(dog ~ location, scales = "free_x", space = "free_x") +
  theme_bw() +
  labs(title = "Dog Values by Sample and Location",
       x = "Sample ID", y = "Value", fill = "Dog") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        strip.text = element_text(size = 10, face = "bold"),
        legend.position = "none")
print(p_reads)

ggsave("figures/subfig_1.png", p_reads, width = 24, height = 20, limitsize = FALSE)
