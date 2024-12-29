# LIBRARIES
library(EIAapi)
library(dplyr)
library(lubridate)
library(plotly)


# PULLING METADATA FROM API
# Setting the api key and the api path to pull data:
api_key <- Sys.getenv("EIA_API_KEY")
api_meta_path <- "electricity/rto/region-sub-ba-data"

# Sending GET request for route metadata (data descriptions):
eia_metadata(api_key = api_key,
             api_path = api_meta_path)


# SENDING A SIMPLE GET REQUEST
# Setting a GET request
api_path <- "electricity/rto/region-sub-ba-data/data"
frequency <- "hourly"
facets <- list(
  parent = "CISO",
  subba = "PGAE"
)

df1 <- eia_get(
  api_key = api_key,
  api_path = api_path,
  frequency = frequency,
  facets = facets
)

str(df1)

df1 <- df1 |>
  mutate(index = ymd_h(period, tz = "UTC")) |>
  select(index, everything()) |>
  arrange(index)

head(df1)

## API LIMITATION
# Let's plot the series:
plot_ly(data = df1, x = ~index, y = ~ value,
        type = "scatter", mode = "lines")


start = "2024-01-01T01"
end = "2024-02-24T01"

df2 <- eia_get(
  api_key = api_key,
  api_path = api_path,
  frequency = frequency,
  facets = facets,
  start = start,
  end = end
)

df2 <- df2 |>
  mutate(index = ymd_h(period, tz = "UTC")) |>
  select(index, everything()) |>
  arrange(index)

head(df2)

plot_ly(data = df2, x = ~index, y = ~ value,
        type = "scatter", mode = "lines")


## HANDLING LARGE DATA REQUEST
# When we have to pull a series with a number of observations that exceed the API limitation of 5000 observations per call,
# use the `eia_backfill` function. The function splits the request into multiple small requests, where the `offset` argument
# defines the size of each request. It is recommended not to use an offset larger than 2500 observations. For example, let's 
# pull data since July 1st, 2018:

start = as.POSIXct("2018-07-01 08:00:00", tz = "UTC")
end = as.POSIXct("2024-10-24 00:00:00", tz = "UTC")
offset <- 2000

df3 <- eia_backfill(
  start = start,
  end = end,
  offset = offset,
  api_key = api_key,
  api_path = api_path,
  facets = facets
)
