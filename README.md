# Trains for Planes: Exploring Potential High Speed Rail Routes to Replace Short-Haul Flights in the United States

## Project Overivew

*Trains for Planes* is a data analysis project that seeks to use 2019 demand for domestic short-haul flights in the United States to determine which cities in the U.S. are best positioned to potentially pivot towards high speed rail as an alternative to air transportation. 

The project was originally conceptualized and drafted in 2022 and has been substantially revised in 2026. The primary dataset that was used for this project comes from the U.S. Bureau of Transportation Statistics (BTS) Origin and Destination Survey : DB1BCoupon.The BTS Origin and Destination Survey DB1B Coupon dataset contains a 10% sample of airline tickets for domestic U.S. air travel. The project uses this sample to identify city markets with significant short-haul passenger volumes and examine the destinations associated with those markets.

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

Visual context in the historical maps

# Limitations and Scope

This project is an exploratory market-screening analysis. Its results should be interpreted with the following limitations in mind.

Sampled passenger data: 

BTS describes DB1B as a 10% sample of airline tickets. Passenger values calculated in this project come from the sampled records and are not complete counts of all airline passengers itineraries for 2019. 

Project-defined distance range: 

The 75–500 mile range is used to narrow the analysis. It is not necessarily the case that high speed rail is always the most time effective transportation option in distance range. This depends on a number of factors including car traffic, whether or not a rail route is non-stop or has intermediate stops, the distance from the airport to the city center amongst other factors.

Air travel distance versus rail distance:

The distance field comes from the BTS airline data. It does not establish the distance, alignment, or travel time of a potential rail corridor. For example, rail lines on the ground would potentially have to navigate topographical features such as lakes, rivers, mountains and canyons. Such features could potentially force a rail alignment into a longer route than what a plane would have to fly to connect the same locations. 

Additionally, the distance for these airline passenger itineraries is calculated from where the origin airport is physically located relative to the destination airport. It is generally the case that central urban rail terminals are positioned closer to the city center than airports. As a result, the distance between the airports of an origin and destination city may not be the same as the distance between two hypothetical central rail terminals.  

Geographic representation:

City-market identifiers and geographic reference points serve different purposes. The coordinates used to visualize a market are geographic proxies and do not necessarily represent the boundaries or center of the corresponding metropolitan area.

No rail feasibility assessment:

The project does not model rail construction costs, infrastructure requirements, operating costs, service frequency, door-to-door travel times, projected ridership, or economic feasibility. High passenger volume alone does not establish that a potential rail route would be viable.

Historical data and methodology:

The 2022 analysis contains a documented data-quality issue involving duplicate airport-code reference entries. The revised 2026 analysis addresses this issue and its results should be understood as outputs of a revised workflow. 

# Potential for Expanded Scope and Future Research

The project could potentially be used as a part of a more sophisticated multivariable model to determine with greater accuracy which cities in the United States are best positioned to become hubs for high speed rail infrastructure.

Other relevant variables that could be added to the analysis in the future incldude:

- Data on passenger volumes for car based transit (buses and personal vehicles)
- Data analysis concerning the potential costs of a purposed rail alignment
- A survey of the topographical conditions that exist between perspective rail routes
- Forecasting of future demand for travel between U.S. cities and the associated revenue that this would generate

# Repository Documentation

The repository contains the main project overview and separate documentation for the two analytical workflows.

- README.md — project overview, research question, methodology, interactive visualization links, limitations, and repository navigation.

- DATA_PROVENANCE_2022.md — detailed sources, transformations, intermediate datasets, and visualization workflow for the original analysis.

- DATA_PROVENANCE_2026.md — detailed sources, transformations, methodological revisions, and outputs for the updated analysis.

- Supporting SQL, derived datasets, source data, R code, and generated outputs are organized under source_data/, with separate subfolders for 2022 and 2026 where applicable.

# Conclusion

Trains for Planes explores how publicly available transportation data can help identify potential high-speed rail routes by examining existing short-haul air travel demand.

Beyond the initial analysis, the project documents the process of revisiting an existing workflow, identifying a data-quality problem, updating geographic reference data, and preserving the historical outputs alongside a revised analysis.

The resulting maps provide a starting point for investigating potential alternatives to short-haul air travel. Determining whether any particular route could support high-speed rail would require additional analysis of infrastructure, travel times, costs, demand, and operational feasibility.
