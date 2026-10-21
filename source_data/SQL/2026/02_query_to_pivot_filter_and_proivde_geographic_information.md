*This query pivots the U.S. DoT 2019 dataset and sums the number of passengers from each origin and destination. 
It also applies filters to the data to limit the records pivoted to only flights with a distance between 75 and 500 miles and it excluded flights that have an origin or a destination in Hawaii*
```sql
WITH temp_table as (SELECT
    OriginCityMarketID, Origin_City_Market, DestCityMarketID, Dest_City_Market, Sum(Passengers) as Sum_of_Passengers, AVG(Distance) AS Distance
  FROM `cycling-case-study-362219.us_air_passenger.BTS_Destination_Survey_DB1B_Coupon_unioned`
  WHERE OriginState != 'HI' and DestState != 'HI'
  GROUP BY OriginCityMarketID, Origin_City_Market, DestCityMarketID, Dest_City_Market)
SELECT a.OriginCityMarketID, a.Origin_City_Market, a.DestCityMarketID, a.Dest_City_Market, a.Sum_of_Passengers, a.Distance,
b.Simple_Maps_lat as OriginLat,
b.Simple_maps_lng as OriginLon,
c.Simple_Maps_lat as DestLat,
c.Simple_maps_lng as DestLon, 
from temp_table as a
LEFT JOIN `cycling-case-study-362219.us_air_passenger.BTS_Simple_Maps_Metro_Area_Translation_Table` as b
ON a.OriginCityMarketID = b.OriginCityMarketID
LEFT JOIN `cycling-case-study-362219.us_air_passenger.BTS_Simple_Maps_Metro_Area_Translation_Table` as c
ON a.DestCityMarketID = c.DestCityMarketID
WHERE  a.Distance BETWEEN 75 AND 500 AND b.Top_20 = true
ORDER BY a.Origin_City_Market, a.Sum_of_Passengers DESC
```
