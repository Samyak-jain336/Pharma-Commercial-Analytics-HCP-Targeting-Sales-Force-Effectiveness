USE pharmaanalytics;

CREATE OR REPLACE VIEW vw_hcp_tiering AS
	WITH hcp_scores AS (
    SELECT
        hcp_id,
        specialty,
        state,
        territory,
        rep_id,
        baseline_rx_monthly,
        rep_access_score,
        competitor_share,
        panel_size,
        AVG(rx_lift_weekly) AS avg_lift,
        (baseline_rx_monthly * 0.3
        + rep_access_score   * 100 * 0.3
        + competitor_share   * 100 * 0.2
        + panel_size         * 0.01 * 0.2) AS composite_score
    FROM hcp_marketing
    GROUP BY hcp_id, specialty, state, territory, rep_id,
             baseline_rx_monthly, rep_access_score,
             competitor_share, panel_size
),
hcp_tiered AS (
    SELECT *,
        NTILE(3) OVER (ORDER BY composite_score DESC) AS tier_raw
    FROM hcp_scores
)
SELECT
    hcp_id,
    specialty,
    state,
    territory,
    rep_id,
    baseline_rx_monthly,
    rep_access_score,
    competitor_share,
    panel_size,
    avg_lift,
    ROUND(composite_score, 2) AS composite_score,
    CASE tier_raw
        WHEN 1 THEN 'A'
        WHEN 2 THEN 'B'
        WHEN 3 THEN 'C'
    END AS hcp_tier
FROM hcp_tiered
ORDER BY composite_score DESC;

CREATE OR REPLACE VIEW vw_quota_attainment AS
	SELECT
    rep_id,
    territory,
    ROUND(AVG(rx_lift_weekly), 2)       AS avg_actual_lift,
    ROUND(AVG(weekly_quota_rx_lift), 2) AS quota,
    ROUND(AVG(rx_lift_weekly) / AVG(weekly_quota_rx_lift) * 100, 1) AS pct_quota_attained,
    CASE
        WHEN AVG(rx_lift_weekly) / AVG(weekly_quota_rx_lift) * 100 >= 100 THEN 'On Track'
        WHEN AVG(rx_lift_weekly) / AVG(weekly_quota_rx_lift) * 100 >= 80  THEN 'At Risk'
        ELSE 'Underperforming'
    END AS status
FROM hcp_marketing
GROUP BY rep_id, territory
ORDER BY pct_quota_attained ASC;

CREATE OR REPLACE VIEW vw_channel_roi AS
SELECT
    ROUND(SUM(rx_lift_weekly) / SUM(cost_email), 3)        AS roi_email,
    ROUND(SUM(rx_lift_weekly) / SUM(cost_rep), 3)           AS roi_rep,
    ROUND(SUM(rx_lift_weekly) / SUM(cost_programmatic), 3)  AS roi_programmatic,
    ROUND(SUM(rx_lift_weekly) / SUM(cost_search), 3)        AS roi_search,
    ROUND(SUM(rx_lift_weekly) / SUM(cost_social), 3)        AS roi_social,
    ROUND(SUM(rx_lift_weekly) / SUM(cost_events), 3)        AS roi_events
FROM hcp_marketing;

CREATE OR REPLACE VIEW vw_priority_call_list AS
SELECT
    hcp_id,
    specialty,
    territory,
    rep_id,
    ROUND(rep_access_score, 2)   AS rep_access_score,
    call_recency_days,
    ROUND(competitor_share, 2)   AS competitor_share
FROM hcp_marketing
WHERE week_index = (SELECT MAX(week_index) FROM hcp_marketing)
  AND rep_access_score > 0.6
  AND call_recency_days > 30
  AND response_flag = 1
  AND competitor_share > 0.5;

CREATE OR REPLACE VIEW vw_territory_ranking AS
SELECT
    territory,
    ROUND(SUM(rx_lift_weekly), 2)              AS total_lift,
    ROUND(SUM(total_marketing_cost), 2)         AS total_spend,
    ROUND(SUM(rx_lift_weekly) / SUM(total_marketing_cost), 4) AS lift_per_dollar,
    RANK() OVER (ORDER BY SUM(rx_lift_weekly) DESC) AS territory_rank
FROM hcp_marketing
GROUP BY territory;

SHOW FULL TABLES WHERE Table_type = 'VIEW';