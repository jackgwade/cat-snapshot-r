# =======================================================
# 03_visualize_hotspots.R
# Purpose: Map Severe Convective Storm hotspots, 2015–2024
# =======================================================

library(readr)
library(dplyr)
library(ggplot2)
library(viridis)
library(maps)

# --- Load processed SCS dataset -------------------------
scs <- read_csv(
  "data/processed/scs_combined_2015_2024.csv",
  show_col_types = FALSE
) %>%
  mutate(
    BEGIN_LAT = as.numeric(BEGIN_LAT),
    BEGIN_LON = as.numeric(BEGIN_LON)
  ) %>%
  filter(
    !is.na(BEGIN_LAT), !is.na(BEGIN_LON),
    dplyr::between(BEGIN_LAT, 24, 50),
    dplyr::between(BEGIN_LON, -125, -66)
  )

# Quick sanity check
message("Rows in scs after filtering: ", nrow(scs))

# --- State outlines -------------------------------------
states <- map_data("state")

# --- Plot ------------------------------------------------
p <- ggplot() +
  # heatmap layer
  stat_bin2d(
    data = scs,
    aes(x = BEGIN_LON, y = BEGIN_LAT, fill = after_stat(count)),
    bins  = 100,
    alpha = 0.95
  ) +
  # state borders on top
  geom_polygon(
    data = states,
    aes(x = long, y = lat, group = group),
    fill = NA,
    color = "white",
    linewidth = 0.25
  ) +
  scale_fill_viridis_c(
    name   = "Reports (2015–2024)",
    option = "plasma",
    trans  = "sqrt",
    breaks = c(1, 10, 50, 200, 500, 1000, 2000),
    labels = c("1", "10", "50", "200", "500", "1k", "2k+")
  ) +
  coord_fixed(
    xlim = c(-125, -66),
    ylim = c(24, 50),
    expand = FALSE
  ) +
  labs(
    title    = "Severe Convective Storm Hotspots (2015–2024)",
    subtitle = "Tornado, hail, and thunderstorm wind reports in 2°×2° bins",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    panel.background = element_rect(fill = "grey10", color = NA),
    plot.background  = element_rect(fill = "grey10", color = NA),
    panel.grid       = element_blank(),
    axis.title       = element_text(color = "grey90"),
    axis.text        = element_text(color = "grey80"),
    plot.title       = element_text(color = "white", face = "bold", size = 16),
    plot.subtitle    = element_text(color = "grey80"),
    legend.title     = element_text(color = "grey90"),
    legend.text      = element_text(color = "grey80")
  )

print(p)

# --- Save figure ----------------------------------------
dir.create("figs", showWarnings = FALSE)
ggsave("figs/scs_hotspots_map.png", p, width = 10, height = 6, dpi = 300)
message("✅ Saved map to figs/scs_hotspots_map.png")
