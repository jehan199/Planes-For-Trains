# Data Provenance

This document describes the sources and transformations used in the original
2022 version of the project and identifies changes made during the
reproducibility revision.

## 1. Overview

The original analysis used 2019 U.S. Department of Transportation Bureau of
Transportation Statistics (BTS) Origin and Destination Survey (DB1B) Coupon
data.

The analysis identified U.S. city markets with substantial passenger volumes
on flights between 75 and 500 miles, with the intention of identifying
short-haul air travel markets that could potentially be served by high-speed
rail.

The original workflow was:

BTS DB1B 2019 Q1-Q4  
→ combine quarterly data  
→ identify the 20 highest-volume eligible origin markets  
→ add geographic and metro-area information  
→ aggregate passenger volume by origin-destination market pair  
→ identify the highest-volume destination routes for each selected origin  
→ prepare route-level data for subsequent analysis and visualization.

---

## 2. Primary Source Data

### BTS DB1B Coupon 2019

Source: U.S. Department of Transportation, Bureau of Transportation
Statistics (BTS), Origin and Destination Survey (DB1B) Coupon.

The original project used the four quarterly 2019 files:

- 2019 Q1
- 2019 Q2
- 2019 Q3
- 2019 Q4

The original files were loaded into Google BigQuery as:

- `2019_Q1`
- `2019_Q2`
- `2019_Q3`
- `2019_Q4`

The original source ZIP files are preserved in the GitHub release:

`v1.0-data-2019`

The raw source files are not modified.

---

## 3. Combining the Quarterly Data

The four quarterly tables were combined using `UNION ALL`.

The resulting table was:

`us_air_passenger.unioned_and_filtered_table3`

The query also joined the historical `Airport_Codes` lookup table twice
to add airport names for the origin and destination airports.

The relevant fields retained included:

- Origin
- Destination
- OriginState
- DestinationState
- OriginCityMarketID
- DestCityMarketID
- Passengers
- Distance
- origin_name
- destination_name

The SQL used to create this table is preserved in the repository.

---

## 4. Market Selection

The original project selected markets using the following criteria:

1. Flight distance between 75 and 500 miles.
2. Flights originating in Hawaii were excluded.
3. Passenger totals were summed by `OriginCityMarketID`.
4. Markets were ranked by total passengers.
5. The 20 highest-volume eligible markets were selected.

The relevant SQL can be found in the SQL queries folder.

[insert link to SQL file]

This produced the 20 markets used in the subsequent analysis.

The resulting 20 `OriginCityMarketID` values were used to identify the
origin markets for the route-level analysis.

---

## 5. Metro_Data_Table and Metro_Area_Data

`Metro_Data_Table` was created as a geographic enrichment table for the
20 selected markets.

It contained:

- `OriginCityMarketID`
- `Sum_of_Passengers`
- `Metro_Area_Name`
- `Main_City__Name`
- `State`
- `Full_Name`
- `Latitude`
- `Longitude`

### BTS-derived fields

`OriginCityMarketID` and `Sum_of_Passengers` were derived from the DB1B
data through the market-selection procedure described above.

### Geographic fields

The city, state, latitude, and longitude information was derived from the
SimpleMaps U.S. Cities Basic v1.75 dataset used in the original 2022 project.

The latitude and longitude values in `Metro_Data_Table` were compared with
the v1.75 dataset and matched exactly for all 20 selected markets.

### Derived fields

`Full_Name` was created in Excel by combining the city and state fields.

`Metro_Area_Name` was a manually created classification used by the
original analysis to group individual cities into the metropolitan markets
used in the project.

### Metro_Area_Data

`Metro_Area_Data` was created in Excel from `Metro_Data_Table`.

The underlying market and geographic information was unchanged. The
`Metro_Area_Name` field was represented as two fields:

- `Metro_Area_Name_Origin_`
- `Metro_Area_Name_Dest_`

Both fields contain the same metro-area classification for a given
CityMarketID.

This restructuring allowed the market lookup information to be used
explicitly for both the origin and destination of an origin-destination
market pair.

---

## 6. Route-Level Passenger Aggregation

After identifying the 20 highest-volume origin markets, the original
analysis aggregated passenger volume by origin-destination market pair.

The relevant query aggregated:

- `OriginCityMarketID`
- `DestCityMarketID`
- `Sum_of_Passengers`

The route-level data was then joined to `Metro_Area_Data` to add geographic
and metro-area information for both the origin and destination.

The resulting route-level dataset included:

- OriginCityMarketID
- DestCityMarketID
- Sum_of_Passengers
- Metro_Area_Name_Origin_
- Metro_Area_Name_Dest_
- OriginLat
- OriginLon
- DestLat
- DestLon
- Distance

The route-level data was intended to support the project's subsequent
visualizations and analysis in R.

The SQL used for this step is preserved in the repository.

---

## 7. Cities_as_rail_hubs.csv

`Cities_as_rail_hubs.csv` is a derived route-level dataset used to identify
the highest-volume short-haul air routes associated with the 20 selected
origin markets.

### Initial query output

The underlying BigQuery query produced an output containing 871
origin-destination market pairs.

The query aggregated passenger volume by:

- `OriginCityMarketID`
- `DestCityMarketID`

and associated each route with geographic and metro-area information.

The query output was exported before the final route-selection filters were
applied.

### Passenger-volume filter

The exported query output was subsequently filtered to retain only
origin-destination pairs with more than 15,000 passengers.

This reduced the dataset from 871 records to 203 records.

### Top-destination selection

The 203 qualifying routes were then ranked by passenger volume within each
origin market.

For each of the 20 selected origin markets, up to the 10 highest-volume
destination routes were retained.

Origins with fewer than 10 qualifying destinations retained all of their
qualifying destinations.

This reduced the dataset from 203 records to 144 records.

The resulting 144 origin-destination pairs comprise
`Cities_as_rail_hubs.csv`.

The selection therefore represents:

> The 20 highest-volume short-haul origin markets, with up to their 10
> highest-volume destination markets among routes carrying more than 15,000
> passengers.

### Geographic information

Geographic information in `Cities_as_rail_hubs.csv` was derived from the
SimpleMaps U.S. Cities Basic v1.75 dataset used in the original 2022 project.

The following fields correspond to geographic information from the
SimpleMaps dataset:

- `OriginLat`
- `OriginLon`
- `DestLat`
- `DestLon`
- `State`
- `FullName`

The latitude and longitude values were compared against the recovered
SimpleMaps v1.75 `uscities.csv` dataset.

All 144 origin coordinate records and all 144 destination coordinate
records matched the corresponding SimpleMaps coordinates.

The `State` and `FullName` fields were also populated using the city and
state information associated with the SimpleMaps dataset.

### Metro-area information

`Metro_Area_Name_Origin_` and `Metro_Area_Name_Dest_` are custom metro-area
classifications used by the original analysis.

These fields were not simply copied from SimpleMaps. They group individual
cities into the metropolitan areas used in the project's analysis and
visualizations.

Examples include:

- `Atlanta`
- `LA/Inland Empire`
- `Bay Area`
- `Boston/Providence`
- `Minneapolis/St.Paul`
- `Washington D.C.`

During the original spreadsheet preparation, destination metro-area
information was subsequently populated for all destination records.

### Additional spreadsheet preparation

`Cities_as_rail_hubs.csv` contains several fields that were added or
prepared during the original spreadsheet workflow after the BigQuery
export.

These include geographic and descriptive fields used to support the
subsequent analysis, as well as the origin and destination ranking fields.

The resulting CSV is therefore a derived analytical dataset rather than a
raw BTS source file.

---

## 8. Geographic Data Source: SimpleMaps U.S. Cities

The original project used the SimpleMaps U.S. Cities Basic v1.75 dataset
for city-level geographic information.

The v1.75 dataset was obtained in 2022 and the original `uscities.csv`
file was subsequently recovered from the original project files.

The recovered dataset contains 30,409 city records.

The geographic values used in both `Metro_Data_Table` and
`Cities_as_rail_hubs.csv` were compared against this recovered v1.75
dataset.

The coordinates used in the project matched the recovered dataset exactly
for:

- all 20 selected origin markets in `Metro_Data_Table`; and
- all 144 origin and 144 destination records in
  `Cities_as_rail_hubs.csv`.

The original SimpleMaps dataset is preserved locally as historical
provenance. It is not redistributed in the GitHub repository.

---

## 9. Airport Code Lookup

The original BigQuery workflow used an `Airport_Codes` lookup table to add
airport names to the DB1B records.

This lookup is part of the historical 2022 workflow but is being reviewed
as part of the reproducibility revision because the original airport-code
source contains outdated or questionable entries.

The original lookup will be preserved as historical provenance but may be
replaced with a more authoritative airport reference dataset in the revised
pipeline.

---

## 10. Historical vs. Reproducibility Workflow

This project distinguishes between the original 2022 analysis and the
2026 reproducibility revision.

The purpose of the revision is not to replace the original analysis with a
different project. Instead, it documents the original methodology and
preserves the historical inputs while improving the reproducibility and
documentation of selected components.

Where a source is replaced, the original source and the reason for the
replacement will be documented.

| Source / Object | Type | Role | Status |
|---|---|---|---|
| BTS DB1B Coupon 2019 Q1–Q4 | Official source data | Primary flight data | Historical source |
| `2019_Q1`–`2019_Q4` | BigQuery tables | Raw imported data | Reproducible |
| `unioned_and_filtered_table3` | BigQuery table | Combined DB1B data | Reproducible |
| `Airport_Codes` | Lookup table | Airport names | To be reviewed |
| SimpleMaps U.S. Cities v1.75 | Geographic dataset | City/geographic attributes | Historical source |
| `Metro_Data_Table` | Derived table | Selected-market enrichment | Reproducible |
| `Metro_Area_Data` | Derived Excel table | Origin/destination metro lookup | Original derived data |
| `Cities_as_rail_hubs.csv` | Derived route-level dataset | Highest-volume short-haul routes | Historical analytical output |
| `Metro_Area_Name` | Manual classification | Metro grouping | Original analytical decision |
