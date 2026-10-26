# Data Provenance

## Overview

This project was originally developed in 2022 to investigate U.S. short-haul air travel markets that could potentially be served by high-speed rail.

The original analysis used 2019 U.S. Department of Transportation Bureau of Transportation Statistics (BTS) Origin and Destination Survey DB1B Coupon data. The analysis identified U.S. city markets with substantial passenger volumes on domestic flights between approximately 75 and 500 miles and then examined the destinations served by the highest-volume markets.

The original project was developed using BigQuery, Excel, R, and interactive HTML visualizations.

This document describes the provenance of the original 2022 analysis, including the source datasets, transformations, intermediate tables, manually created fields, and visualization workflow. The purpose is to make the original analysis as reproducible as possible while preserving the original methodology and outputs.

A separate 2026 revision of the project may subsequently update selected data sources or methodology. 

---

# 1. Primary Source Data

## BTS DB1B Coupon Data and Lookup Table

The primary analytical dataset was the U.S. Department of Transportation Bureau of Transportation Statistics (BTS) Origin and Destination Survey DB1B Coupon dataset. A secondary Lookup Table Dataset was also sourced from BTS to provide a Metro Area Name to each OriginCityMarketID and DestCityMarketID. 

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

The BTS Lookup Table can be downloaded here:

<https://transtats.bts.gov/Download_Lookup.asp?Y11x72=Y_PVgl_ZNeXRg_VQ>

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

The original workflow then combined the four quarterly tables using `UNION ALL` and left joined to the BTS Lookup table on fields `OriginCityMarketID` and `DestCityMarketID` in columns labelled as `Origin_City_Market` and `Dest_City_Market`.

The resulting table was named:

`BTS_Destination_Survey_DB1B_Coupon_unioned`

The query performs the following steps:

- Uses a union operator to append the four quarterly files together
- Left joins to the BTS lookup table to provide a City_Market name for both the Origin and Destination using `OriginCityMarketID` and `DestCityMarketID`
- Selects specific relevant fields from the 2019 BTS DB1BCoupon Source Data

The resulting dataset contains, among other fields:

- Origin City Market (Name of the Market)
- Destination City Market (Name of the Market)
- origin city market ID
- destination city market ID
- passengers
- distance
- origin state
- destination state

The original SQL used to create this table is saved in the following location within the repository : 
source_data/SQL/2026/01_union_quarterly_data_sql.md

It was discovered that in the 2022 version of this query that a join to an Airport Codes table resulted in duplicate records and inflated passenger totals when the records were summed by a pivot. 

The record count in the 2022 unioned BTS table was 44,156,578 and the sum of passenger count across all records totaled to 76,960,036. This issue was corrected in the 2026 query and subsequent data table. As a result of this correction, the new table contained 43,259,853 records and a total passenger count of 75,658,628.

---

# 3. Identification of the 50 Highest-Volume Origin Markets for Short-Haul Flights to Establish a Translation Table to Link `Origin_City_Market` to Geographic Data for Visualization

The next stage identified the U.S. city markets with the largest number of passengers on eligible short-haul flights.

The query that was used for this step is saved in the following location:

source_data/SQL/2026/02_top_50_markets.md

The query applied the following conditions:

```sql
WHERE Distance BETWEEN 75 AND 500
  AND OriginState != 'HI'
```

Passenger totals were then grouped by `Origin_City_Market` and ordered from highest to lowest.

The analysis retained the top 50 markets.

### Why Filter Flights to Between 75 and 500 Miles?

While there is some debate on what exactly constitutes the "sweet spot" for high speed rail distance, the general idea is that there exists a distance range where the door to door travel time from one city to another is lowest when high speed rail is used as the method of transit. 

When a trip is below 100 miles, it is generally quicker to drive considering that you wouldn't have to go to a central train station to catch a train to go from one city to another. When the a trip exceeds 500 miles, it is generally quicker to fly when you consider the faster transportation speed. When a trip is between these two distances, high speed rail is generally considered to be more time competitive.  

<img width="768" height="462" alt="image" src="https://github.com/user-attachments/assets/c0cbce78-5dfc-4940-839b-a0a31e81d376" />

Source: Adapted from Commission for Integrated Transport, London (2004) High-speed rails: international comparisons, Steer Davies Gleave.
https://transportgeography.org/contents/applications/high-speed-rail-systems/breakeven-distances-rail-air-transport/


### Why exclude Hawaii?

Hawaii was excluded because the project's research question concerns potential substitution of short-haul flights with rail. Hawaii cannot be connected to the continental U.S. passenger rail network.

The Hawaii exclusion is therefore a methodological choice specific to this project rather than a property of the underlying BTS data.
---

# 4. Geographic Data for the 50 Origin Markets

## SimpleMaps U.S. Cities Basic v1.75

Geographic information for the 50 selected markets was derived from the **SimpleMaps U.S. Cities Basic v1.75** dataset.

The version used by the original project was released by SimpleMaps in 2022 and was obtained by the project author in September 2022.

The historical copy of the dataset contains **30,409 records**.

The original project used the city-level latitude and longitude values from this dataset.

Because SimpleMaps licensing restricts redistribution of the underlying database, the complete SimpleMaps dataset is **not redistributed in this repository**. Instead, this project documents the specific historical version used and preserves the derived values necessary to understand the original analysis.

The SimpleMaps dataset should therefore be treated as a historical source dependency rather than as a file that can necessarily be regenerated from the repository alone.

---

# 5. `BTS_Simple_Maps_Metro_Area_Translation_Table`

The 50 selected city markets were combined with geographic information to create the BigQuery table:

`BTS_Simple_Maps_Metro_Area_Translation_Table`

The table contains:

- `OriginCityMarketID`
- `Origin_City_Market`
- `DestCityMarketID`
- `Dest_City_Market`
- `_Sum_of_Passengers_`
- `Simple_Maps_City_Name`
- `Simple_Maps_City_State`
- `Simple_Maps_City_and_State`
- `Simple_Maps_lat`
- `Simple_Maps_lng`
- `Top_20`

The BTS-derived fields are:

- `OriginCityMarketID`
- `Origin_City_Market`
- `DestCityMarketID`
- `Dest_City_Market`
- `_Sum_of_Passengers_`

In this table `OriginCityMarketID` and `DestCityMarketID` are the same for all records. Conisquentally `Origin_City_Market` and `Dest_City_Market` are also the same.  The purpose was to make it possible to join the selected markets to both the origin and destination sides of the later origin-destination analysis.

The SimpleMaps v1.75 fields are:

- `Simple_Maps_City_Name`
- `Simple_Maps_City_State`
- `Simple_Maps_City_and_State` *This field is a concatenate of `Simple_Maps_City_Name` and `Simple_Maps_City_State`*
- `Simple_Maps_lat`
- `Simple_Maps_lng`

The connection between these two data sets was established by manually connecting the `Origin_City_Market` field with a representative city in the SimpleMaps dataset. Representative cities in the SimpleMaps dataset where chosen on the basis of which city is the most populous within a given metro area. For example, if `Origin_City_Market` for a given record reads "Minneapolis/St. Paul, MN", the representative city that is chosen to represent that metro area will be "Minneapolis, MN". This allows us to bring in geospatial data from the SimpleMaps dataset which then allows us to plot a point in our visualization that will represent the metro area. Note that this geospatial data is not directly involved in the analysis and is only used for visualization purposes.

User Derived Field(s):

- `Top_20`

This field was used to provide a filter criteria for subsequent queries. The 2022 iteration of this project had a similar derived file titled "Metro_Area_Table" and it contained 20 records that represented the geographic data for the top 20 metro areas where short haul flights originated. Although my final visualization for Cities with the Most Short Haul Flights only visualizes 20 City Markets, this project also generated visualization where the 5 biggest markets where give their own interactive map that shows where these flights ended up going. Creating a translation table with 50 metro areas meant that I could ensure that my destination metros for the 5 largest hubs all had geospatial information in the source data that was uploaded into R to create the visualizations, even if these cities weren't a top 20 origin metro. 

---

# 6. `Cities_with_most_short_flights_geo_data_2026.csv`

This file was generated by the query saved in the following location: source_data/SQL/2026/04_query_to_select_top_20_markets.md

This query performs the following functions:

- Sources data from the `BTS_Destination_Survey_DB1B_Coupon_unioned` table
- Filters out results with origins in Hawaii and filters records to only flights between 75 and 500 miles
- Groups records by `Origin_City_Market` and sums the number of passengers
- Joins on `Origin_City_Market` to the `BTS_Simple_Maps_Metro_Area_Translation_Table` to pull in geographic data
- Sorts output by `Sum_of_Passengers` and limits output to 20 records to create a top 20. 

The resulting CSV contains:

- `Origin_City_Market`
- `State`
- `Sum_of_Passengers`
- `Latitude`
- `Longitude`

This file is a direct export of the corresponding BigQuery query. It is later used as a source file for one of the visualizations in R.

# 7. `Cities_as_rail_hubs_2026.csv`

This file was generate by a query saved in the following location:

source_data/SQL/2026/03_query_to_pivot_filter_and_proivde_geographic_information.md

`Cities_as_rail_hubs_2026.csv` contains the final origin-destination data used for the 2022 visualizations.

Important fields include:

- `OriginCityMarketID`
- `Origin_City_Market`
- `DestCityMarketID`
- `Dest_City-Market`
- `Sum_of_Passengers`
- `Distance`
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
Filter out records with an origin or destination in state = 'HI'
        ↓
Filter for records with a flight distance between 75 and 500 miles
        ↓
Rank origins by passenger volume that clears the previous filters
        ↓
Rank destinations within each origin
        ↓
Keep top 5 origins
        ↓
Keep up to 5 destinations per origin
        ↓
25 records
        ↓
Cities_as_rail_hubs_2026.csv
```

---

## 8. R Visualization Workflow

The final visualization stage of the revised 2026 workflow was performed in R using R Markdown. The workflow generates six interactive maps: one national overview of the 20 city markets with the highest short-haul flight passenger volumes and five city-market-specific analyses of the highest-volume origin markets.

### Source Data

The visualization workflow uses two SQL-derived CSV files:

- `Cities_with_most_short_flights_geo_data_2026.csv` — source data for the national overview map.
- `Cities_as_rail_hubs_2026.csv` — source data for the five city-market-specific maps.

All six maps use the 2016 U.S. primary-roads shapefile, `tl_2016_us_primaryroads.shp`, from the U.S. Census Bureau's TIGER/Line program, as a geographic reference layer.

The R workflows use packages including `readr`, `dplyr`, `sf`, `mapview`, and `leaflet` for data loading, transformation, spatial processing, and interactive visualization.

### 8.1 National Overview Map: Cities with Most Short-Haul Flights

The national overview map uses `Cities_with_most_short_flights_geo_data_2026.csv`. The workflow converts passenger totals to numeric values, sorts city markets by descending passenger volume, and generates an `Origin_Rank` field in R. Rank 1 is assigned to the market with the highest passenger total.

City-market coordinates are converted into spatial point features using longitude and latitude in the WGS 84 coordinate reference system (EPSG:4326). Marker colors represent passenger volumes, and hover labels display each market's origin rank.

The map's interactive popups contain the following fields:

- `Feature ID`
- `Origin_City_Market`
- `State`
- `Sum_of_Passengers`
- `Latitude`
- `Longitude`
- `Origin_Rank`
- `geometry`

### 8.2 City-Market-Specific Analyses

The five city-market-specific maps use `Cities_as_rail_hubs_2026.csv` to examine destinations associated with the five highest-volume origin city markets.

Each map distinguishes the origin market from its destination markets. Hovering over the origin marker displays **Origin**, while hovering over a destination marker displays its **Destination Rank**.

The origin marker's interactive popup contains:

- `Feature ID`
- `Origin_City_Market`
- `OriginLat`
- `OriginLon`
- `Origin_Rank`
- `geometry`
- `Origin_Label`

Destination markers' interactive popups contain:

- `Feature ID`
- `Destination_City_Market`
- `Sum of Passengers`
- `Passenger_Band`
- `Rank_Label`
- `DestLat`
- `DestLon`
- `Distance`
- `geometry`

These attributes provide the destination market's passenger volume, passenger-volume band, rank label, geographic coordinates, and distance from the origin market.

## 8.3 Road Overlay and Basemap

### Esri Basemap Notes

- The Esri basemap requires an internet connection when viewing the HTML file.The interactive maps use the Esri World Gray Canvas basemap, accessed online through `mapview`.
- Esri's Web Site and Service Terms of Use permit certain noncommercial uses of Esri services, subject to applicable terms and restrictions.
- The maps retain the basemap attribution displayed by the service. This project does not redistribute a separate copy of the basemap tile data.
- Terms reviewed:
    - [Esri Web Site and Service Terms of Use](https://www.esri.com/en-us/legal/terms/web-site-service)
    - [Esri Master Agreement](https://www.esri.com/content/dam/esrisites/en-us/media/legal/ma-full/ma-full.pdf)
- This note documents the terms reviewed for the project; it is not a legal determination that every method of publication or redistribution is authorized.

### 2016 U.S. Primary Roads Notes

- The maps use the 2016 U.S. Primary Roads National Shapefile from the U.S. Census Bureau's TIGER/Line program. The dataset represents primary roads, generally limited-access highways, and is used as a visual reference layer rather than as a complete road network.

- The dataset is listed under the CC0 1.0 public-domain dedication. It has been cropped to the map area for visualization.

- Source: U.S. Census Bureau, 2016 TIGER/Line Primary Roads. https://catalog.data.gov/dataset/tiger-line-shapefile-2016-nation-u-s-primary-roads-national-shapefile



### Relationship to the Original 2022 Workflow

The revised 2026 visualization workflow updates the original 2022 implementation to use the revised city-market datasets and R Markdown scripts. The national overview now generates origin rankings in R from passenger totals. The five city-market-specific maps distinguish origin and destination markers through hover labels and provide destination-level information through interactive popups.

The original 2022 maps and associated workflow are retained as historical project materials and documented separately from the revised 2026 outputs.

# 9. 2026 Visualization Outputs

The original project produced six interactive HTML outputs:

1. Cities-with-Most-Short-Haul-Flights-2026.html
2. Atlanta-as-a-Rail-Hub-2026.html
3. Los-Angles-as-a-Rail-Hub-2026.html
4. Washington-DC-as-a-Rail-Hub-2026.html
5. San-Francisco-as-a-Rail-Hub-2026.html
6. Charlotte-as-a-Rail-Hub-2026.html

The HTML files preserve the coordinates, passenger values, rankings, map configuration, and visualization design used in the original project.

The hub maps represent selected high-volume origin city-markets and their short-haul flight destinations.

All visualizations were uploaded to Github via the 2026 Analysis Outputs release: https://github.com/jehan199/Planes-For-Trains/releases#release-v1.0-2026-outputs

---

# 10. Roads Data

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

The complete dataset was uploaded to Github via the 2016 US Primary Roads Data release: https://github.com/jehan199/Planes-For-Trains/releases#release-v.1.0-primary-roads-2016

---

# 11. Historical vs. Revised Analysis

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


The 2026 version made the following changes:

- removed the airport code reference data and any joins to the 2019 BTS DB1B data
- used a lookup table published by BTS to introduce a City-Market name for each City-Market-ID
- created a translation table to bridge the gap between BTS and SimpleMaps geographic data featuring the top 50 city markets by origin. This eliminated the need to manually input geographic data into the eventual Cities_as_rail_hubs_2026.csv document
- rewrote "query_to_pivot_filter_and_proivde_geographic_information" SQL query to eliminate the need for any manual data transformations before Cities_as_rail_hubs_2026.csv could be produced
- R `mapview` visualization for Cities-with-Most-Short-Haul-Flights-2026 was changed in the following ways:
-   Underlying basemap was changed from OpenStreetMaps to Esri Basemap due to issues with OpenStreetMaps functionality and licensing
-   Hover values for Origin City-Markets changed from Sum of Passengers to Origin Rank
-   Popup fields changed to the fields referenced in Data_Provenance_2026 section 8.1
-   Esri Basemap and US Primary Road Notes added to HTML output (see section 8.3 of Data_Provenance_2026 for more details)
- 

These changes should not overwrite the historical workflow.

Instead, the project should maintain separate documentation and code for the original 2022 analysis and the revised analysis.

---

# 15. Current Provenance Status

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

# 16. Reproducibility Philosophy

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
