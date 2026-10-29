# Trains for Planes: Exploring Potential High Speed Rail Routes to Replace Short-Haul Flights in the United States

## Project Overivew

*Trains for Planes* is a data analysis project that seeks to use 2019 demand for domestic short-haul flights in the United States to determine which cities in the U.S. are best positioned to pivot towards high speed rail as an alternative to air transportation. 

The project was originally conceptualized and drafted in 2022 and has been substantially revised in 2026. The primary dataset that was used for this project comes from the U.S. Bureau of Transportation Statistics (BTS) Origin and Destination Survey : DB1BCoupon. This report contains a 10% sample of domestic flight itinerates in the U.S. and it was used to identify city markets with significant short-haul passenger volumes and examine the destinations associated with those markets.

The project combines SQL-based data analysis, geographic reference data, R-based visualization, and interactive maps to create a visual representation of the markets with potential for high speed rail. 

The goal is to identify potentially relevant markets for further investigation—not to determine which rail corridors should be built purely based on the object of this project's analysis. 

## Research Question

Which U.S. city markets have the highest short-haul air passenger volumes, and which destinations associated with those markets could warrant further investigation as potential high-speed rail markets?

The analysis uses a project-defined distance range of 75–500 miles to screen for short-haul air travel. This range is an analytical choice for narrowing the scope of the project, not a universal threshold for high-speed rail competitiveness. It is however, based on the concept that high speed rail can be more time competitive than other forms of transportation for city center to city center travel in a certain distance range where the fixed time cost of a flight (getting to the airport, going through security, boarding, unboarding and getting from the airport in the destination city to the center of that destination city) makes the trip slower than a train despite the faster travel speed. This constitutes the upper, 500 mile limit. The lower 75 mile limit applies to personal vehicles. Here the fixed time cost of using the train (getting to the station, boarding, unboarding and getting to the city center of the destination city) might mean that driving is faster over a distance below 75 miles, but as the distance increases, the faster train speed for a high speed train will compensate the fixed time cost.



