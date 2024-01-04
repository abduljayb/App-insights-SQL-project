
--combine 4 tables downloaded from data source into one table.

create table applestore_description_combined as 

SELECT * FROM appleStore_description1

UNION ALL

SELECT * from appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4

**EXPLORATORY DATA ANALYSIS**

--check the number of unique apps in both tables.

SELECT COUNT (DISTINCT id) as UniqueAppIDs
from AppleStore

SELECT COUNT (DISTINCT id) as UniqueAppIDs
from applestore_description_combined

--check for any missing values in key fields in both tables.

SELECT COUNT(*) as MissingValues
FROM AppleStore
where track_name is null or user_rating is null or prime_genre is null

SELECT COUNT(*) as MissingValues
FROM applestore_description_combined
where app_desc is null 

--Find out the number of apps per genre.

select prime_genre, COUNT(*) as NumApps
FROM AppleStore
GROUP by prime_genre
ORDER by NumApps DESC

-- Get an overview of app ratings.

SELECT min(user_rating) as MinRating,
       max(user_rating) as MaxRating,
       avg(user_rating) as AvgRating
FROM AppleStore 

--Determine whether paid apps have higher ratings than free apps.

SELECT CASE
        WHEN price > 0 then 'Paid'
        else 'Free'
    end as App_Type,
    avg(user_rating) as Avg_Rating
 FROM AppleStore
 GROUP by App_Type
 
 --check if apps that support more languages have higher ratings.
 
 SELECT CASE
        WHEN lang_num < 10 then '<10 languages'
        WHEN lang_num BETWEEN 10 and 30 then '10-30 languages'
        else '>30 languages'
    end as Language_Bucket,
    avg(user_rating) as Avg_Rating
 from AppleStore
 group by Language_Bucket
 ORDER by Avg_Rating desc
 
 --check genres with low ratings.
 
 SELECT prime_genre,
        avg(user_rating) as Avg_Rating
 from AppleStore
 group by prime_genre
 order by Avg_Rating ASC
 limit 10
 
 --check if there's a correlation between length of app description and user rating.

select CASE
            when length(B.app_desc) <100 then 'Short'
            when length(B.app_desc) between 500 and 1000 then 'Medium'
            else 'Long'
        end as description_length_bucket,
        avg(a.user_rating) as average_rating

from
     AppleStore as A
JOIN
     applestore_description_combined as B
ON
     A.id = B.id
group by description_length_bucket
order by average_rating desc

--check top rated apps for each genre.

SELECT
     prime_genre,
     track_name,
     user_rating
from (
      SELECT
      prime_genre,
      track_name,
      user_rating,
      RANK() OVER(PARTITION by prime_genre ORDER by user_rating desc, rating_count_tot desc) as rank
      from
      AppleStore
      ) as a
  where
  a.rank = 1