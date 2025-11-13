-- ============================================================
-- Fantasy Premier League SQL Analysis
-- Full workflow: base table, analytical views, and key insights
-- ============================================================

-- Clean slate (optional)
DROP VIEW IF EXISTS fpl.fpl_team_summary;
DROP VIEW IF EXISTS fpl.fpl_cost_performance;
DROP VIEW IF EXISTS fpl.fpl_base;

-- ============================================================
-- CREATE BASE VIEW
-- ============================================================

-- FPL positions: 1 GK, 2 DEF, 3 MID, 4 FWD
CREATE OR REPLACE VIEW fpl.fpl_base AS
SELECT
  first_name,
  second_name,
  -- Convert element_type to readable positions
  CASE element_type
    WHEN 1 THEN 'GK'
    WHEN 2 THEN 'DEF'
    WHEN 3 THEN 'MID'
    WHEN 4 THEN 'FWD'
    ELSE CONCAT('TYPE_', element_type)
  END AS position,

  -- Map team IDs to team names
  CASE team
    WHEN 1 THEN 'Arsenal'
    WHEN 2 THEN 'Aston Villa'
    WHEN 3 THEN 'Burnley'
    WHEN 4 THEN 'Bournemouth'
    WHEN 5 THEN 'Brentford'
    WHEN 6 THEN 'Brighton'
    WHEN 7 THEN 'Chelsea'
    WHEN 8 THEN 'Crystal Palace'
    WHEN 9 THEN 'Everton'
    WHEN 10 THEN 'Fulham'
    WHEN 11 THEN 'Leeds'
    WHEN 12 THEN 'Liverpool'
    WHEN 13 THEN 'Man City'
    WHEN 14 THEN 'Man United'
    WHEN 15 THEN 'Newcastle'
    WHEN 16 THEN 'Nottingham Forest'
    WHEN 17 THEN 'Southampton'
    WHEN 18 THEN 'Tottenham'
    WHEN 19 THEN 'West Ham'
    WHEN 20 THEN 'Wolves'
    ELSE CONCAT('TEAM_', team)
  END AS team_name,

  now_cost / 10.0 AS cost_m,  -- Convert tenths of a million to millions

  total_points,
  minutes,
  starts,
  goals_scored,
  assists,
  clean_sheets,
  points_per_game,

  -- Per 90 stats
  expected_goals_per_90,
  expected_assists_per_90,
  expected_goal_involvements_per_90,
  expected_goals_conceded_per_90,
  goals_conceded_per_90,
  defensive_contribution_per_90,
  saves_per_90,
  points_per_90,
  goals_per_90,
  assists_per_90,

  points_per_million

FROM fpl.fpl_data
WHERE minutes >= 180;  -- sensible filter to remove short cameos
-- ============================================================


-- ============================================================
-- 1 TOP PLAYERS AND POSITIONAL ANALYSIS
-- ============================================================

-- Top 10 Players Overall by Total Points
SELECT 
  CONCAT(first_name, ' ', second_name) AS player_name,
  position,
  team_name,
  total_points,
  points_per_game,
  goals_scored,
  assists,
  clean_sheets,
  cost_m
FROM fpl.fpl_base
ORDER BY total_points DESC
LIMIT 10;


-- 2 Best Players by Position (Top 3 by Points per Game)
WITH ranked_players AS (
  SELECT 
    position,
    CONCAT(first_name, ' ', second_name) AS player_name,
    team_name,
    points_per_game,
    total_points,
    cost_m,
    starts,
    RANK() OVER (PARTITION BY position ORDER BY points_per_game DESC) AS rank_in_position
  FROM fpl.fpl_base
  WHERE minutes >= 500
)
SELECT *
FROM ranked_players
WHERE rank_in_position <= 3;


-- Underperformers: High Expected Goals but Low Actual Goals
SELECT 
  CONCAT(first_name, ' ', second_name) AS player_name,
  team_name,
  ROUND(expected_goals_per_90 * (minutes / 90), 2) AS expected_goals_total,
  goals_scored,
  ROUND((expected_goals_per_90 * (minutes / 90)) - goals_scored, 2) AS xg_difference,
  minutes
FROM fpl.fpl_base
WHERE minutes >= 500
ORDER BY xg_difference DESC
LIMIT 10;


-- Overperformers: Outscoring Expected Goals
SELECT 
  CONCAT(first_name, ' ', second_name) AS player_name,
  team_name,
  goals_scored,
  ROUND(expected_goals_per_90 * (minutes / 90), 2) AS expected_goals_total,
  ROUND(goals_scored - (expected_goals_per_90 * (minutes / 90)), 2) AS overperformance,
  minutes
FROM fpl.fpl_base
WHERE minutes >= 500
ORDER BY overperformance DESC
LIMIT 10;

-- ============================================================


-- ============================================================
-- 3 TEAM PERFORMANCE SUMMARY VIEW
-- ============================================================

CREATE OR REPLACE VIEW fpl.fpl_team_summary AS
SELECT 
  team_name,
  COUNT(*) AS num_players,
  ROUND(SUM(total_points), 0) AS total_team_points,
  ROUND(AVG(points_per_game), 2) AS avg_points_per_game,
  ROUND(AVG(goals_conceded_per_90), 2) AS avg_goals_conceded,
  ROUND(AVG(clean_sheets), 2) AS avg_clean_sheets,
  ROUND(AVG(points_per_million), 2) AS avg_value_efficiency
FROM fpl.fpl_base
GROUP BY team_name
ORDER BY total_team_points DESC;

-- Preview
SELECT * FROM fpl.fpl_team_summary;

-- ============================================================


-- ============================================================
-- 4 PLAYER VALUE & EFFICIENCY ANALYSIS
-- ============================================================

-- Player Efficiency: Best Value Players by Points per Million
WITH ranked_value AS (
  SELECT 
    position,
    CONCAT(first_name, ' ', second_name) AS player_name,
    team_name,
    total_points,
    cost_m,
    ROUND(points_per_million, 2) AS points_per_million,
    ROUND(points_per_game, 2) AS points_per_game,
    RANK() OVER (PARTITION BY position ORDER BY points_per_million DESC) AS rank_value
  FROM fpl.fpl_base
  WHERE minutes >= 500
)
SELECT 
  position,
  player_name,
  team_name,
  total_points,
  cost_m,
  points_per_million,
  points_per_game,
  rank_value
FROM ranked_value
WHERE rank_value <= 5
ORDER BY position, rank_value;

-- ============================================================


-- ============================================================
-- 5 DREAM TEAM CALCULATION
-- ============================================================

-- DREAM TEAM XI: Top-performing players by position
WITH ranked_players AS (
  SELECT 
    position,
    CONCAT(first_name, ' ', second_name) AS player_name,
    team_name,
    total_points,
    cost_m,
    points_per_game,
    points_per_million,
    RANK() OVER (PARTITION BY position ORDER BY total_points DESC) AS pos_rank
  FROM fpl.fpl_base
  WHERE minutes >= 500
)
SELECT 
  position,
  player_name,
  team_name,
  total_points,
  cost_m,
  points_per_game,
  points_per_million,
  pos_rank
FROM ranked_players
WHERE 
  (position = 'GK'  AND pos_rank <= 1) OR
  (position = 'DEF' AND pos_rank <= 4) OR
  (position = 'MID' AND pos_rank <= 3) OR
  (position = 'FWD' AND pos_rank <= 3)
ORDER BY FIELD(position, 'GK', 'DEF', 'MID', 'FWD'), pos_rank;


-- DREAM TEAM SUMMARY: Total Cost, Points, and Efficiency
WITH ranked_players AS (
  SELECT 
    position,
    total_points,
    cost_m,
    RANK() OVER (PARTITION BY position ORDER BY total_points DESC) AS pos_rank
  FROM fpl.fpl_base
  WHERE minutes >= 500
)
SELECT 
  ROUND(SUM(cost_m), 1) AS total_team_cost_m,
  SUM(total_points) AS total_team_points,
  ROUND(SUM(total_points) / SUM(cost_m), 2) AS team_value_efficiency
FROM ranked_players
WHERE 
  (position = 'GK'  AND pos_rank <= 1) OR
  (position = 'DEF' AND pos_rank <= 4) OR
  (position = 'MID' AND pos_rank <= 3) OR
  (position = 'FWD' AND pos_rank <= 3);

-- ============================================================


-- ============================================================
-- 6 COST vs PERFORMANCE CORRELATION VIEW
-- ============================================================

CREATE OR REPLACE VIEW fpl.fpl_cost_performance AS
SELECT 
  team_name,
  position,
  ROUND(AVG(cost_m), 2)  AS avg_cost_m,
  ROUND(AVG(total_points), 2) AS avg_total_points,
  ROUND(AVG(points_per_game), 2) AS avg_points_pg,
  ROUND(AVG(points_per_million), 2) AS avg_value_efficiency,
  ROUND(AVG(goals_per_90), 3) AS avg_goals_90,
  ROUND(AVG(assists_per_90), 3) AS avg_assists_90
FROM fpl.fpl_base
WHERE minutes >= 500
GROUP BY team_name, position
ORDER BY position, avg_total_points DESC;

-- Preview
SELECT * FROM fpl.fpl_cost_performance LIMIT 20;

-- ============================================================

-- Final check: preview base dataset
SELECT * FROM fpl.fpl_base LIMIT 20;


