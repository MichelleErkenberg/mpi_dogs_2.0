#install.packages(c("reshape2", "gridExtra"))
library(ggplot2)
library(reshape2)
library(gridExtra)

setwd("~/github/mpi_dogs/")

### ------------------Heatmaps container office-------------------

data_container <- read.csv("data/dog_samples/R_prep/all_dogs_AC/Container.csv")

# Heatmap for each Container dog
heatmap_heidi <- ggplot(data_container, aes(x = x, y = y, fill = AC.Heidi)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "blue", limits = c(0, 1)) +
  scale_x_continuous(breaks = unique(data_container$X)) +
  scale_y_continuous(breaks = unique(data_container$Y)) +
  coord_fixed() +
  labs(title = "Heatmap for Heidi") +
  theme_minimal() +
  theme(
    axis.title = element_blank(),  
    panel.grid = element_blank(),
    axis.text = element_blank(),
    legend.title = element_blank()
  )


heatmap_vito <- ggplot(data_container, aes(x = x, y = y, fill = AC.Vito)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "blue", limits = c(0, 1)) +
  scale_x_continuous(breaks = unique(data_container$X)) +
  scale_y_continuous(breaks = unique(data_container$Y)) +
  coord_fixed() +
  labs(title = "Heatmap for Vito") +
  theme_minimal() +
  theme(
    axis.title = element_blank(),  
    panel.grid = element_blank(),
    axis.text = element_blank(),
    legend.title = element_blank()
  )

heatmap_fritzy <- ggplot(data_container, aes(x = x, y = y, fill = AC.Fritzy)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "blue", limits = c(0, 1)) +
  scale_x_continuous(breaks = unique(data_container$X)) +
  scale_y_continuous(breaks = unique(data_container$Y)) +
  coord_fixed() +
  labs(title = "Heatmap for Fritzy") +
  theme_minimal() +
  theme(
    axis.title = element_blank(),  
    panel.grid = element_blank(),
    axis.text = element_blank(),
    legend.title = element_blank()
  )

heatmap_urza <- ggplot(data_container, aes(x = x, y = y, fill = AC.Urza)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "blue", limits = c(0, 1)) +
  scale_x_continuous(breaks = unique(data_container$X)) +
  scale_y_continuous(breaks = unique(data_container$Y)) +
  coord_fixed() +
  labs(title = "Heatmap for Urza") +
  theme_minimal() +
  theme(
    axis.title = element_blank(),  
    panel.grid = element_blank(),
    axis.text = element_blank(),
    legend.title = element_blank()
  ) 


print(heatmap_heidi)
print(heatmap_vito)
print(heatmap_fritzy)
print(heatmap_urza)
combined_plot_container <- grid.arrange(heatmap_fritzy, heatmap_heidi, heatmap_urza, heatmap_vito, ncol = 2)
#ggsave("figures/container_office_dogs_heatmap.png", combined_plot_container, width = 16, height = 16)


### ---------------------------heatmaps for Thor A and Lily office ----------------------


data_thorA_lily <- read.csv("data/dog_samples/R_prep/Mimi_Linda.csv")


# Heatmap for each dog
heatmap_lily <- ggplot(data_thorA_lily, aes(x = x, y = y, fill = Lily)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "blue", limits = c(0, 1)) +
  scale_x_continuous(breaks = unique(data_thorA_lily$X)) +
  scale_y_continuous(breaks = unique(data_thorA_lily$Y)) +
  coord_fixed() +
  labs(title = "Heatmap for Lily") +
  theme_minimal() +
  theme(
    axis.title = element_blank(),  
    panel.grid = element_blank(),
    axis.text = element_blank(),
    legend.title = element_blank()
  )


heatmap_thorA <- ggplot(data_thorA_lily, aes(x = x, y = y, fill = ThorA)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "blue", limits = c(0, 1)) +
  scale_x_continuous(breaks = unique(data_thorA_lily$X)) +
  scale_y_continuous(breaks = unique(data_thorA_lily$Y)) +
  coord_fixed() +
  labs(title = "Heatmap for ThorA") +
  theme_minimal() +
  theme(
    axis.title = element_blank(),  
    panel.grid = element_blank(),
    axis.text = element_blank(),
    legend.title = element_blank()
  )



print(heatmap_lily)
print(heatmap_thorA)
combined_plot_thorA_lily <- grid.arrange(heatmap_lily, heatmap_thorA, ncol = 1)
ggsave("figures/thorA_lily_office_dogs_heatmap.png", combined_plot_thorA_lily, width = 16, height = 16)
