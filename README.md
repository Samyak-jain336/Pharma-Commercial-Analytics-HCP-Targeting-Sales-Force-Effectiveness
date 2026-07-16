# Pharma Commercial Analytics - HCP Targeting & Sales Force Effectiveness

Pharma commercial analytics system built on a 150K-row synthetic HCP marketing dataset. MySQL for territory segmentation, quota tracking, and call planning queries. Power BI dashboard covering HCP tiering, rep performance, and multi-channel marketing ROI. Python used for data modelling and pipeline automation.

---

## Project Objective

A pharmaceutical company runs a multi-channel marketing campaign targeting ~25,000 doctors (HCPs) across the US over 26 weeks, spending ~$88 per doctor per week. This project answers four core business questions:

1. **Which doctors are worth targeting?** - A/B/C tiering using composite scoring
2. **Are reps hitting their numbers?** - Quota attainment tracking by rep and territory
3. **Which marketing channel gives the best ROI?** - Lift per dollar across 6 channels
4. **Who should reps call next week?** - Priority call list based on access, recency, and competitor share

---

## Tech Stack

| Layer | Technology |
|---|---|
| Data Enrichment | Python (Pandas, NumPy) |
| Database | MySQL 8.0 |
| Analytics | SQL (CTEs, Window Functions, Aggregations) |
| Visualisation | Power BI Desktop |
| Version Control | Git / GitHub |

---

## Dataset

**Source:** Synthetic HCP Omnichannel Marketing Dataset (Kaggle - danielmeiser)  
**Size:** 150,000 rows × 42 columns  
**Structure:** Panel data - one row per HCP per week (24,935 unique doctors × 26 weeks)

**Key column groups:**

- **HCP Profile** - `specialty`, `state`, `panel_size`, `baseline_rx_monthly`, `competitor_share`
- **Scoring** - `rep_access_score`, `digital_affinity_score`, `payer_restriction_score`
- **Marketing Activity** - `rep_calls`, `email_sends`, `email_opens`, `site_visits`, `programmatic_impressions`
- **Channel Costs** - `cost_rep`, `cost_email`, `cost_programmatic`, `cost_search`, `cost_social`, `cost_events`
- **Outcomes** - `rx_lift_weekly`, `response_flag`, `response_probability`, `engagement_score`
- **Engineered** - `territory`, `rep_id`, `weekly_quota_rx_lift` (added via Python)

---

## Repository Structure

```
Pharma-Commercial-Analytics/
│
├── Dashboard_Screenshots/
│   ├── 01_HCP_Segmentation.png
│   ├── 02_Rep_Performance.png
│   └── 03_Marketing_Mix_And_Territory_ROI.png
│
├── 01_create_table.sql          # MySQL table schema
├── 02_create_views.sql          # 5 analytical SQL views
├── addSQL.py                    # Loads CSV into MySQL
├── Pharma_Commercial_Analytics.pbix   # Power BI dashboard file
└── README.md
```

---

## SQL Analytical Views

Five views built on top of `hcp_marketing` table:

### 1. `vw_hcp_tiering` - HCP Segmentation
Tiers all 24,935 doctors into A/B/C using a composite score:

```
Composite Score = (baseline_rx_monthly × 0.3)
                + (rep_access_score × 100 × 0.3)
                + (competitor_share × 100 × 0.2)
                + (panel_size × 0.01 × 0.2)
```

Uses `NTILE(3)` window function to split into equal thirds. Tier A = highest composite score = highest priority target.

### 2. `vw_quota_attainment` - Rep Performance
Computes `AVG(rx_lift_weekly) / AVG(weekly_quota_rx_lift) × 100` per rep per territory. Labels reps as On Track (≥100%), At Risk (80–99%), or Underperforming (<80%) using `CASE WHEN`.

### 3. `vw_channel_roi` - Marketing Mix ROI
Computes `SUM(rx_lift_weekly) / SUM(cost_X)` for each of 6 marketing channels. Key finding: email generates 6.0 Rx lift per dollar vs 0.013 for rep visits — a 460x efficiency gap.

### 4. `vw_priority_call_list` - Next Week Call Targets
Filters the latest week's data for HCPs meeting all four criteria:
- `rep_access_score > 0.6` (accessible)
- `call_recency_days > 30` (not recently visited)
- `response_flag = 1` (historically responded)
- `competitor_share > 0.5` (competitor-dominated, high opportunity)

### 5. `vw_territory_ranking` - Territory Performance
Ranks all 5 territories by total Rx lift generated using `RANK()` window function. Southeast ranks #1 with 36,111 total lift units.

---

## Power BI Dashboard

### Page 1 - HCP Segmentation & Targeting
- **Scatter plot** - 3 tier bubbles (A/B/C) by average composite score vs average Rx lift
- **Filled map** - competitor share by US state (green → red gradient)
- **Bar chart** - HCP count by tier and specialty
- **KPI cards** - Total HCPs, Avg Competitor Share, Avg Composite Score
- **Slicers** - Filter by territory and specialty

![Page 1](Dashboard_Screenshots/01_HCP_Segmentation.png)

### Page 2 - Representatives' Performance & Call Planning
- **Quota attainment table** - all 23 rep-territory rows with conditional formatting
- **Priority call list table** - 23 high-opportunity HCPs with competitor share heat map
- **Bar chart** - quota status (On Track / At Risk / Underperforming) by territory
- **KPI cards** - Avg Attainment %, Reps On Track, Reps Underperforming

![Page 2](Dashboard_Screenshots/02_Rep_Performance.png)

### Page 3 - Marketing Mix & Territory ROI
- **Bar chart** - channel ROI ranking (Email far outperforms all other channels)
- **Territory ranking table** - ranked 1-5 with green/red conditional formatting
- **Line chart** - weekly Rx lift trend by territory over 26 weeks
- **KPI cards** - Best Channel ROI, Worst Channel ROI, Top Performing Territory

![Page 3](Dashboard_Screenshots/03_Marketing_Mix_And_Territory_ROI.png)

---

## Key Insights

- **Email marketing generates 460x better ROI than rep visits** on a cost-per-lift basis ($0.17 vs $77 per Rx lift unit), though rep visits serve a strategic relationship-building function not captured in short-term lift metrics
- **Southeast is the top-performing territory** with 36,111 total Rx lift units, while West ranks last at 17,682
- **4 of 19 reps are Underperforming** (below 80% quota attainment), concentrated in the Northeast and Southeast territories
- **Midwest/Ohio area shows highest competitor penetration** on the geographic map - the strongest opportunity for market share recovery
- **HCP composite score and actual Rx lift are weakly correlated** (r ≈ 0.01), indicating that targeting strategy based on access and panel size alone is insufficient - channel mix plays a significant role in driving lift

---

## How to Run


**1. Load into MySQL:**
```bash
pip install sqlalchemy pymysql
python addSQL.py
```

**2. Create analytical views:**
```sql
-- Run in MySQL CLI or Workbench
source 01_create_table.sql
source 02_create_views.sql
```

**3. Open dashboard:**
Open `Pharma_Commercial_Analytics.pbix` in Power BI Desktop. Update the MySQL connection to `127.0.0.1:3306` with your credentials.

---

## Skills Demonstrated

`MySQL` · `SQL Window Functions` · `CTEs` · `Python (Pandas)` · `Power BI` · `DAX` · `Data Modeling` · `Pharma Commercial Analytics` · `Sales Force Effectiveness`