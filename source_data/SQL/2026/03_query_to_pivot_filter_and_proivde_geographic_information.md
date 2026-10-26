This query pivots the BTS 2019 dataset and sums the number of passengers from each origin and destination. 

It also applies filters to the data to limit the records pivoted to only flights with a distance between 75 and 500 miles, it excluded flights that have an origin or a destination in Hawaii, it assigns an `Origin_Rank` value based on the volume of passengers leaving from a city-market on short haul flights and creates an `Destination_Rank` value that ranks the volume of passengers leaving from each origin to the top destination metros areas.

Lastly the query filters to only the top 5 `Destination_Ranks` for each origin and it sorts the data first by `Origin_Rank` and then by `Destination_Rank`.

The output of this query is 
```sql
WITH temp_table AS (
  SELECT
    OriginCityMarketID,
    Origin_City_Market,
    DestCityMarketID,
    Dest_City_Market,
    SUM(Passengers) AS Sum_of_Passengers,
    AVG(Distance) AS Distance
  FROM `rail-as-alt-travel-362219.us_air_passenger.BTS_Destination_Survey_DB1B_Coupon_unioned`
  WHERE OriginState != 'HI'
    AND DestState != 'HI'
  GROUP BY
    OriginCityMarketID,
    Origin_City_Market,
    DestCityMarketID,
    Dest_City_Market
),

filtered_table AS (
  SELECT
    a.*,
    b.US_Census_Bureau_LAT AS OriginLat,
    b.US_Census_Bureau_LON AS OriginLon,
    c.US_Census_Bureau_LAT AS DestLat,
    c.US_Census_Bureau_LON AS DestLon
  FROM temp_table AS a
  LEFT JOIN `rail-as-alt-travel-362219.us_air_passenger.BTS_US_Census_Place_City_Market_Translation_Table` AS b
    ON a.OriginCityMarketID = b.OriginCityMarketID
  LEFT JOIN `rail-as-alt-travely-362219.us_air_passenger.BTS_US_Census_Place_City_Market_Translation_Table` AS c
    ON a.DestCityMarketID = c.DestCityMarketID
  WHERE a.Distance BETWEEN 75 AND 500
    AND b.Top_20 = TRUE
),

ranked_table AS (
  SELECT
    *,
    DENSE_RANK() OVER (
      ORDER BY Origin_Total_Passengers DESC
    ) AS Origin_Rank,
    DENSE_RANK() OVER (
      PARTITION BY OriginCityMarketID
      ORDER BY Sum_of_Passengers DESC
    ) AS Destination_Rank
  FROM (
    SELECT
      *,
      SUM(Sum_of_Passengers) OVER (
        PARTITION BY OriginCityMarketID
      ) AS Origin_Total_Passengers
    FROM filtered_table
  )
)

SELECT OriginCityMarketID, Origin_City_Market, DestCityMarketID, Dest_City_Market, Sum_of_Passengers, Distance, OriginLat, OriginLon, DestLat, DestLon, Origin_Rank, Destination_Rank
FROM ranked_table
WHERE Origin_rank <=5 and Destination_Rank <= 5
ORDER BY Origin_Rank, Destination_Rank;
```
