# CREATED DATABASE AND TABLES
  create database if not exists fnb_db;
  use fnb_db;
  
  drop table if exists dim_cities;
  create table dim_cities (
  city_id varchar(20) PRIMARY KEY,
  city varchar(20),
  Tier varchar(20)
  );

CREATE TABLE dim_resposents (	
respondent_id INTEGER PRIMARY KEY,
name varchar(50),
Age	varchar(50),
Gender varchar(50),
City_ID varchar(20)
);

CREATE TABLE fact_survey_responses (
response_id INTEGER PRIMARY KEY,
respondent_id INTEGER,
Consume_frequency varchar(80),
Consume_time varchar(80),
Consume_reason varchar(80),
Heard_before varchar(80),
Brand_perception varchar(80),
General_perception varchar(80),
Tried_before varchar(80),
Taste_experience INTEGER,
Reasons_preventing_trying varchar(80),
Current_brands	varchar(80),
Reasons_for_choosing_brands	varchar(80),
Improvements_desired varchar(80),
Ingredients_expected varchar(80),
Health_concerns	varchar(80),
Interest_in_natural_or_organic varchar(80),
Marketing_channels varchar(80),
Packaging_preference varchar(80),
Limited_edition_packaging varchar(80),
Price_range	varchar(25),
Purchase_location varchar(80),
Typical_consumption_situations varchar(80));



-- Imported csv files into tables 

# Primary Analysis

**Demographic insights**

-- 1. who prefers energy drinks more? Males

            select gender,
            concat(Round((100count()/(select count(*) from dim_respodents)), 2),'%') as count
            from dim_respodents
            group by gender
            order by count desc;

Output ------ gender	count
            	Male	60.38%
            	Non-binary	5.07%
            	Female	34.55%  ----

# Which age group?
 
               select age,
              		concat(Round((100*count(*)/(select count(*) from dim_respodents)), 2),'%') as count
              from dim_respodents
              group by age
              order by count desc;

Output ------        age	count
                    	19-30	55.20%
                    	46-65	4.26%
                    	31-45	23.76%
                    	15-18	14.88%
                    	65+	1.90%  ----

-- 2. Which type of marketing reaches the most Youth (15-30)?

            select marketing_channels,
            count(*) as count
            from fact_survey_responses f
            join dim_respodents r	
            on f.respondent_id = r.respondent_id
            where age in ('15-18', '19-30')
            group by marketing_channels
            Order by 2 desc
            
--   Output ------  Online ads	3373
            TV commercials	1785
            Other	702
            Outdoor billboards	702
            Print media	446 ----------



****Consumer Preferences***

 -- 1. What are the preferred ingredients of energy drinks among respondents?:   Caffeine > Vitamins > Sugar > Guarana

          select Ingredients_expected as Ingre_prefered,
          count(*) as count
          from fact_survey_responses
          group by 1
          order by 2 desc;
          
  Output -------	Caffeine	3896
                  Vitamins	2534
                  Sugar	2017
                  Guarana	1553 ------



***Competition Analysis ****

-- 1. Who are the current market leaders? :  Cola-Coka 

          select distinct current_brands,
          count(respondent_id) as count
          from fact_survey_responses
          group by 1
          order by 2 desc

 Output -------     Cola-Coka	2538
                    Bepsi	2112
                    Gangster	1854
                    Blue Bull	1058
                    CodeX	980
                    Sky 9	979
                    Others	479 ------

--2. The reason why consumers prefer them over ours? :  Brand Reputation > Taste/Flavor Preference


            select *, rank() over(partition by brand order by count desc) as prefered_reason
            
            from(
            select current_brands as brand,
            reasons_for_choosing_brands,
            count(*) as count
            from fact_survey_responses
            group by 1, 2
            order by 3 desc) x
            where brand in ('Cola-Coka', 'Bepsi', 'Gangster')

 Output ------- brand	reasons_for_choosing_brands	count	prefered_reason
                Bepsi	Brand reputation	577	1
                Bepsi	Taste/flavor preference	423	2
                Bepsi	Availability	418	3
                Bepsi	Other	355	4
                Bepsi	Effectiveness	339	5
                Cola-Coka	Brand reputation	616	1
                Cola-Coka	Taste/flavor preference	531	2
                Cola-Coka	Availability	510	3
                Cola-Coka	Other	448	4
                Cola-Coka	Effectiveness	433	5
                Gangster	Brand reputation	511	1
                Gangster	Taste/flavor preference	357	2
                Gangster	Availability	339	3
                Gangster	Effectiveness	338	4
                Gangster	Other	309	5 ---------

*** Marketing Channels & Brand Awareness***
-- 1. Which marketing channel can be used to reach more customers? :  Online Ads 



            select  marketing_channels,
            count(*) as count
            from fact_survey_responses
            group by marketing_channels
            Order by 2 desc
            ;

Output -------  Online ads	4020
                TV commercials	2688
                Outdoor billboards	1226
                Other	1225
                Print media	841 ------

 ***Brand Penetration ***

--1. What do people think about our brand? (overall rating) : 3.2819

select avg(taste_experience) as avg_rating
from fact_survey_responses;

Output ------- avg_ratings 
                3.2819 ------

-- 2. Which cities do we need to focus more on? :  Mumbai & Bangalore
           
            select city,
            count(*) as untapped_count
            from fact_survey_responses f
            join dim_respodents r
            on f.respondent_id = r.respondent_id
            join dim_cities c
            on r.city_id = c.city_id
            where heard_before = 'No'
            group by city
            order by 2 desc;


Output ------ Bangalore	1158
              Mumbai	899
              Hyderabad	728
              Pune	377
              Chennai	372
              Delhi	267
              Kolkata	210
              Ahmedabad	207 ------


# cities where consumers were aware of our brand but have not tried it yet

          select city, 
          		count(*) as untapped_count
          from fact_survey_responses f
          join dim_respodents r
          	on f.respondent_id = r.respondent_id
          join dim_cities c
          	on r.city_id = c.city_id
          where heard_before = 'No'
          group by city
          order by 2 desc

Output ------ city    pop_aware
              Mumbai	806
              Pune	357
              Bangalore	340
              Delhi	242
              Hyderabad	214
              Ahmedabad	134  ------

***Purchase behavior***
 -- 1. - Where do respondents prefer to purchase energy drinks? :  *Supermarkets
    
    
        select purchase_location,
        count(*) as count
        from fact_survey_responses
        group by purchase_location;
    

Output ------     purchase_location count 
                  Supermarkets	4494
                  Online retailers	2550
                  Gyms and fitness centers	1464
                  Other	679
                  Local stores	813 ----
  
-- 2. What are the typical consumption situations for energy drinks among respondents? : Sports/exercise	 
        

        select Typical_consumption_situations,
        count(*) as count
        from fact_survey_responses
        group by Typical_consumption_situations
        order by 2 desc;


 Output ------      Sports/exercise	4494
                    Studying/working late	3231
                    Social outings/parties	1487
                    Other	491
                    Driving/commuting	297  ----
                                     