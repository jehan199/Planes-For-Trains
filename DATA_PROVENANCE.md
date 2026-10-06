# Data Provenance

## Overview

This project was originally developed in 2022 to investigate U.S. short-haul air travel markets that could potentially be served by high-speed rail.

The original analysis used 2019 U.S. Department of Transportation Bureau of Transportation Statistics (BTS) Origin and Destination Survey DB1B Coupon data. The analysis identified U.S. city markets with substantial passenger volumes on domestic flights between approximately 75 and 500 miles and then examined the destinations served by the highest-volume markets.

The original project was developed using BigQuery, Excel, R, and interactive HTML visualizations.

This document describes the provenance of the original 2022 analysis, including the source datasets, transformations, intermediate tables, manually created fields, and visualization workflow. The purpose is to make the original analysis as reproducible as possible while preserving the original methodology and outputs.

A separate 2026 revision of the project may subsequently update selected data sources or methodology. 

---

# 1. Primary Source Data

## 1.1 BTS DB1B Coupon Data

The primary analytical dataset was the U.S. Department of Transportation Bureau of Transportation Statistics (BTS) Origin and Destination Survey DB1B Coupon dataset.

The analysis used the four quarterly DB1B Coupon files from **2019**:

- 2019 Q1
- 2019 Q2
- 2019 Q3
- 2019 Q4

The original files were downloaded from the BTS TranStats system and subsequently loaded into Google BigQuery.

The original BTS source files have been preserved unchanged as part of the project's historical data archive.

### Original source

BTS TranStats DB1B Coupon data:

<https://www.transtats.bts.gov/PREZIP/>

The DB1B Coupon field-selection page used during the project was:

<https://www.transtats.bts.gov/DL_SelectFields.aspx?gnoyr_VQ=FLM&QO_fu146_anzr=b4vtv0%20n0q%20Qr56v0n6v10%20f748rB>

### Archived source files

The four original 2019 quarterly ZIP files are preserved in the project's GitHub release:

**Release:** `v1.0-data-2019`  
**Title:** `2019 BTS DB1BCoupon Source Data`

The files are retained in their original form rather than being modified during the reproducibility work.

---

# 2. Loading and Combining the Quarterly BTS Data

Each quarterly DB1B Coupon file was loaded into BigQuery as a separate table:

- `2019_Q1`
- `2019_Q2`
- `2019_Q3`
- `2019_Q4`

The original workflow then combined the four quarterly tables using `UNION ALL`.

The resulting table was named:

`unioned_and_filtered_table3`

Despite the table name, the original query that created this table **does not itself perform the later 75–500 mile distance filter or the Hawaii exclusion**.

Instead, the query:

1. unions the four quarterly datasets;
2. retains selected DB1B fields;
3. joins airport-code information to the origin and destination airport codes; and
4. creates a combined working table for subsequent analysis.

The resulting dataset contains, among other fields:

- origin airport
- destination airport
- origin state
- destination state
- origin city market ID
- destination city market ID
- passengers
- distance
- airport names

The original SQL used to create this table has been recovered and should be preserved in the project's SQL archive.

---

# 3. Identification of the 20 Highest-Volume Origin Markets

The next stage identified the U.S. city markets with the largest number of passengers on eligible short-haul flights.

The original query applied the following conditions:

```sql
WHERE Distance BETWEEN 75 AND 500
  AND OriginState != 'HI'
```

Passenger totals were then grouped by `OriginCityMarketID` and ordered from highest to lowest.

The analysis retained the top 20 markets.

### Why exclude Hawaii?

Hawaii was excluded because the project's research question concerns potential substitution of short-haul flights with rail. Hawaii cannot be connected to the continental U.S. passenger rail network.

The Hawaii exclusion is therefore a methodological choice specific to this project rather than a property of the underlying BTS data.

### Top-20 selection

The resulting 20 `OriginCityMarketID` values were:

| Rank | OriginCityMarketID | Passengers |
|---:|---:|---:|
| 1 | 30397 | 1,550,916 |
| 2 | 32575 | 1,307,190 |
| 3 | 30852 | 1,248,484 |
| 4 | 32457 | 1,072,246 |
| 5 | 31057 | 1,008,128 |
| 6 | 30977 | 970,452 |
| 7 | 30194 | 855,011 |
| 8 | 32211 | 736,505 |
| 9 | 31703 | 681,855 |
| 10 | 31295 | 550,230 |
| 11 | 30721 | 535,399 |
| 12 | 30466 | 490,399 |
| 13 | 31453 | 484,598 |
| 14 | 33570 | 431,918 |
| 15 | 34100 | 371,566 |
| 16 | 31650 | 356,497 |
| 17 | 33192 | 303,467 |
| 18 | 30693 | 294,947 |
| 19 | 30325 | 293,731 |
| 20 | 34492 | 283,171 |

These totals represent passengers associated with each origin city market after applying the original 75–500 mile and non-Hawaii criteria.

---

# 4. Geographic Data for the 20 Origin Markets

## 4.1 SimpleMaps U.S. Cities Basic v1.75

Geographic information for the 20 selected markets was derived from the **SimpleMaps U.S. Cities Basic v1.75** dataset.

The version used by the original project was released by SimpleMaps in 2022 and was obtained by the project author in September 2022.

The historical copy of the dataset contains **30,409 records**.

The original project used the city-level latitude and longitude values from this dataset.

The geographic coordinates in the resulting `Metro_Data_Table` have been checked against the preserved v1.75 dataset and match the original values for all 20 selected markets.

Because SimpleMaps licensing restricts redistribution of the underlying database, the complete SimpleMaps dataset is **not redistributed in this repository**. Instead, this project documents the specific historical version used and preserves the derived values necessary to understand the original analysis.

The SimpleMaps dataset should therefore be treated as a historical source dependency rather than as a file that can necessarily be regenerated from the repository alone.

---

# 5. `Metro_Data_Table`

The 20 selected city markets were combined with geographic information to create the BigQuery table:

`Metro_Data_Table`

The table contains:

- `OriginCityMarketID`
- `_Sum_of_Passengers_`
- `Metro_Area_Name`
- `Main_City__Name`
- `State`
- `Full_Name`
- `Latitude`
- `Longitude`

The BTS-derived fields are:

- `OriginCityMarketID`
- `_Sum_of_Passengers_`

The geographic fields were derived from SimpleMaps v1.75.

The `Metro_Area_Name` field was **manually defined for the purposes of this project**. It does not represent a directly sourced SimpleMaps field.

Examples include:

- `LA/Inland Empire`
- `Bay Area`
- `Boston/Providence`
- `Washington D.C.`
- `Minneapolis/St.Paul`

The `Full_Name` field was constructed from the city/state information.

This distinction is important because the metro-area terminology used throughout the visualizations represents the project's analytical grouping rather than an independently sourced metropolitan-area classification.

---

# 6. `Cities_with_most_short_flights_geo_data.csv`

The BigQuery top-20 market results were joined to `Metro_Data_Table` to produce the geographic dataset used by the visualization workflow.

The resulting CSV contains:

- `Metro_Area_Name`
- `State`
- `Sum_of_Passengers`
- `Latitude`
- `Longitude`

This file is a direct export of the corresponding BigQuery query.

It is therefore a **derived analytical output**, not an independent source dataset.

Its provenance is:

```text
BTS DB1B Coupon 2019
        ↓
unioned_and_filtered_table3
        ↓
75–500 mile filter + Hawaii exclusion
        ↓
top 20 OriginCityMarketID values
        ↓
join to Metro_Data_Table
        ↓
Cities_with_most_short_flights_geo_data.csv
```

---

# 7. `Metro_Area_Data`

A second intermediate dataset, `Metro_Area_Data`, was created from `Metro_Data_Table`.

This table contains the same underlying market and geographic information but restructures the metro-area name into separate origin and destination fields:

- `Metro_Area_Name_Origin_`
- `Metro_Area_Name_Dest_`

The table also retains:

- `OriginCityMarketID`
- `DestCityMarketID`
- `_Sum_of_Passengers_`
- `Main_City__Name`
- `State`
- `Full_Name`
- `Latitude`
- `Longitude`

For this table, the origin and destination city market IDs are the same for each row.

This was an **Excel-based restructuring of `Metro_Data_Table`**, rather than a new external data source.

The purpose was to make it possible to join the selected markets to both the origin and destination sides of the later origin-destination analysis.

---

# 8. Origin-Destination Analysis

After identifying the 20 highest-volume origin markets, the project examined where passengers from those markets were traveling.

The initial origin-destination aggregation produced **871 origin-destination records**.

Passenger volumes were aggregated by:

```text
OriginCityMarketID × DestCityMarketID
```

The analysis then applied a passenger-volume threshold:

```text
Sum_of_Passengers > 15,000
```

This reduced the dataset from:

```text
871 records
      ↓
203 records
```

The destinations were then ranked within each origin market according to passenger volume.

The analysis retained up to the **10 highest-volume destinations for each origin market**.

This produced the final:

```text
144 origin-destination records
```

The resulting dataset was saved as:

`Cities_as_rail_hubs.csv`

Because some origin markets had fewer than ten destinations exceeding the 15,000-passenger threshold, the final dataset contains 144 rather than 200 records.

---

# 9. `Cities_as_rail_hubs.csv`

`Cities_as_rail_hubs.csv` contains the final origin-destination data used for the 2022 visualizations.

Important fields include:

- `OriginCityMarketID`
- `DestCityMarketID`
- `Sum_of_Passengers`
- `ID_Pair`
- `Distance`
- `Metro_Area_Name_Origin_`
- `Metro_Area_Name_Dest_`
- `State`
- `FullName`
- `OriginLat`
- `OriginLon`
- `DestLat`
- `DestLon`
- `Origin Rank`
- `Destination Rank`

The ranking fields have two different meanings:

### Origin Rank

The `Origin Rank` represents the overall ranking of the 20 selected origin markets according to their total short-haul passenger volume.

### Destination Rank

The `Destination Rank` represents the ranking of a destination within its origin market according to passenger volume.

The resulting provenance chain is:

```text
2019 BTS DB1B data
        ↓
871 origin-destination records
        ↓
Passenger threshold > 15,000
        ↓
203 records
        ↓
Rank destinations within each origin
        ↓
Keep up to 10 destinations per origin
        ↓
144 records
        ↓
Cities_as_rail_hubs.csv
```

---

# 10. R Visualization Workflow

The final visualization stage was performed in R.

The recovered `Mapview.R` script loads:

- `Cities_with_most_short_flights_geo_data.csv`
- `Cities_as_rail_hubs.csv`
- a 2016 U.S. primary roads shapefile
- R spatial and visualization packages including `sf`, `mapview`, `tmap`, `maps`, `tidyverse`, and `leafpop`.

The original R script loads the roads shapefile and the two SQL-derived CSV files as source data. It also establishes the ranking vector used for the 20 selected markets.

The script converts the city coordinates into spatial objects using longitude and latitude and associates the data with metro names, passenger totals, and destination rankings.

The top-20 candidate dataset is constructed from the geographic coordinates and assigned:

- market rank
- metro-area name
- total passengers flying from the market

The destination spatial dataset is constructed from destination coordinates and assigned:

- destination rank
- flight origin city
- destination city
- passengers received

---

# 11. Map Generation

The R workflow generated two types of visualizations.

## 11.1 National Top-20 Map

The first visualization displays the 20 selected origin markets and their total short-haul passenger volumes.

The rank and passenger totals were attached to the spatial points before visualization.

The resulting map allows the 20 candidate markets to be compared geographically according to their total short-haul passenger volume.

## 11.2 City-Specific Hub Maps

The second visualization examined the top 5 origin markets by total short-haul passenger volume individually.

The project generated maps for:

- Atlanta
- LA/Inland Empire
- Washington D.C.
- Bay Area
- Charlotte

For each selected origin market, the map displays the origin location together with the destinations associated with that market.

The original R workflow filtered the destination data by origin metro area before generating each hub visualization.

For example, the Atlanta workflow created an Atlanta origin object and an Atlanta destination object before displaying the destinations according to passenger volume and the Atlanta origin separately.

The same general workflow was used for:

- LA/Inland Empire
- Washington D.C.
- Bay Area
- Charlotte

The five city-specific maps were generated using the commands preserved in the project's original Markdown documentation.

---

# 12. Historical 2022 Visualization Outputs

The original project produced six interactive HTML outputs:

1. `Short-Haul-Flight-Cities.html`
2. `Atlanta-Visual.html`
3. `LA-Inland-Empire-as-a-Hub.html`
4. `Washington-D.C.-as-a-Hub.html`
5. `Bay-Area-as-a-Hub.html`
6. `Charlotte-as-a-Hub..html`

These files are preserved as historical 2022 outputs.

They should be considered **outputs of the original analysis**, rather than independently reproducible source data.

The HTML files preserve the coordinates, passenger values, rankings, map configuration, and visualization design used in the original project.

The hub maps represent selected high-volume origin metro areas and their short-haul flight destinations.

Some external basemap providers used by the original interactive maps have changed their access policies since 2022. Consequently, certain basemaps may no longer function exactly as they did when the HTML files were originally created.

This does not affect the underlying analytical data embedded in the historical outputs.

---

# 13. Roads Data

The R visualization workflow also loaded a 2016 U.S. primary roads shapefile:

```text
tl_2016_us_primaryroads.shp
```

The original R script loaded this file from a local project directory and transformed it into a Lambert Conformal Conic projection for visualization.

The roads layer was used as **visual context only**.

It was not used to:

- calculate passenger volumes;
- select markets;
- calculate flight distances;
- determine potential rail routes; or
- otherwise affect the analytical results.

The exact original source/download provenance for this roads dataset has not yet been independently reconstructed.

This is therefore classified as a **minor remaining provenance item**, rather than a dependency of the analytical results.

---

# 14. Airport Code Data

The original workflow also used an airport-code table to associate three-letter airport codes with airport names.

The historical airport-code file was reconstructed from an older airport-code reference used by the 2022 project.

Because that reference contains outdated airport codes and is not considered an appropriate authoritative source for a modern reproduction, it is being treated as a **legacy 2022 dependency**.

The original airport-code information will be preserved for historical reproducibility, but the 2026 revision should consider replacing it with an authoritative BTS/FAA airport reference dataset.

This change should be documented as a deliberate methodological revision rather than silently replacing the original source.

---

# 15. Historical vs. Revised Analysis

An important goal of the reproducibility work is to distinguish the original 2022 analysis from any subsequent revisions.

The historical analysis preserves:

- 2019 BTS DB1B data
- the original SQL logic
- the original 20-market selection
- SimpleMaps v1.75 geographic data
- the original manually defined metro-area names
- the original Excel transformations
- the original R workflow
- the original interactive HTML outputs

Any future revisions should be documented separately.

For example, a revised analysis may update:

- airport reference data
- geographic data
- distance thresholds
- route-selection methodology
- data-processing code
- visualization methods

These changes should not overwrite the historical workflow.

Instead, the project should maintain separate documentation and code for the original 2022 analysis and the revised analysis.

---

# 16. Current Provenance Status

As of the current reproducibility review, the major stages of the original project have been reconstructed.

## Fully established

- 2019 BTS DB1B Coupon source data
- Quarterly Q1–Q4 data
- BigQuery union of quarterly files
- 75–500 mile selection for the top-20 market analysis
- Hawaii exclusion
- Selection of the 20 highest-volume origin markets
- SimpleMaps v1.75 geographic source
- `Metro_Data_Table`
- `Cities_with_most_short_flights_geo_data.csv`
- `Metro_Area_Data`
- 871 → 203 → 144 origin-destination reduction
- `Cities_as_rail_hubs.csv`
- R spatial-data preparation
- R map-generation workflow
- Five city-specific hub maps
- National top-20 visualization
- Historical HTML outputs

## Established, but documentation can be improved

- Manual creation of `Metro_Area_Name`
- Excel restructuring used to create `Metro_Area_Data`
- Exact organization of some intermediate BigQuery tables
- Historical airport-code source and its relationship to the original workflow
- Exact source/download provenance for the 2016 primary-roads shapefile

## Remaining minor provenance item

The exact original download source for the 2016 primary-roads shapefile has not yet been reconstructed.

Because this dataset was used only as a visualization layer, this does not affect the provenance of the passenger-volume analysis or the selection of the candidate markets.

---

# 17. Reproducibility Philosophy

The purpose of this documentation is not to rewrite the original project as though it had been created using a modern reproducible workflow.

Instead, the goal is to preserve the original analytical history while making the sequence of sources, transformations, and outputs understandable and reproducible wherever possible.

The original project was developed in 2022 using a combination of:

- public government data
- BigQuery
- Excel
- manually defined analytical classifications
- R
- interactive HTML visualization

The current reconstruction documents those steps explicitly.

Future improvements will be treated as revisions to the analysis rather than retroactive corrections to the historical project.







