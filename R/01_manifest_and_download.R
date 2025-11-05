base_url <- "https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/"
years <- 2015:2024
dest_path <- "data/raw"

dir.create(dest_path, recursive = TRUE, showWarnings = FALSE)

for (yr in years) {
  file_name <- paste0("StormEvents_details-ftp_v1.0_", yr, ".csv.gz")
  file_url <- paste0(base_url, file_name)
  dest_file <- file.path(dest_path, file_name)
  
  message("Downloading ", file_url)
  tryCatch({
    download.file(file_url, destfile = dest_file, mode = "wb")
    message("✅ Saved to ", dest_file)
  }, error = function(e) {
    message("⚠️ Failed to download: ", file_name)
  })
}
