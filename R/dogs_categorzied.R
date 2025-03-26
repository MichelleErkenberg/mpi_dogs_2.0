library(data.table)
library(ggplot2)

# Set working directory
setwd("~/github/mpi_dogs/")

# Read the main CSV file with dog data, leaving empty fields as NA
#dt.main <- fread('data/dog_samples/R_prep/all_dogs_ACwoL/R_prep_sample_vs_dog_ACwoL_2snp_renamed.csv', na.strings = c('-', 'NA', ''))
#dt.main <- fread('data/dog_samples/R_prep/all_dogs_ACwoL/R_prep_sample_vs_dog_ACwoL_5snp_renamed.csv', na.strings = c('-', 'NA', ''))
dt.main <- fread('data/dog_samples/R_prep/all_dogs_ACwoL/R_prep_sample_vs_dog_ACwoL_10snp_renamed.csv', na.strings = c('-', 'NA', ''))

# Read the TXT file with location categories
dt.categories <- fread('data/dog_samples/R_prep/sample_location.txt', na.strings = c('-', 'NA', ''))

# Define custom order for locations (adjust this list as needed)
custom_order <- c("Dog Office (Container)", "Dog Office (Lily/ThorA)", "Hallway (Lily/ThorA)", "Dog Office (Anda/Charlie)", "Hallway (Anda/Charlie)", "Non-Dog Office", "Elevator", "Main Entrance", "Lab (PCR Lab)", "Lab (Cleanroom)", "Negativ Control")  # Beispiel: Reihenfolge der Locations

# Merge main data with categories
dt.combined <- merge(dt.main, dt.categories, by = "sample_id", all.x = TRUE)

# Identify dog columns (all columns except sample_id and location)
dog_columns <- setdiff(names(dt.combined), c("sample_id", "location"))

# Reshape data to long format
dt.long <- melt(dt.combined, id.vars = c("sample_id", "location"), 
                variable.name = "dog", value.name = "value")

# Replace NA values in the value column with NA (keine Balken für fehlende Werte)
dt.long[, value := ifelse(is.na(value), NA, value)]

# Extract number from sample_id for sorting
dt.long[, sample_number := as.numeric(sub(".*_", "", sample_id))]

# Sort data by location and sample_number
setorder(dt.long, location, sample_number)

# Apply custom order to location factor
if (length(custom_order) > 0) {
  dt.long$location <- factor(dt.long$location, levels = custom_order)
} else {
  dt.long$location <- factor(dt.long$location, levels = unique(dt.long$location))
}

# Create the bar plot ensuring only relevant sample_ids are shown for each location
p <- ggplot() +
  # Add bars only for non-NA values
  geom_bar(data = dt.long[!is.na(value)], aes(x = factor(sample_id), y = value, fill = dog), 
           stat = "identity", position = "dodge") +
  # Add asterisks for NA values at the correct positions
  geom_text(data = dt.long[is.na(value)], aes(x = factor(sample_id), y = 0, label = "*"), 
            position = position_dodge(width = 0.9), vjust = -0.5) +
  facet_grid(dog ~ location, scales = "free_x", space = "free_x") +
  theme_bw() +
  labs(title = "Dog Values by Sample and Location",
       x = "Sample ID", y = "Value", fill = "Dog") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        strip.text = element_text(size = 10, face = "bold"),
        legend.position = "none")

# Apply custom colors if defined
custom_colors <- c()  # Add your custom colors here if needed
if (length(custom_colors) > 0) {
  p <- p + scale_fill_manual(values = custom_colors)
}

print(p)


# Save the plot
#ggsave("figures/dogs_categorized_2snp.png", p, width = 24, height = length(dog_columns) * 2, limitsize = FALSE)
#ggsave("figures/dogs_categorized_5snp.png", p, width = 24, height = length(dog_columns) * 2, limitsize = FALSE)
#ggsave("figures/dogs_categorized_10snp.png", p, width = 24, height = length(dog_columns) * 2, limitsize = FALSE)

