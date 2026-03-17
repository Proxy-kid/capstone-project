-- Capstone Project

-- Data Source: https://www.kaggle.com/datasets/arashnic/fitbit
use portfolio_project;

-- I made a copy of all the tables that i'll work with
CREATE TABLE dailyactivity_copy AS
SELECT * FROM dailyactivity_merged;

CREATE TABLE sleepday_copy AS
SELECT * FROM sleepday_merged;

CREATE TABLE weightloginfo_copy AS
SELECT * FROM weightloginfo_merged;

-- Data cleaning/ processing Phase

--  Step 1 Check each table for duplicate
SELECT *
FROM dailyactivity_copy;

SELECT Id, ActivityDate, count(*)as duplicate
FROM dailyactivity_copy
GROUP BY Id, ActivityDate
HAVING duplicate > 1;

-- Outcome is 0 duplicates

SELECT * 
FROM sleepday_copy;

SELECT Id, SleepDay, COUNT(*) as duplicate
FROM sleepday_copy
GROUP BY Id, SleepDay
HAVING COUNT(*) > 1;

-- Outcome is 0 duplicates

SELECT * 
FROM weightloginfo_copy;
-- This table has the weightlog of only two users. It Shows that only few users use this feature

--  ----------------------------------------

-- Step 2 standardize data and fix errors

-- Standadize any date related Field to a date type
-- 2 convert the format using str_to_date

desc dailyactivity_copy;
SELECT *
FROM dailyactivity_copy;

UPDATE dailyactivity_copy
SET ActivityDate = STR_TO_DATE(ActivityDate, '%m/%d/%Y');
ALTER TABLE dailyactivity_copy
MODIFY ActivityDate DATE;

desc sleepday_copy;
SELECT SleepDay
FROM sleepday_copy
LIMIT 10;

UPDATE sleepday_copy
SET SleepDay = STR_TO_DATE(SleepDay, '%m/%d/%Y %h:%i:%s %p');
ALTER TABLE sleepday_copy
MODIFY SleepDay DATE;

DESC weightloginfo_copy;

UPDATE weightloginfo_copy
SET Date = STR_TO_DATE(Date, '%m/%d/%Y %h:%i:%s %p');
ALTER TABLE weightloginfo_copy
MODIFY Date DATE;

-- ----------------------------------------------------------------

-- Checking for null values
SELECT 
  COUNT(*) - COUNT(Id) AS Id_nulls,
  COUNT(*) - COUNT(ActivityDate) AS ActivityDate_nulls,
  COUNT(*) - COUNT(TotalSteps) AS TotalSteps_nulls,
  COUNT(*) - COUNT(TotalDistance) AS TotalDistance_nulls,
  COUNT(*) - COUNT(TrackerDistance) AS TrackerDistance_nulls,
  COUNT(*) - COUNT(LoggedActivitiesDistance) AS Logged_nulls,
  COUNT(*) - COUNT(VeryActiveDistance) AS VeryActiveDist_nulls,
  COUNT(*) - COUNT(ModeratelyActiveDistance) AS ModerateDist_nulls,
  COUNT(*) - COUNT(LightActiveDistance) AS LightDist_nulls,
  COUNT(*) - COUNT(SedentaryActiveDistance) AS SedentaryDist_nulls,
  COUNT(*) - COUNT(VeryActiveMinutes) AS VeryActiveMin_nulls,
  COUNT(*) - COUNT(FairlyActiveMinutes) AS FairlyActiveMin_nulls,
  COUNT(*) - COUNT(LightlyActiveMinutes) AS LightlyActiveMin_nulls,
  COUNT(*) - COUNT(SedentaryMinutes) AS SedentaryMin_nulls,
  COUNT(*) - COUNT(Calories) AS Calories_nulls
FROM dailyactivity_copy;
-- Outcome There is no null value

SELECT
    COUNT(*) - COUNT(Id) as missing_Id,
    COUNT(*) - COUNT(TotalSleepRecords) as missing_TotalSleepRecords,
    COUNT(*) - COUNT(SleepDay) as missing_SleepDay,
    COUNT(*) - COUNT(TotalMinutesAsleep) as missing_TotalMinutesAsleep,
    COUNT(*) - COUNT(TotalTimeInBed) as missing_TotalTimeInBed
FROM sleepday_copy; 
-- Outcome There is no null value

-- No need to validate each column checking for nulls, because the dataset has only 3 rows  and i can just view all the records in one query
SELECT *
FROM weightloginfo_copy;

-- there are null value in the fat column
SELECT
    COUNT(*) - COUNT(NULLIF(Fat, '')) as fat
FROM weightloginfo_copy;

-- The fat column will be dropped due to 66% (2 of 3 rows) of the values were missing. Insufficient data for analysis
ALTER TABLE weightloginfo_copy
DROP COLUMN fat;

-- Purpose: To investigate rows with zero TotalSteps
SELECT *
FROM dailyactivity_copy
WHERE TotalSteps <= 0; 
SELECT
   COUNT(DISTINCT id) as affected_users, 
   COUNT(*) as total_row,
   SUM(CASE WHEN TotalSteps > 0 then 1 ELSE 0 END) as non_zero,
   SUM(CASE WHEN TotalSteps <= 0 then 1 ELSE 0 END) as Zero_value
FROM dailyactivity_copy;
-- Observations:
-- rows with 0 TotalSteps usually record 0 for most of the columns within the same row:
-- of these rows only SedentaryMinutes, Calories and ActivityDate were populated with data
-- Out of 216 rows 25 rows recorded zero activities made by 7 users 
-- This could mean that the device were not worn properly or were faulty
-- Action:
-- Exclude it from trend analysis for data intergrety
-- keep it for device usage analysis .

-- Purpose confirm if columns: TotalDistance & TrackerDistance have exact values
SELECT 
  CASE 
    WHEN COUNT(*) = SUM(CASE WHEN TotalDistance = TrackerDistance THEN 1 ELSE 0 END)
    THEN 'Columns are identical'
    ELSE 'Columns differ'
  END as comparison_result
FROM dailyactivity_copy;

-- Observations
-- Yes, both columns are the same

-- Action
-- Drop one of the column
ALTER TABLE dailyactivity_copy
DROP COLUMN TrackerDistance;


-- ------------------------------------------------------------------------------------
-- EXPLORATORY DATA ANALYSIS
SELECT * 
FROM dailyactivity_copy;

-- Get overall summary statistics
SELECT 
   COUNT(DISTINCT Id) as total_users,
   COUNT(*) as total_records,
   MIN(ActivityDate) as start_date,
   MAX(ActivityDate) as end_date,
   DATEDIFF(MAX(ActivityDate), MIN(ActivityDate)) as tracking_period_days
FROM dailyactivity_copy
WHERE TotalSteps > 0;  

-- Purpose Segment Users by their total_distance
SELECT
    Id,
    AVG(TotalDistance) as total_Distance,
    
    CASE 
        WHEN AVG(TotalDistance) >=8 THEN 'Very High'
        WHEN AVG(TotalDistance) >= 5 THEN 'High'
        ELSE 'Low'
	END AS Category
FROM dailyactivity_copy
WHERE TotalSteps > 0
GROUP BY Id;

-- Analyze Users Behavior by Segment
SELECT 
    Activity_group,
    COUNT(Id) Users,
    ROUND(AVG(total_steps), 0) AS avg_steps,
    ROUND(AVG(calories), 0) AS avg_calories,
    ROUND(AVG(avg_very_active_min), 0) as avg_very_active_min,
    ROUND(AVG(avg_sedentary_min), 0) as avg_sedentary_min
FROM
  (
    SELECT
        Id,
        ROUND(AVG(TotalSteps)) as total_Steps,
        ROUND(AVG(Calories)) AS calories,
        ROUND(AVG(VeryActiveMinutes), 0) as avg_very_active_min,
        ROUND(AVG(SedentaryMinutes), 0) as avg_sedentary_min,
        CASE 
            WHEN ROUND(AVG(TotalSteps),0) >= 10000 THEN 'Fitness Enthusiast'
            WHEN ROUND(AVG(TotalSteps),0) >= 5000 THEN 'Casual User'
            ELSE 'Beginner'
	    END AS Activity_group
    FROM dailyactivity_copy
    WHERE TotalSteps > 0
    GROUP BY Id
    ) s
GROUP BY Activity_group
ORDER BY AVG(total_steps) DESC;

-- Findings:
-- 1. Users were segmented into three behavioral groups based on average daily steps:
--    • Fitness Enthusiasts (10,000+ steps)
--    • Casual Users (5,000–9,999 steps)
--    • Beginners (<5,000 steps)

-- 2. Fitness Enthusiasts recorded the highest average very active minutes
--    and the lowest sedentary minutes.

-- 3. Beginners showed the lowest movement intensity and the highest sedentary time.

-- 4. Higher average step counts were associated with increased high-intensity activity
--    and reduced sedentary behavior. 

-- Recommendations:
-- • Introduce movement reminders targeting Beginner users.
-- Build reward systems that'll help  both casuals and beginners transition into higher activity segments.

WITH activity_table AS(
SELECT
        Id,
        ROUND(AVG(TotalSteps)) as total_Steps,
        ROUND(AVG(Calories)) AS calories,
        ROUND(AVG(VeryActiveMinutes), 0) as avg_very_active_min,
        ROUND(AVG(SedentaryMinutes), 0) as avg_sedentary_min,
        CASE 
            WHEN ROUND(AVG(TotalSteps),0) >= 10000 THEN 'Fitness Enthusiast'
            WHEN ROUND(AVG(TotalSteps),0) >= 5000 THEN 'Casual User'
            ELSE 'Beginner'
	    END AS Activity_group
    FROM dailyactivity_copy
    WHERE TotalSteps > 0
    GROUP BY Id
    
)
SELECT
    two.Activity_group,
    COUNT(DISTINCT sleep.Id) Total_user,
    ROUND(AVG(sleep.TotalTimeInBed / 60), 1) AS HoursInBed,
    ROUND(AVG(sleep.TotalMinutesAsleep / 60), 1) AS HourAsleep
FROM sleepday_copy as sleep
JOIN activity_table AS two
  ON sleep.Id = two.Id
GROUP BY two.Activity_group
ORDER BY HourAsleep DESC;

-- Findinds
-- • Beginners recorded the highest average time in bed (~10 hours).
-- • Fitness Enthusiasts recorded the lowest average time in bed (~6.4 hours).

-- Recommendations:
-- Bellabeat could tailor marketing messages:
-- • Beginners → focus on balanced wellness and habit-building.


-- Which days are users mostly active?
SELECT 
  DAYNAME(ActivityDate) as day_of_week,
  COUNT(*) as tracking_instances,
  ROUND(AVG(TotalSteps), 0) as avg_steps,
  ROUND(AVG(Calories), 0) as avg_calories,
  ROUND(AVG(VeryActiveMinutes + FairlyActiveMinutes), 0) as avg_active_minutes,
  ROUND(AVG(SedentaryMinutes), 0) as avg_sedentary_minutes
FROM dailyactivity_copy
WHERE TotalSteps > 0
GROUP BY DAYNAME(ActivityDate), DAYOFWEEK(ActivityDate)
ORDER BY  avg_steps desc;

-- Key Findings
-- Activity was evaluated using a combination of steps, active minutes, calories, and sedentary time.
-- Saturday recorded the highest average steps (~8,000), indicating increased weekend activity. 
-- Friday showed the lowest average steps (~5,993), suggesting reduced engagement before weekends
-- Sedentary time remains relatively high across all days, indicating opportunity for engagement features

-- Recommendations: 
-- Schedule motivational notifications on Fridays to counter reduced activity.
-- Promote weekend challenges when users naturally show higher movement levels.
-- Encourage short movement breaks on weekdays to reduce sedentary time.

    
-- How many users track each feature?
SELECT 
  'Daily Activity Tracking' as feature,
  COUNT(DISTINCT Id) as users,
  ROUND(100.0 * COUNT(DISTINCT Id) / (SELECT COUNT(DISTINCT Id) FROM dailyactivity_copy), 1) as adoption_rate
FROM dailyactivity_copy
WHERE TotalSteps > 0

UNION ALL

SELECT 
  'Sleep Tracking' as feature,
  COUNT(DISTINCT Id) as users,
  ROUND(100.0 * COUNT(DISTINCT Id) / (SELECT COUNT(DISTINCT Id) FROM dailyactivity_copy), 1) as adoption_rate
FROM sleepday_copy

UNION ALL

SELECT 
  'Weight Logging' as feature,
  COUNT(DISTINCT Id) as users,
  ROUND(100.0 * COUNT(DISTINCT Id) / (SELECT COUNT(DISTINCT Id) FROM dailyactivity_copy), 1) as adoption_rate
FROM weightloginfo_copy;

-- Findings
-- -- Adoption rate is calculated using total users present in daily activity data as baseline.
-- Daily activity tracking shows full adoption (100%), indicating core feature usage
-- Sleep tracking adoption is moderate (~71%) with 5 actively logged users
-- Weight logging has low adoption (~29%) only two users logged their device

-- Recommendations
-- Passive tracking features (activity and sleep) show higher adoption than manual logging features,
-- suggesting users prefer automated data collection over effort-based tracking.
            

WITH activity_table AS(
SELECT
        Id,
        ROUND(AVG(TotalSteps)) as total_Steps,
        CASE 
            WHEN ROUND(AVG(TotalSteps),0) >= 10000 THEN 'Fitness Enthusiast'
            WHEN ROUND(AVG(TotalSteps),0) >= 5000 THEN 'Casual User'
            ELSE 'Beginner'
	    END AS Activity_group
    FROM dailyactivity_copy
    WHERE TotalSteps > 0
    GROUP BY Id
),

feature_usage AS (
SELECT 
    DISTINCT Id as users,
	'Sleep Tracking' as feature
FROM sleepday_copy
  UNION ALL
SELECT 
    DISTINCT Id as users, 
	'Weight Logging' as feature
FROM weightloginfo_copy
)

SELECT
    seconds.Activity_group,
    firsts.feature,
    COUNT(DISTINCT firsts.users) AS Users_no
FROM feature_usage AS firsts
JOIN activity_table AS seconds
 ON firsts.users = seconds.Id
GROUP BY seconds.Activity_group, firsts.feature
;

-- What's the rate at which users device were faulty or not worn properly:
WITH activity_table AS(
SELECT
        Id,
        ROUND(AVG(TotalSteps)) as total_Steps,
        CASE 
            WHEN ROUND(AVG(TotalSteps),0) >= 10000 THEN 'Fitness Enthusiast'
            WHEN ROUND(AVG(TotalSteps),0) >= 5000 THEN 'Casual User'
            ELSE 'Beginner'
	    END AS Activity_group
    FROM dailyactivity_copy
    WHERE TotalSteps > 0
    GROUP BY Id
)

SELECT
    daily.Id AS users,
    COUNT(*) AS total_days,
    SUM(CASE WHEN TotalSteps > 0 THEN 1 ELSE 0 END) AS active_days,
    ROUND(100 * SUM(CASE WHEN TotalSteps > 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS usage_rate,
    seg.Activity_group
FROM dailyactivity_copy AS daily
JOIN activity_table AS seg
ON daily.Id = seg.Id
GROUP BY daily.Id
ORDER BY 4 DESC;

-- Findings:
-- • Active days were defined as days where TotalSteps > 0.
-- • Casual users showed consistently high active-day rates (~100%),
--   indicating strong device adherence.
-- • Beginner users had lower active-day rates (<69%), suggesting irregular tracking behavior.
-- • Fitness Enthusiasts maintained high adherence, with rates above ~96%.


-- Recommendation
-- • Introduce reminder notifications after inactivity streaks.
-- • Use habit-forming features (streaks, daily goals) to increase adherence among Beginners. 


-- Sleep quality analysis
SELECT
    Id,
    ROUND(AVG(TotalMinutesAsleep / 60), 1) as avg_hours_asleep,
    ROUND(AVG(TotalTimeInBed / 60), 1) as avg_hours_in_bed,
    ROUND(AVG(TotalTimeInBed - TotalMinutesAsleep), 0) as avg_restless_minutes,
    CASE
        WHEN AVG(TotalMinutesAsleep) < 360 THEN 'Poor Sleep'
        WHEN AVG(TotalMinutesAsleep) <= 480 THEN 'Good Sleep'
        ELSE 'Oversleeping'
    END as sleep_quality
FROM sleepday_copy
GROUP BY Id;
    




