# CAT Snapshot: U.S. Severe Convective Storm Hotspots (2015–2024) in R

This project maps U.S. severe convective storm hotspots from 2015–2024 using NOAA’s Storm Events data.

It focuses on three event types:

- **Tornado**
- **Hail**
- **Thunderstorm Wind**

The main output is a gridded hotspot map saved as:

- `figs/scs_hotspots_map.png`

---

## Data Source

All data come from the NOAA / NCEI Storm Events Database (bulk CSV files):

- **National Centers for Environmental Information (NCEI)** – Storm Events Database  
  <https://www.ncei.noaa.gov/products/land-based-station/storm-events>

For this project only the **StormEvents _details_ files** are used (one row per event with time, location, and impacts).

---

## How the Data Were Obtained (Manual Download)

Instead of automatically downloading files from within R, the Storm Events data were **manually downloaded**:

1. Open the NCEI Storm Events Bulk Data interface.
2. For each year **2015–2024**, download the compressed **details** file:

   ```text
   StormEvents_details-ftp_v1.0_dYYYY_c*.csv.gz
Save all of these files into:


data/raw/
The script R/01_manifest_and_download.R in this repo is an optional helper for automating downloads, but the analysis and map shown here are based on these manually downloaded files in data/raw/.

Pipeline Overview
Once the raw .csv.gz files are in data/raw/, there are two main scripts.

## 1. Build the Combined Severe-Convective Dataset
Script: R/02_build_working_set.R

### This script:

Finds all StormEvents_details-*.csv.gz files in data/raw/.

Reads and combines them into a single data frame.

Filters to severe convective storms:

"Tornado"

"Hail"

"Thunderstorm Wind"

### Selects and cleans key fields:

YEAR, STATE, CZ_NAME, EVENT_TYPE

DAMAGE_PROPERTY, DEATHS_DIRECT, INJURIES_DIRECT

BEGIN_LAT, BEGIN_LON, END_LAT, END_LON

### Writes a processed CSV:

data/processed/scs_combined_2015_2024.csv


## 2. Visualize Severe Convective Hotspots
Script: R/03_visualize_hotspots.R

### This script:

Reads the combined dataset:

data/processed/scs_combined_2015_2024.csv
Filters to years 2015–2024 (safety check).


Bins events into a regular latitude/longitude grid (e.g., 2° × 2° bins).

Counts reports per grid cell.

Draws a U.S. map using ggplot2 with a dark theme and viridis color scale.

Saves the final figure to:

figs/scs_hotspots_map.png


## How to Run the Project



source("R/02_build_working_set.R")
Create working set

source("R/03_visualize_hotspots.R")
Create hotspot map

The map will be written to:

figs/scs_hotspots_map.png

```text
R/
  ├─ 01_manifest_and_download.R   # optional helper for automated downloads
  ├─ 02_build_working_set.R       # combines & filters Storm Events details
  └─ 03_visualize_hotspots.R      # produces the hotspot map

data/
  ├─ raw/                         # manually downloaded StormEvents_details-*.csv.gz (gitignored)
  └─ processed/                   # processed outputs, e.g. scs_combined_2015_2024.csv (gitignored)

figs/
  └─ scs_hotspots_map.png         # final map output
```

.gitignore
cat-snapshot-r.Rproj
README.md
.gitignore
cat-snapshot-r.Rproj
README.md
Caveats
Only three event types are included: Tornado, Hail, and Thunderstorm Wind.

## The hotspot map is based on reported events, which can be influenced by:

  Population density

  Observation practices

  Reporting changes over time

  Only details files are used; location and fatality tables are not yet incorporated.

  Coordinates are used as given in the Storm Events details files and may contain location uncertainty.


