# =======================================================
# 02_build_working_set.R
# Purpose: Merge NOAA Storm Events (Details, Locations, Fatalities)
# into one clean dataset ready for analysis.
# =======================================================

library(dplyr)

# --- Paths ---
raw_path  <- "data/raw"
out_path  <- "data/processed"
dir.create(out_path, recursive = TRUE, showWarnings = FALSE)

# --- Identify files (all years in folder) ---
details_files    <- list.files(raw_path, pattern = "details.*\\.csv\\.gz$", full.names = TRUE)
locations_files  <- list.files(raw_path, pattern = "locations.*\\.csv\\.gz$", full.names = TRUE)
fatalities_files <- list.files(raw_path, pattern = "fatalities.*\\.csv\\.gz$", full.names = TRUE)

message("📂 Found ", length(details_files), " detail, ",
        length(locations_files), " location, and ",
        length(fatalities_files), " fatality files.")

# --- Helper: stack CSVs safely with base R (no bind_rows) ---
stack_csvs <- function(files, force_damage_crops = FALSE) {
  big <- NULL
  
  for (f in files) {
    message("📄 Reading ", basename(f))
    df <- tryCatch(
      read.csv(f, stringsAsFactors = FALSE),
      error = function(e) {
        message("⚠️ Skipping ", basename(f), " due to error: ", e$message)
        return(NULL)
      }
    )
    if (is.null(df)) next
    
    # Make DAMAGE_CROPS consistently character if requested
    if (force_damage_crops) {
      if (!"DAMAGE_CROPS" %in% names(df)) {
        df$DAMAGE_CROPS <- NA_character_
      } else {
        df$DAMAGE_CROPS <- as.character(df$DAMAGE_CROPS)
      }
    }
    
    # Align columns with existing 'big' before rbind
    if (is.null(big)) {
      big <- df
    } else {
      missing_in_big <- setdiff(names(df), names(big))
      for (m in missing_in_big) big[[m]] <- NA
      
      missing_in_df <- setdiff(names(big), names(df))
      for (m in missing_in_df) df[[m]] <- NA
      
      df <- df[, names(big)]
      big <- rbind(big, df)
    }
  }
  
  big
}

# --- Load data ---
message("📥 Loading Details...")
details <- stack_csvs(details_files, force_damage_crops = TRUE)

message("📥 Loading Locations...")
locations <- stack_csvs(locations_files, force_damage_crops = FALSE)

message("📥 Loading Fatalities...")
fatalities <- stack_csvs(fatalities_files, force_damage_crops = FALSE)

# --- Use YEAR column and limit to 2015–2024 ---
if ("YEAR" %in% names(details)) {
  details$YEAR <- suppressWarnings(as.integer(details$YEAR))
  details <- details %>% filter(YEAR >= 2015, YEAR <= 2024)
} else {
  stop("YEAR column not found in details data.")
}

# --- Coerce key numeric columns AFTER stacking ---
to_num <- function(x) suppressWarnings(as.numeric(x))

num_cols <- c("DAMAGE_PROPERTY","DEATHS_DIRECT","DEATHS_INDIRECT",
              "INJURIES_DIRECT","INJURIES_INDIRECT",
              "BEGIN_LAT","BEGIN_LON","END_LAT","END_LON")

for (c in num_cols) {
  if (c %in% names(details))    details[[c]]    <- to_num(details[[c]])
  if (c %in% names(locations))  locations[[c]]  <- to_num(locations[[c]])
  if (c %in% names(fatalities)) fatalities[[c]] <- to_num(fatalities[[c]])
}

# --- Merge by EVENT_ID ---
message("🔗 Merging datasets...")
storms_full <- details %>%
  left_join(locations,  by = "EVENT_ID", relationship = "many-to-many") %>%
  left_join(fatalities, by = "EVENT_ID", relationship = "many-to-many")

# --- Filter Severe Convective Storms ---
message("🌪️ Filtering Severe Convective Storms...")
scs <- storms_full %>%
  filter(EVENT_TYPE %in% c("Tornado", "Hail", "Thunderstorm Wind")) %>%
  select(YEAR, STATE, CZ_NAME, EVENT_TYPE,
         DAMAGE_PROPERTY, DEATHS_DIRECT, INJURIES_DIRECT,
         BEGIN_LAT, BEGIN_LON, END_LAT, END_LON)

# --- Save output ---
output_file <- file.path(out_path, "scs_combined_2015_2024.csv")
write.csv(scs, output_file, row.names = FALSE)

message("✅ Saved combined dataset to: ", output_file)
