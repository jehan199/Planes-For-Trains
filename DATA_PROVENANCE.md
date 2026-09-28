 Data Provenance

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
→ filter flights by distance and geography
→ aggregate passengers by OriginCityMarketID
→ identify the 20 highest-volume eligible markets
→ add geographic and metro-area information
→ conduct the subsequent analysis.

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

The relevant SQL can be found in the the SQL queries folder

[insert link to SQL file]

This produced the 20 markets used in the subsequent analysis.

---

## 5. Metro_Data_Table

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

---

## 6. Airport Code Lookup

The original BigQuery workflow used an `Airport_Codes` lookup table to add
airport names to the DB1B records.

This lookup is part of the historical 2022 workflow but is being reviewed
as part of the reproducibility revision because the original airport-code
source contains outdated or questionable entries.

The original lookup will be preserved as historical provenance but may be
replaced with a more authoritative airport reference dataset in the revised
pipeline.

---

## 7. Historical vs. Reproducibility Workflow

This project distinguishes between the original 2022 analysis and the
2026 reproducibility revision.

The purpose of the revision is not to replace the original analysis with a
different project. Instead, it documents the original methodology and
preserves the historical inputs while improving the reproducibility and
documentation of selected components.

Where a source is replaced, the original source and the reason for the
replacement will be documented.
