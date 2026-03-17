-- ====================================================================
-- TABLEAU DASHBOARD QUERIES
-- Additional queries to export for visualization
-- Export each query result as CSV and import to Tableau
-- ====================================================================

USE portfolio_project;

-- ====================================================================
-- DASHBOARD 1: EXECUTIVE OVERVIEW
-- ====================================================================

-- Query 1.1: KPI Summary
SELECT 
    COUNT(DISTINCT Id) as total_users,
    ROUND(AVG(TotalSteps), 0) as avg_daily_steps,
    ROUND(AVG(TotalDistance), 2) as avg_daily_distance,
    ROUND(AVG(Calories), 0) as avg_daily_calories,
    ROUND(AVG(VeryActiveMinutes + FairlyActiveMinutes), 0) as avg_active_minutes,
    ROUND(AVG(SedentaryMinutes), 0) as avg_sedentary_minutes
FROM dailyactivity_copy
WHERE TotalSteps > 0;
