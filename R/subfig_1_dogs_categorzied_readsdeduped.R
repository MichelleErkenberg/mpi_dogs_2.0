library(data.table)
library(ggplot2)
library(dplyr)
library(cowplot)


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


# Get the list of sample_ids and readsdeduped that meet the criteria
valid_samples <- dt.filter_valid$sample_id

# Filter the main data to include only valid samples and add + rename ReadsDeduped
dt.main_filtered <- dt.main[sample_id %in% valid_samples]
dt.filter_valid_reads <- dt.filter_valid[sample_id %in% valid_samples]
dt.main_filtered_reads <- mutate(dt.main_filtered, dt.filter_valid_reads$ReadsDeduped)
names(dt.main_filtered_reads)[names(dt.main_filtered_reads) == "dt.filter_valid_reads$ReadsDeduped"] <- "ReadsDeduped"

# Define custom order for locations
custom_order <- c("Dog Office (Container)", "Dog Office (Lily/ThorA)", "Hallway (Lily/ThorA)", 
                  "Dog Office (Anda/Charlie)", "Hallway (Anda/Charlie)", "Non-Dog Office", 
                  "Elevator", "Main Entrance", "Lab (PCR Lab)", "Lab (Cleanroom)", 
                  "Negativ Control")

# Merge main data with categories
dt.combined <- merge(dt.main_filtered_reads, dt.categories, by = "sample_id", all.x = TRUE)
dt.combined_reads <- select(dt.combined, sample_id, location, ReadsDeduped)

# Reshape data to long format
dt.long <- melt(dt.combined, id.vars = c("sample_id", "location", "ReadsDeduped"), 
                variable.name = "dog", value.name = "value")

# Extract number from sample_id for sorting
dt.long[, sample_number := as.numeric(sub(".*_", "", sample_id))]

# Sort data by location and sample_number
setorder(dt.long, location, sample_number)

# Apply custom order to location factor
dt.long$location <- factor(dt.long$location, levels = custom_order)
dt.combined_reads$location <- factor(dt.combined_reads$location, levels = custom_order)

#reorder sample_id
dt.long$sample_id <- factor(dt.long$sample_id, levels = paste0("sample_", c(1:85)))
dt.combined_reads$sample_id <- factor(dt.combined_reads$sample_id, levels = paste0("sample_", c(1:85)))

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

p_reads <- ggplot() +
  # Add bars only for non-NA values
  geom_bar(data = dt.combined_reads, aes(x = factor(sample_id), y = ReadsDeduped), 
           stat = "identity", position = "dodge") +
  facet_grid( ~ location, scales = "free_x", space = "free_x") +
  theme_bw() +
  labs(title = "ReadsDeduped by Sample and Location (Filtered)",
       x = "Sample ID", y = "ReadsDeduped") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        strip.text = element_text(size = 10, face = "bold"),
        legend.position = "none") 

print(p_reads)

#both plots in one graphic
p_grid <- plot_grid(p, p_reads,
          labels = "AUTO",
          nrow = 2,    #diagramms in two rows
          align = "v",
          axis = "lr", # alignment along left and right (x-axis)
          rel_heights = c(1/2, 1/3)) # heights of the diagramms

print(p_grid)

# Save the plot
ggsave("figures/subfig_1.png", p_grid, width = 24, height = 20, limitsize = FALSE)


