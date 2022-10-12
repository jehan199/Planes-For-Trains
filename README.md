# Planes-For-Trains
This project seeks to use 2019 demand for short haul flights (between 75 and 550 miles) to determine which cities in the United States are best positioned to pivot towards high speed rail as an alternative to short flights.

# Data Collection and Setup

The dataset I am using for this project comes from the US Bureau of Transportation Statistics Origin and Destination Survey : DB1BCoupon. This is a report that is released quarterly that includes every domestic flight itinerary for a given period. Since the report is issued quarterly, I decided to take the 4 quarterly reports from 2019 and consolidate them into one table for analysis. I also downloaded a list of US domestic airport codes that I then joined with the source data to provide more descriptive infomortion 

```
CREATE TABLE us_air_passenger.unioned_and_filtered_table AS
(WITH temp_table AS
(SELECT
  Origin, OriginStateName, Dest, DestStateName, Passengers, Distance, OriginState, DestState, OriginCityMarketID, DestCityMarketID
FROM `high-speed-rail-1029201.us_air_passenger.2019_Q1`
UNION ALL
SELECT
  Origin, OriginStateName, Dest, DestStateName, Passengers, Distance, OriginState, DestState, OriginCityMarketID, DestCityMarketID
FROM `high-speed-rail-1029201.us_air_passenger.2019_Q2`
UNION ALL
SELECT 
  Origin, OriginStateName, Dest, DestStateName, Passengers, Distance, OriginState , DestState, OriginCityMarketID, DestCityMarketID
FROM `high-speed-rail-1029201.us_air_passenger.2019_Q3`
UNION ALL
SELECT
  Origin, OriginStateName, Dest, DestStateName, Passengers, Distance, OriginState, DestState, OriginCityMarketID, DestCityMarketID
FROM `high-speed-rail-1029201.us_air_passenger.2019_Q4`)
SELECT 
a1.string_field_1 AS origin_name,OriginStateName, OriginState,
a2.string_field_1 AS destination_name, DestStateName, DestState,
Origin AS Origin_Airport_Code, Dest AS Dest_Airport_Code, 
OriginCityMarketID, DestCityMarketID, 
Passengers, Distance
FROM temp_table AS full_data
LEFT JOIN `high-speed-rail-1029201.us_air_passenger.Airport_Codes` AS a1 ON full_data.Origin = a1.string_field_0
LEFT JOIN `high-speed-rail-1029201.us_air_passenger.Airport_Codes` AS a2 ON full_data.Dest = a2.string_field_0)
```

# Query Data to Determine the Top 20 Metros
Next I run a query that takes the consolidated table and groups it by the Sum of Passengers for each origin city and then sorts the values in descending order with the output limited to 20 rows. This gives us a list of the metro areas that have the most passengers departing from their airports on short haul flights. A table with the latitude and longitude of these metro areas is also used to provide the spatial data that is needed for the subisquent visualization in R. 

```
SELECT  
  b.Metro_Area_Name,b.State,a.Sum_of_Passengers,b.Latitude,b.Longitude
FROM 
  (WITH temp_table AS
    (SELECT 
      origin_name,Passengers, Distance, OriginState,destination_name, OriginCityMarketID, DestCityMarketID
    FROM `high-speed-rail-1029201.us_air_passenger.unioned_and_filtered_table`
    WHERE  Distance BETWEEN 75 and 500 and OriginState != 'HI')
      SELECT
        OriginCityMarketID,Sum(Passengers) as Sum_of_Passengers
      FROM temp_table
      GROUP BY OriginCityMarketID) as a
LEFT JOIN `high-speed-rail-1029201.us_air_passenger.Metro_Data_Table` as b
ON a.OriginCityMarketID = b.OriginCityMarketID
Order BY Sum_of_Passengers DESC
LIMIT 20
```
# Query Data in SQL to Setup City Specific Analysis in R

While the last query gave us a list of the 20 cities with the most short haul domestic flights, this query is meant to determine where these flights are actually going. This will be key to determining 

```
WITH temp_table as 
  (SELECT
    OriginCityMarketID, DestCityMarketID, Sum(Passengers) as Sum_of_Passengers, AVG(Distance) AS Distance
  FROM `high-speed-rail-1029201.us_air_passenger.unioned_and_filtered_table`
  GROUP BY OriginCityMarketID, DestCityMarketID)
  
SELECT a.*,b.Metro_Area_Name_Origin_,c.Metro_Area_Name_Dest_,d.Latitude as OriginLat,d.Longitude as OriginLon,e.Latitude as DestLat, e.Longitude as DestLon, 
from temp_table as a
LEFT JOIN `high-speed-rail-1029201.us_air_passenger.Metro_Area_Data` as b
ON a.OriginCityMarketID = b.OriginCityMarketID
LEFT JOIN `high-speed-rail-1029201.us_air_passenger.Metro_Area_Data` as c
ON a.DestCityMarketID = c.DestCityMarketID
LEFT JOIN `high-speed-rail-1029201.us_air_passenger.Metro_Area_Data` as d
ON a.OriginCityMarketID= d.OriginCityMarketID
LEFT JOIN `high-speed-rail-1029201.us_air_passenger.Metro_Area_Data` as e
ON a.DestCityMarketID = e.DestCityMarketID
WHERE a.Distance BETWEEN 75 AND 550 AND Sum_of_Passengers > 15000
ORDER BY b.Metro_Area_Name_Origin_, a.Sum_of_Passengers DESC
```
# Using R to Visualize the Data

Now that the data has been queried in SQL, the next step is to visualize the data with an interactive map in R. The goal here is to create a series of maps that show which cities have the most short haul flights that can be replaced by trains.  

## Package Setup in R

In order to visualize the data in R, there are a series of packages that need to be installed and loaded.

```
install.packages('tmap')
install.packages('classInt')
install.packages('sf')
install.packages('spData')
install.packages('mapview')
install.packages('maps')
library('tmap')
library('classInt')
library('sf')
library('spData')
library('mapview')
library('maps')
library('tidyverse')
```

## Loading Source Data

The next step is to load the data into R that is needed to conduct the analysis. 
The table "railroads" is a dataset that highlights the primary railroad tracks in the US as spatial objects for mapping.
"city_data.pt1" is name we are giving to the output of the "Top 20 Metros" query from earlier.
"city_data.pt2" is the name given to the third query from eariler that contains information on the destinations for short haul flights.
"Rank" is a value list that will be used to ascribe a numeric value to the Top 20 Metros based on passenger volume.

```
railroads <- st_read("/Users/jeremyhandy/Trains_for_planes_cars/US Transport Data/tl_2016_us_primaryrailroads/tl_2016_us_primaryrailroads.shp")
city_data.pt1 <- read_csv('/Users/jeremyhandy/Trains_for_planes_cars/US Transport Data/SQL Outputs for Use in R/Cities_with_most_short_flights_geo_data.csv')
city_data.pt2<- read_csv('/Users/jeremyhandy/Trains_for_planes_cars/US Transport Data/SQL Outputs for Use in R/Cities_as_rail_hubs.csv')
Rank <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20)
```

## Setup for Transformation to Geom Data

Now we need to take the latitude and longitude data we have for our metro areas and put it in a format that can be turned into a spatial object. The follwing code does this setup.

```
geographic_data <- city_data.pt1 %>% 
  select(Latitude, Longitude)
geographic_data_pt.2 <- city_data.pt2 %>% 
  select(OriginLat, OriginLon)
geographic_data_pt.3 <- city_data.pt2 %>% 
  select(DestLat, DestLon)
``` 
And this code turns our data concerning railroads, origin cities and destination cities into spatial objects.

```
proj <- "+proj=lcc +lat_1=31.41666666666667 +lat_2=34.28333333333333 +lat_0=0 +lon_0=-83.5 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs"
railroads <- st_transform(railroads, proj)

Top_20_Candidates <- st_as_sf(x = geographic_data, 
                          coords = c("Longitude", "Latitude"),
                          crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")

my.sf.point_dest <- st_as_sf(x = geographic_data_pt.3, 
                             coords = c("DestLon", "DestLat"),
                             crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
```

## Adding Other Columns to Geom Data for Popups

The data that shows up in the popup by default includes the values that the row is referencing for each column included in the dataset. To fill this out, we need to add a few columns to each spatial data table.

```
Top_20_Candidates.$Rank <- Rank
Top_20_Candidates.$Metro_Area_Name <-city_data.pt1$Metro_Area_Name
Top_20_Candidates.$Total_Passengers_Flying_From <-city_data.pt1$Sum_of_Passengers

my.sf.point_dest$Destination_Rank <- city_data.pt2$`Destination Rank`
my.sf.point_dest$Flight_Origin_City <- city_data.pt2$Metro_Area_Name_Origin_
my.sf.point_dest$City_Name <- city_data.pt2$Metro_Area_Name_Dest_
my.sf.point_dest$Passengers_Recieved <- city_data.pt2$Sum_of_Passengers
```

# Top 20 Metros Mapview Function

Now we can start actaully generating the maps. This first map plots each of the metro area and ranks them by color based on the passenger volume.

```
mapview(Top_20_Candidates.,zcol ='Total_Passengers_Flying_From', at = c(250000,500000,750000,1000000,1300000,1600000))
```

# City Specific Mapviews

Here we are going to create views that show the 5 biggest metros in terms of short haul passenger volume as well as the existing railroad network and the metros that end up recieving the passenegers. The first code chunk will be the setup that allows us to select a single metro and the second code chunk will be the functions that will actually create each map.

Setup:
```
Atlanta <- filter(Top_20_Candidates., Metro_Area_Name == 'Atlanta')
Atlanta_dest <- filter(my.sf.point_dest, Flight_Origin_City  == 'Atlanta')

LA_Inland_Empire <- filter(Top_20_Candidates., Metro_Area_Name =='LA/Inland Empire')
LA_Inland_Empire_dest <- filter(my.sf.point_dest, Flight_Origin_City  == 'LA/Inland Empire')

Washington_D.C. <- filter(Top_20_Candidates., Metro_Area_Name == 'Washington D.C.')
Washington_D.C_Dest <- filter(my.sf.point_dest, Flight_Origin_City  == 'Washington D.C.')

Bay_Area <- filter(Top_20_Candidates., Metro_Area_Name =='Bay Area')
Bay_Area_dest <- filter(my.sf.point_dest, Flight_Origin_City  == 'Bay Area')

Charlotte <- filter(Top_20_Candidates., Metro_Area_Name =='Charlotte')
Charlotte_dest <- filter(my.sf.point_dest, Flight_Origin_City  == 'Charlotte')
```
Execution:
```
mapview(Atlanta_dest, zcol = 'Passengers_Recieved',map.types = "OpenStreetMap", at = c(30000,50000,80000,110000,140000)) +
  mapview(roads,color = 'grey', legend = FALSE)+
  mapview(Atlanta, zcol = 'Metro_Area_Name', color ="red", legend = FALSE)

mapview(LA_Inland_Empire_dest, zcol = 'Passengers_Recieved',map.types = "OpenStreetMap",at = c(20000,100000,200000,600000))+
  mapview(roads,color = 'grey', legend = FALSE) +
  mapview(LA_Inland_Empire,zcol = 'Metro_Area_Name', color ="red", legend = FALSE)
  
mapview(Washington_D.C_Dest, zcol = 'Passengers_Recieved',map.types = "OpenStreetMap",at = c(20000,100000,200000,600000))+
  mapview(roads,color = 'grey', legend = FALSE) +
  mapview(Washington_D.C.,zcol = 'Metro_Area_Name', color ="red", legend = FALSE)
  
mapview(Bay_Area_dest, zcol = 'Passengers_Recieved',map.types = "OpenStreetMap",at = c(17000,100000,200000,600000))+
  mapview(roads,color = 'grey', legend = FALSE) +
  mapview(Bay_Area,zcol = 'Metro_Area_Name', color ="red", legend = FALSE)

mapview(Charlotte_dest, zcol = 'Passengers_Recieved',map.types = "OpenStreetMap",at = c(20000,50000,100000,150000))+
  mapview(roads,color = 'grey', legend = FALSE) +
  mapview(Charlotte,zcol = 'Metro_Area_Name', color ="red", legend = FALSE)
```

# Links to Visualizations

Top 20 Cities with Most Short Haul Flights:file:///Users/jeremyhandy/Trains_for_planes_cars/Short-Haul-Flight-Cities.html
Atlanta as a Hub:file:///Users/jeremyhandy/Trains_for_planes_cars/Atlanta-Visual.html
LA/Inland Empure as a Hub:file:///Users/jeremyhandy/Trains_for_planes_cars/LA_Inland-Empire-as-a-Hub.html
Washington D.C. as a Hub:file:///Users/jeremyhandy/Trains_for_planes_cars/Washington-D.C.-as-a-Hub.html
The Bay Area as a Hub:file:///Users/jeremyhandy/Trains_for_planes_cars/Bay-Area-as-a-Hub.html
Charlotte as a Hub:file:///Users/jeremyhandy/Trains_for_planes_cars/Charlotte-as-a-Hub..html


