library(data.table)
library(ggplot2)
library(dplyr)

## Set working directory
setwd("~/github/mpi_dogs/")

## Read in the txt file with dog office and category information
dt.dog_office <- fread('data/dog_samples/R_prep/dog_env_samples_24_v1.txt', na.strings = c('-','NA',''))

## Read in the tsv file with the quicksand data for all samples
dt.tax <- fread('data/env_samples/quicksand.v2/final_report.tsv', na.strings = c('-','NA',''))

# Define threshold
threshold_reads <- 15000 

## Filter and prepare the data
dt.tax_filtered <- merge(dt.tax, dt.dog_office[, .(sample_id, category, category2, office)], by="sample_id", all.x=TRUE)
dt.tax_filtered <- dt.tax_filtered[ReadsRaw >= threshold_reads]
dt.tax_filtered <- dt.tax_filtered[Family %in% c('Hominidae', 'Canidae')]

# Print information about removed samples
total_samples <- nrow(dt.tax)
filtered_samples <- nrow(dt.tax_filtered)
removed_samples <- total_samples - filtered_samples
print(paste("Removed", removed_samples, "samples below the threshold of", threshold_reads, "reads."))

## Define family order and custom colors
custom_colors <- c("Hominidae" = "#fed976", "Canidae" = "#35978f")

## Extract unique categories
unique_categories <- unique(dt.dog_office$category2)
print(unique_categories)

## Manual adjustments
category_mapping <- c(
  "dog_office" = "Dog Office",
  "main-entrance" = "Main Entrance",
  "elevator" = "Elevator",
  "hallway" = "Hallway",
  "nc_office" = "No Dog Office",
  "nc" = "Negative Control",
  "lab" = "Lab"
)

## Apply the mapping to create the Category column
dt.tax_filtered[, Category := factor(category2, levels = names(category_mapping), labels = category_mapping)]

## Create a new column for combined category labels, only for "lab" category
dt.tax_filtered[, CategoryLabel := ifelse(category2 == "lab", 
                                          paste0(Category, " (", office, ")"), 
                                          as.character(Category))]

# unique lab categories 
lab_categories <- sort(unique(dt.tax_filtered[category2 == "lab", CategoryLabel]))

# define order
custom_order <- c(
  "Negative Control",
  lab_categories[1],  # "Lab (Cleanroom)"
  lab_categories[2],  # "Lab (PCR Lab)"
  "No Dog Office",
  "Hallway", 
  "Elevator",
  "Main Entrance",
  "Dog Office"
)

## Ensure the order of categories is preserved with the custom order
dt.tax_filtered[, ReadsDeduped := ReadsDeduped + 1]

## Count unique samples per location after filtering
sample_counts <- dt.tax_filtered[, .(N = uniqueN(sample_id)), by = .(CategoryLabel)][
  , CategoryLabel := factor(CategoryLabel, levels = custom_order)
][order(CategoryLabel)]

## Create new labels with sample counts
sample_counts[, CategoryLabelWithCount := paste0(CategoryLabel, "\n(n = ", N, ")")]

## Update factor levels in the main dataset
dt.tax_filtered[, CategoryLabelWithCount := factor(
  CategoryLabel,
  levels = sample_counts$CategoryLabel,
  labels = sample_counts$CategoryLabelWithCount
)]


## Create the plot
ggplot(dt.tax_filtered, aes(x = ReadsDeduped, y = CategoryLabelWithCount, fill = Family)) +
  geom_boxplot(position = position_dodge(width = 0.8), width = 0.7, alpha = 0.7) +
  coord_cartesian(xlim = c(1, max(dt.tax_filtered$ReadsDeduped, na.rm = TRUE))) +
  scale_x_log10(labels = scales::comma) +
  theme_bw() +
  labs(title = "Distribution of Reads by Location and Family",
       x = "mtDNA (log10 scale)",
       y = "Location",
       fill = "Family") +  
  theme(
    legend.position = "bottom",  
    legend.box.just = "center",  
    legend.margin = margin(t = 0, r = 0, b = 0, l = 0)) +
  scale_fill_manual(values = custom_colors)

## Save the plot
ggsave("figures/category_family_distribution.png", width = 12, height = 10)



##show the impact of the threshold as a table

# Merge dt.tax with location information
dt.merged <- merge(dt.tax, dt.dog_office[, .(sample_id, category, category2, office)], by="sample_id", all.x=TRUE)

# Create CategoryLabel column
dt.merged[, CategoryLabel := ifelse(category2 == "lab", 
                                    paste0(category_mapping[category2], " (", office, ")"), 
                                    category_mapping[category2])]

# Count samples per location without threshold
count_without_threshold <- dt.merged[, .(n_without_threshold = uniqueN(sample_id)), by = CategoryLabel]

# Count samples per location with threshold
count_with_threshold <- dt.merged[ReadsRaw >= threshold_reads, .(n_threshold = uniqueN(sample_id)), by = CategoryLabel]

# Merge the counts
result_table <- merge(count_without_threshold, count_with_threshold, by = "CategoryLabel", all = TRUE)

# Replace NA with 0 for locations that have no samples after threshold
result_table[is.na(n_threshold), n_threshold := 0]

# Calculate the difference
result_table[, difference := n_without_threshold - n_threshold]

# Order the table based on the custom order
result_table[, CategoryLabel := factor(CategoryLabel, levels = custom_order)]
setorder(result_table, CategoryLabel)

# Print the result
print(result_table)



