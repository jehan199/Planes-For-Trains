# Trains for Planes: Exploring Potential High Speed Rail Routes to Replace Short-Haul Flights in the United States

## Project Overivew

*Trains for Planes* is a data analysis project that seeks to use 2019 demand for domestic short-haul flights in the United States to determine which cities in the U.S. are best positioned to potentially pivot towards high speed rail as an alternative to air transportation. 

The project was originally conceptualized and drafted in 2022 and has been substantially revised in 2026. The primary dataset that was used for this project comes from the U.S. Bureau of Transportation Statistics (BTS) Origin and Destination Survey : DB1BCoupon. This report contains a 10% sample of domestic flight itinerates in the U.S. and it was used to identify city markets with significant short-haul passenger volumes and examine the destinations associated with those markets.

The project combines SQL-based data analysis, geographic reference data, R-based visualization, and interactive maps to create a visual representation of the markets with potential for high speed rail. 

The goal is to identify potentially relevant markets for further investigation—not to determine which rail corridors should be built purely based on the object of this project's analysis. 

## Research Question

Which U.S. city markets have substantial short-haul air passenger volumes, and which origin-destination pairs could represent potential high-speed rail routes based on existing air travel demand?

The analysis uses a project-defined distance range of 75–500 miles to screen for short-haul air travel. This range is an analytical choice for narrowing the scope of the project, not a universal threshold for high-speed rail competitiveness. 

The distance criteria are based on the concept that high-speed rail can be more time-competitive than other forms of transportation for city-center-to-city-center travel within a certain distance range.

The upper limit of 500 miles reflects the idea that, beyond a certain distance, the higher cruising speed of air travel may outweigh the time spent getting to and from airports, passing through security, boarding, and disembarking. Within the project's selected range, however, these additional steps can make high-speed rail competitive with air travel in total city-center-to-city-center journey time. The 500-mile threshold is therefore used as a screening criterion for identifying potentially relevant short-haul air markets, rather than as a definitive point at which air travel becomes faster than rail. Actual travel-time competitiveness depends on factors such as airport and station access, service frequency, and the speed and routing of the rail service.

The lower limit of 75 miles reflects the potential advantage of personal vehicles over shorter distances. Driving avoids the additional time required to reach a train station, board and disembark, and travel from the destination station to the city center. However, as the distance increases, the higher speed of high-speed rail may compensate for these fixed time costs, making rail more competitive with driving.

## Methodology

The analysis uses the four quarterly 2019 BTS Origin and Destination Survey DB1B Coupon datasets.

At a high level, the workflow consists of the following steps:

- Combine quarterly data. Load and combine the four quarterly DB1B Coupon datasets using SQL in Google BigQuery.

- Filter and rank markets. Apply the project's distance and geographic criteria, aggregate passenger values by city market, and identify the 20 highest-volume origin markets.

- Examine destinations. Analyze origin-destination passenger volumes for selected markets and identify high-volume destinations.

- Add geographic information. Associate city markets with geographic coordinates to support spatial analysis and visualization.

- Create visualizations. Use R and interactive HTML maps to compare the selected origin markets and explore the destinations associated with the highest-volume markets.

The project uses passenger values derived from the DB1B sample. These values are useful for comparisons within the defined analytical scope but should not be interpreted as complete counts of all airline passengers considering that the DB1B sample is only a 10% sample of passenger flight itineraries. 

## Evolution of the Project: 2022–2026

While the 2019 BTW Origin and Destination Survey : DB1BCoupon remains the foundational source data for the project and the research question remained the same, several other source data files, along with their downstream SQL queries and R code, were changed in the 2026 revision.

# Original analysis — 2022

The original workflow used BigQuery, Excel, geographic data from SimpleMaps U.S. Cities Basic v1.75, and R-based interactive visualizations.

The analysis identified 20 high-volume origin markets and examined the destinations associated with five leading markets:

- Atlanta

- LA/Inland Empire

- Washington, D.C.

- Bay Area

- Charlotte

The resulting maps provided a geographic view of short-haul air passenger volumes and the destinations connected to these markets.

# Revised analysis — 2026

The 2026 revision revisited the original workflow, its data sources, and its geographic methodology.

During this review, it was discovered that duplicate airport-code entries in the legacy reference data had inflated passenger totals for some origin-destination combinations. The revised SQL workflow removed the problematic airport-code joins and use BTS city-market identifiers and market-name reference data instead.

The revised workflow also uses the U.S. Census Bureau's 2026 Gazetteer Places dataset for geographic reference information, replacing the SimpleMaps coordinates used in the original analysis. This was done because it became clear upon review that the SimpleMaps dataset wasn't allowed to be distributed without explicit permission. 

The 2026 outputs provide an updated view of the selected markets using the revised methodology. The historical 2022 workflow and its outputs are retained separately to document the project's development and preserve the distinction between the two analyses.

The revisions demonstrate the importance of checking reference data, validating analytical assumptions, checking the rules that govern the redistribution of source data, and documenting methodological changes when revisiting an existing data project.

# Interactive Visualizations

The repository includes interactive HTML maps from both the original and revised analyses.

The visualizations include:

- A national map comparing the 20 selected origin markets.

- Individual hub maps exploring destinations associated with selected high-volume origin markets.

- Historical 2022 maps preserved for comparison with the revised 2026 outputs.

The maps are intended to help readers explore the geographic distribution of passenger volumes and identify markets for potential high speed rail routes.

# 2026 Revised Analysis

- National map: Cities with the Most Short-Haul Flights — 2026

- Atlanta as a Rail Hub — 2026

- Los Angeles as a Rail Hub — 2026

- Washington, D.C. as a Rail Hub — 2026

- San Francisco as a Rail Hub — 2026

- Charlotte as a Rail Hub — 2026

[View the 2026 outputs on GitHub](https://github.com/jehan199/Planes-For-Trains/releases#release-v1.0-2026-outputs)

# 2022 Original Analysis 

- Short-Haul Flight Cities

- Atlanta as a Rail Hub

- LA/Inland Empire as a Rail Hub

- Washington, D.C. as a Rail Hub

- Bay Area as a Rail Hub

- Charlotte as a Rail Hub

[View the 2022 outputs on Github](https://github.com/jehan199/Planes-For-Trains/releases#release-v1.0-2022-outputs)

* Note that some external basemap providers used by the original interactive maps have changed their access policies since 2022. Consequently, certain basemaps may no longer function exactly as they did when the HTML files were originally created. *

# Tools and data sources

| Tool | Purpose |
|:---|:---|
| Google BigQuery and SQL | Combining quarterly datasets, filtering records, aggregating passenger values, and ranking markets |
| Microsoft Excel | Supporting intermediate data restructuring in the original workflow |
| R | Spatial data processing and interactive visualization |

| Data Source | Purpose |
|:---|:---|
| BTS DB1B Coupon data | Source of sampled airline ticket and passenger information |
| BTS Lookup Table | Source of city-market names to link to each city-market-id in the BTS DB1B Coupon data 
| SimpleMaps U.S. Cities Basic v1.75 | Geographic reference data used in the 2022 analysis |
| U.S. Census Bureau Gazetteer Places, 2026 | Geographic reference data used in the revised analysis |
| U.S. Census Bureau TIGER/Line Primary Roads, 2016 | Visual context both the 2022 and 2026 maps |
