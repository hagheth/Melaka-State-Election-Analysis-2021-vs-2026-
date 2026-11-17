# Melaka State Election Analysis — SE-15 (2021) vs SE-16 (2026)

A data analysis project comparing the 15th and 16th Melaka State Elections (PRN), covering results, vote swing, and voter demographics across all 28 DUN seats.

---

## Power BI Report — 3 Pages

### Page 1 · Results Overview
- Seat count cards: BN 21 · PH 4 · PN 3
- Coalition slicer (2026 Winner filter)
- Clustered bar chart: Seats won by coalition (2021 vs 2026)
- Table: All 28 DUN results with winner, majority, and majority change

### Page 2 · Vote Swing Analysis
- Diverging bar chart: Coalition vote swing (BN / PH / PN) per DUN
- Table: Seats that changed hands (3 flipped seats)
- DUN slicer for seat-level filtering

### Page 3 · Electorate Demographics
- Cards: Total registered voters 2021 (495,195) and 2026 (687,697)
- Bar chart: New young voters (18–24) by DUN — 2026 Top 10
- Stacked bar: Registered voters by ethnicity per DUN — Top 10

---

## Key Findings

- **BN** retained all 21 seats from 2021; majority sizes grew significantly
- **PN** gained 2 seats (N.11 Sungai Udang, N.13 Paya Rumput) — both flipped from BN, with BN vote share dropping ~40%
- **PH** lost 1 seat (N.17 Bukit Katil) to PN; retained 4 seats
- **3 seats changed hands** in total; all swings driven by BERSATU leaving PN and contesting as BEBAS
- Voter roll grew by **192,502 (+38.9%)** between 2021 and 2026, largely due to Undi18 automatic registration
- N.13 Paya Rumput has the highest concentration of new young voters (18–24) at 9,500

---

## Files

| File | Description |
|------|-------------|
| `Melaka_State_Election.pbix` | Power BI report (3 pages) |
| `headline_ballots.csv` | Candidate-level results, all Malaysian elections 1955–2026 |
| `mlk_se15_2021.csv` | Melaka voter roll 2021 — 495,195 voters |
| `mlk_se16_2026.csv` | Melaka voter roll 2026 — 687,697 voters |
| `peninsular_2018_dun.geojson` | DUN boundary map (Peninsular Malaysia, 2018 delimitation) |
| `sql/01_schema.sql` | MySQL database schema |
| `sql/02_views.sql` | Views: v_seat_results, v_swing, v_voter_demog |
| `sql/03_load_data.py` | Python ETL script to load CSVs into MySQL |

---

## Database

Built on **MySQL** (`prn_melaka` database):
- `election_results` — candidate-level results, Melaka only
- `voter_roll_2021` — full Melaka voter roll for SE-15
- `voter_roll_2026` — full Melaka voter roll for SE-16

Three views power the Power BI report directly via MySQL connector.

---

## Tools Used
- MySQL 8 · Power BI Desktop · Python 3 · Git
