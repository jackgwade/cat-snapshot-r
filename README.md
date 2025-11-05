CAT Snapshot: U.S. Severe Convective Storm Hotspots (2015–2024) in R

This project maps U.S. severe convective storm hotspots from 2015–2024 using NOAA’s Storm Events data. It focuses on three event types:

Tornado

Hail

Thunderstorm Wind

The output is a gridded hotspot map saved as figs/scs_hotspots_map.png.

Data source

All data come from the NOAA / NCEI Storm Events Database (bulk CSV files):

National Centers for Environmental Information (NCEI), Storm Events Database
https://www.ncei.noaa.gov/products/land-based-station/storm-events

For this project only the StormEvents details files are used (one row per event with time, location, and impacts).

How the data were obtained (manual download)

Instead of automatically downloading files from within R, the Storm Events data were manually downloaded:

Open the NCEI Storm Events Bulk Data interface.

For each year 2015–2024, download the compressed details file:

StormEvents_details-ftp_v1.0_dYYYY_c*.csv.gz


Save all of these files into:

data/raw/


The script R/01_manifest_and_download.R in this repo is an optional helper for automating downloads, but the results shown here are based on these manually downloaded files in data/raw/.

Pipeline overview

Once the raw .csv.gz files are in data/raw/, there are two main scripts:

1. Build the combined severe-convective dataset

Script: R/02_build_working_set.R

This script:

Finds all StormEvents_details-*.csv.gz files in data/raw/.

Reads and combines them into a single data frame.

Filters to severe convective storms:

"Tornado", "Hail", "Thunderstorm Wind"

Selects and cleans key fields:

YEAR, STATE, CZ_NAME, EVENT_TYPE

DAMAGE_PROPERTY, DEATHS_DIRECT, INJURIES_DIRECT

BEGIN_LAT, BEGIN_LON, END_LAT, END_LON

Writes the processed dataset to:

data/processed/scs_combined_2015_2024.csv

2. Visualize hotspots

Script: R/03_visualize_hotspots.R

This script:

Reads data/processed/scs_combined_2015_2024.csv.

Filters to events between 2015 and 2024, dropping rows with missing coordinates.

Bins events into a regular 2° × 2° latitude/longitude grid across the CONUS.

Uses ggplot2 to draw:

U.S. state outlines for context.

A filled tile layer where color intensity represents the number of reports in each grid cell.

Saves the final map to:

figs/scs_hotspots_map.png

How to reproduce the analysis
1. Clone the repo
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>

2. Open the R project

Open cat-snapshot-r.Rproj in RStudio.

3. Install packages (first time only)

In R:

install.packages(c(
  "readr",
  "dplyr",
  "purrr",
  "ggplot2",
  "sf",
  "tigris",
  "viridis"
))

4. Download data manually

From the NCEI Storm Events Bulk Data page, download all
StormEvents_details-ftp_v1.0_dYYYY_c*.csv.gz files for years 2015–2024.

Place them in:

data/raw/

5. Build the working dataset

In RStudio:

source("R/02_build_working_set.R")


This creates data/processed/scs_combined_2015_2024.csv.

6. Create the hotspot map

Then run:

source("R/03_visualize_hotspots.R")


The figure will be saved as figs/scs_hotspots_map.png.

Repository structure
.
├── R
│   ├── 01_manifest_and_download.R   # optional download helper (not required if you download manually)
│   ├── 02_build_working_set.R       # reads NOAA details files and builds SCS dataset
│   └── 03_visualize_hotspots.R      # produces the hotspot map
├── data
│   ├── raw/                         # manually downloaded StormEvents_details-*.csv.gz (gitignored)
│   └── processed/
│       └── scs_combined_2015_2024.csv
├── figs
│   └── scs_hotspots_map.png         # final map output
├── .gitignore
├── cat-snapshot-r.Rproj
└── README.md


Note: data/ is ignored by Git via .gitignore, so raw and processed data are not committed to the repository.

Caveats

Only three event types are included: Tornado, Hail, and Thunderstorm Wind.

The hotspot map is based on reported events, which can be influenced by population density, observation practices, and reporting systems.

Only “details” files are used; location and fatality tables are not yet incorporated.

Contributions

Suggestions and improvements are welcome.
Open an issue or submit a pull request if you’d like to extend or refine the analysis or visualization.