library(data.table)
library(ggplot2)
library(gridExtra)
library(cowplot)

## Set working directory
setwd("~/github/mpi_dogs/")
# for ben
# setwd("~/GoogleDrive/mpi_dogs/")

## Read in the txt file with dog office and category information
dt.dog_office <- fread('data/dog_samples/R_prep/dog_env_samples_24_v1.txt', na.strings = c('-','NA',''))

## Read in the tsv file with the quicksand data for all samples
dt.tax <- fread('data/env_samples/quicksand.v2/final_report.tsv', na.strings = c('-','NA',''))

## Merge dt.tax with dt.dog_office to include category information
dt.tax_filtered <- merge(dt.tax, dt.dog_office[, .(sample_id, category, category2, office)], by="sample_id", all.x=TRUE)

## Filter for only Hominidae and Canidae families
relevant_families <- c('Hominidae', 'Canidae')
dt.tax_filtered <- dt.tax_filtered[Family %in% relevant_families]

## Add wall information, treating empty categories as "No Wall"
dt.tax_filtered[, is_wall := ifelse(category == "wall", "Wall", "No Wall")]
dt.tax_filtered[is.na(is_wall) | is_wall == "", is_wall := "No Wall"]

dt.tax_filtered[, .N, category]

## Define offices to exclude
## also, the negative samples aren't all in NC?
#     sample_number           sample_id              office office_number     x
# 85:            85 negative_sample_gr1                <NA>          <NA>    NA
# 86:            86 negative_sample_gr2                <NA>          <NA>    NA
# 87:            87 negative_sample_gr3                <NA>          <NA>    NA
# 88:            88 negative_sample_gr4                <NA>          <NA>    NA
offices_to_exclude <- c("NC", "Mimi/Linda Hallway", "Tracy/Silke Hallway", "Main Entrance")

## Filter out the excluded offices
dt.tax_filtered <- dt.tax_filtered[!office %in% offices_to_exclude]

## List the included offices
dt.tax_filtered[, .N, office]
dt.tax_filtered[is.na(office)]

## Define custom color scheme
custom_colors <- c("Canidae" = "#35978f", "Hominidae" = "#fed976")

## Function to create a single boxplot with custom colors
create_single_boxplot <- function(data, title, x_label) {
  p <- ggplot(data, aes(x = is_wall, y = ReadsDeduped + 1, fill = Family)) +
    geom_boxplot(width = 0.7, alpha = 0.7) +
    stat_summary(fun = median, geom = "point", shape = 18, size = 3, color = "black") +
    scale_y_log10(labels = scales::comma) +
    scale_fill_manual(values = custom_colors) +
    theme_bw() +
    labs(title = title, x = x_label, y = "ReadsDeduped (log10 scale)")
  
  r.w <- data[is_wall == 'Wall', mean(ReadsDeduped)]
  r.o <- data[is_wall == 'No Wall', mean(ReadsDeduped)]
  cat('Avg  wall reads:', r.w, '\n')
  cat('Avg !wall reads:', r.o, '\n')
  cat('Ratio:', r.w/r.o, '\n')
  
  return(p)
}

## Creating the four separate plots
plot_dog_office_canidae <- create_single_boxplot(
  dt.tax_filtered[category2 == "dog_office" & Family == "Canidae"], 
  "Dog Office: Canidae", 
  "Sample Location"
) + theme(legend.position = "none")

plot_dog_office_hominidae <- create_single_boxplot(
  dt.tax_filtered[category2 == "dog_office" & Family == "Hominidae"], 
  "Dog Office: Hominidae", 
  "Sample Location"
) + theme(legend.position = "none")

plot_non_dog_office_canidae <- create_single_boxplot(
  dt.tax_filtered[category2 != "dog_office" & Family == "Canidae"], 
  "Non-Dog Location: Canidae", 
  "Sample Location"
) + theme(legend.position = "none")

plot_non_dog_office_hominidae <- create_single_boxplot(
  dt.tax_filtered[category2 != "dog_office" & Family == "Hominidae"], 
  "Non-Dog Location: Hominidae", 
  "Sample Location"
) + theme(legend.position = "none")

## Combine plots
combined_plots <- plot_grid(
  plot_dog_office_canidae,
  plot_non_dog_office_canidae,
  plot_dog_office_hominidae,
  plot_non_dog_office_hominidae,
  ncol = 2
)

print(combined_plots)

## Saving the combined plot
ggsave("figures/walls_vs_no_walls.png", combined_plots, width = 16, height = 16)




## T-Test
# Data walls vs not wall
wall_data <- dt.tax_filtered[is_wall == "Wall", ReadsDeduped]
no_wall_data <- dt.tax_filtered[is_wall == "No Wall", ReadsDeduped]

t_test_result <- t.test(wall_data, no_wall_data)

print(t_test_result)


##Data walls vs not wall (dog + human and office specific)

#dog office dogs
canidae_dog_office_wall <- dt.tax_filtered[category2 == "dog_office" & Family == "Canidae" & is_wall == "Wall", ReadsDeduped]
canidae_dog_office_no_wall <- dt.tax_filtered[category2 == "dog_office" & Family == "Canidae" & is_wall == "No Wall", ReadsDeduped]

#dog office human
hominidae_dog_office_wall <- dt.tax_filtered[category2 == "dog_office" & Family == "Hominidae" & is_wall == "Wall", ReadsDeduped]
hominidae_dog_office_no_wall <- dt.tax_filtered[category2 == "dog_office" & Family == "Hominidae" & is_wall == "No Wall", ReadsDeduped]

#not dog office dog
canidae_non_dog_office_wall <- dt.tax_filtered[category2 != "dog_office" & Family == "Canidae" & is_wall == "Wall", ReadsDeduped]
canidae_non_dog_office_no_wall <- dt.tax_filtered[category2 != "dog_office" & Family == "Canidae" & is_wall == "No Wall", ReadsDeduped]

#not dog office human
hominidae_non_dog_office_wall <- dt.tax_filtered[category2 != "dog_office" & Family == "Hominidae" & is_wall == "Wall", ReadsDeduped]
hominidae_non_dog_office_no_wall <- dt.tax_filtered[category2 != "dog_office" & Family == "Hominidae" & is_wall == "No Wall", ReadsDeduped]

#t-test for each groupe
t_test_canidae_dog_office <- t.test(canidae_dog_office_wall, canidae_dog_office_no_wall)
t_test_hominidae_dog_office <- t.test(hominidae_dog_office_wall, hominidae_dog_office_no_wall)
t_test_canidae_non_dog_office <- t.test(canidae_non_dog_office_wall, canidae_non_dog_office_no_wall)
t_test_hominidae_non_dog_office <- t.test(hominidae_non_dog_office_wall, hominidae_non_dog_office_no_wall)

print(t_test_canidae_dog_office)
print(t_test_hominidae_dog_office)
print(t_test_canidae_non_dog_office)
print(t_test_hominidae_non_dog_office)

######
## messing around with mixed effects models - have to talk to a real statistician!

library(lme4)

dt.tax_filtered[, office.n_obs := .N, office]
dt.tax_filtered[office.n_obs > 4, .N, category2]

mixed.lmer <- lmer(ReadsDeduped ~ is_wall + (1|office), 
                   data = dt.tax_filtered)
summary(mixed.lmer)

<<<<<<< HEAD
## Save combined plot with jitter
ggsave("figures/walls_vs_no_walls_with_jitter.png", combined_plot_with_jitter, width = 16, height = 8)

=======
mixed.lmer <- lmer(ReadsDeduped ~ is_wall + (1|category2) + Family, 
                   data = dt.tax_filtered)
summary(mixed.lmer)
>>>>>>> bf9910a36297a1073f2b89f3fc52c3125868e694
