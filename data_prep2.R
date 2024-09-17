# Change directory and clear environment
setwd("C:\\Users\\denni\\Desktop\\MXB362")
rm(list = ls())

# Libraries
library(dplyr)  # Only `dplyr` is used, so remove the others

# Read CSV file
covid_cases_cleaned <- read.csv("covid_cases_cleaned.csv")

# Convert datetime to POSIXct
covid_cases_cleaned$Datetime <- as.POSIXct(covid_cases_cleaned$Datetime, format = "%Y-%m-%d %H:%M:%S")

# Extract just the date part
covid_cases_cleaned$Date <- as.Date(covid_cases_cleaned$Datetime)

# Convert 'Date' and 'Name' to characters to avoid factor issues
covid_cases_cleaned$Date <- as.character(covid_cases_cleaned$Date)
covid_cases_cleaned$Name <- as.character(covid_cases_cleaned$Name)

# Aggregate data by date and name
aggregated_data <- covid_cases_cleaned %>%
  group_by(Date, Name) %>%
  summarize(Count = n(), .groups = 'drop')  # Named the column 'Count'

# Create a DataFrame with all combinations of dates and names
all_dates <- unique(aggregated_data$Date)
all_names <- unique(aggregated_data$Name)
date_name_matrix <- expand.grid(Date = all_dates, Name = all_names, stringsAsFactors = FALSE)

# Merge this matrix with the original aggregated_data DataFrame
cumulative_cases <- merge(date_name_matrix, aggregated_data, by = c('Date', 'Name'), all.x = TRUE)

# Replace NA values with 0 in the 'Count' column
cumulative_cases$Count[is.na(cumulative_cases$Count)] <- 0

# Calculate the cumulative sum of cases for each 'Name'
cumulative_cases <- cumulative_cases %>%
  arrange(Date, Name) %>%  # Ensure data is ordered by Date and then Name
  group_by(Name) %>%
  mutate(Cumulative = cumsum(Count))  # Changed 'total_cases' to 'Count'

# Export the cumulative cases DataFrame to a CSV file
write.csv(cumulative_cases, "cumulative_cases.csv", row.names = FALSE)

# Verify that the file was created
file.exists("cumulative_cases.csv")
