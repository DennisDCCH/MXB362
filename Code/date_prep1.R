# Change directory and clear environment
setwd("C:\\Users\\denni\\Desktop\\MXB362")
rm(list = ls())

# Libraries
library(ggplot2)
library(sf)
library(gganimate)

# Read CSV file
covid_locations <- read.csv("SG-COVID-Locations - Locations.csv")

# Read GeoJSON file
geo_boundary <- st_read("MasterPlan2019PlanningAreaBoundaryNoSea.geojson")

# Check the data
head(covid_locations)
plot(geo_boundary)

########## Data Cleaning ########## 

# Step 1: Replace en-dashes (–) with hyphens (-)
covid_locations$Time <- gsub("–", "-", covid_locations$Time)

# Step 2: Ensure there is a space before and after the hyphen
# First, replace any occurrences of "h-" or "-h" without spaces with the correct format
covid_locations$Time <- gsub("([0-9]+h)-", "\\1 - ", covid_locations$Time)  # Add space after "h" and before "-"
covid_locations$Time <- gsub("-([0-9]+h)", " - \\1", covid_locations$Time)  # Add space after "-" and before "h"

# Step 3: Remove additional time component in 'Date' column
covid_locations$Date <- gsub(" .*", "", covid_locations$Date)

covid_locations$Area <- gsub("Changi Airport", "Changi", covid_locations$Area)

########## Preparing Data ########## 

# Extract the 'PLN_AREA_N' values
pln_area_n_values <- gsub(".*<th>PLN_AREA_N</th> <td>([^<]+)</td>.*", "\\1", geo_boundary$Description)

# Combine the extracted 'PLN_AREA_N' values with the 'Name' column from geo_boundary into a new dataframe
new_df <- data.frame(Name = geo_boundary$Name, PLN_AREA_N = pln_area_n_values)

# View the new dataframe
head(new_df)

# Ensure 'Area' in covid_locations and 'PLN_AREA_N' in new_df are character vectors for the merge
covid_locations_subset <- covid_locations[, c("Area", "Longitude", "Latitude", "Date", "Time")]
covid_locations_subset$Area <- toupper(covid_locations_subset$Area)
covid_locations_subset$Area <- as.character(covid_locations_subset$Area)
new_df$PLN_AREA_N <- as.character(new_df$PLN_AREA_N)

# Perform the merge
covid_cases <- merge(covid_locations_subset, new_df, by.x = "Area", by.y = "PLN_AREA_N", all.x = TRUE)

# Get Starting Time
covid_cases$StartTime <- gsub("^(\\d{2})(\\d{2})h.*", "\\1:\\2:00", covid_cases$Time)

# Combine Date and StartTime into a single datetime column
covid_cases$Datetime <- as.POSIXct(paste(covid_cases$Date, covid_cases$StartTime),
                                   format = "%m/%d/%Y %H:%M:%S")  # Adjust format if needed

# Drop Date, Time, and StartTime columns
covid_cases_cleaned <- covid_cases[, !(names(covid_cases) %in% c("Date", "Time", "StartTime"))]

# Verify the changes
head(covid_cases_cleaned)

# Export the cleaned dataframe to a CSV file
write.csv(covid_cases_cleaned, "covid_cases_cleaned.csv", row.names = FALSE)

# Verify that the file was created
file.exists("covid_cases_cleaned.csv")


