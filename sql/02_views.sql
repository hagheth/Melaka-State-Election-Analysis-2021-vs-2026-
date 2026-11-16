USE prn_melaka;

-- ============================================================
--  VIEWS for Power BI
-- ============================================================


DROP VIEW IF EXISTS v_seat_results;

CREATE VIEW v_seat_results AS
SELECT
    base.election,
    base.election_date,
    base.seat,
    base.winner_name,
    base.winner_party,
    base.winner_coalition,
    base.winner_votes,
    base.total_votes,
    base.winner_votes - runner.runner_votes   AS majority,
    base.pct_BN,
    base.pct_PH,
    base.pct_PN,
    base.pct_BEBAS,
    base.num_candidates
FROM (
    SELECT
        r.election,
        r.election_date,
        r.seat,
        MAX(CASE WHEN r.result='won' THEN r.candidate_name END) AS winner_name,
        MAX(CASE WHEN r.result='won' THEN r.party          END) AS winner_party,
        MAX(CASE WHEN r.result='won' THEN r.coalition      END) AS winner_coalition,
        MAX(CASE WHEN r.result='won' THEN r.votes          END) AS winner_votes,
        SUM(r.votes) AS total_votes,
        ROUND(SUM(CASE WHEN r.coalition='BN'    THEN r.votes ELSE 0 END)/NULLIF(SUM(r.votes),0)*100,2) AS pct_BN,
        ROUND(SUM(CASE WHEN r.coalition='PH'    THEN r.votes ELSE 0 END)/NULLIF(SUM(r.votes),0)*100,2) AS pct_PH,
        ROUND(SUM(CASE WHEN r.coalition='PN'    THEN r.votes ELSE 0 END)/NULLIF(SUM(r.votes),0)*100,2) AS pct_PN,
        ROUND(SUM(CASE WHEN r.coalition='ALONE' THEN r.votes ELSE 0 END)/NULLIF(SUM(r.votes),0)*100,2) AS pct_BEBAS,
        COUNT(*) AS num_candidates
    FROM election_results r
    WHERE r.state = 'Melaka'
    GROUP BY r.election, r.election_date, r.seat
) base
JOIN (
    SELECT election, seat, MAX(votes) AS runner_votes
    FROM election_results
    WHERE state = 'Melaka'
      AND result NOT IN ('won', 'won_uncontested')
    GROUP BY election, seat
) runner ON runner.election = base.election AND runner.seat = base.seat;

-- ------------------------------------------------------------
-- v_swing: compare 2021 vs 2026 per seat (for swing chart)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_swing AS
SELECT
    s21.seat,
    s21.winner_coalition                        AS winner_2021,
    s26.winner_coalition                        AS winner_2026,
    CASE WHEN s21.winner_coalition != s26.winner_coalition THEN 1 ELSE 0 END AS flipped,
    s21.majority                                AS majority_2021,
    s26.majority                                AS majority_2026,
    s26.majority - s21.majority                 AS majority_change,
    s21.total_votes                             AS total_votes_2021,
    s26.total_votes                             AS total_votes_2026,
    s26.total_votes - s21.total_votes           AS voter_growth,
    s21.pct_BN  AS bn_2021,  s26.pct_BN  AS bn_2026,  s26.pct_BN  - s21.pct_BN  AS bn_swing,
    s21.pct_PH  AS ph_2021,  s26.pct_PH  AS ph_2026,  s26.pct_PH  - s21.pct_PH  AS ph_swing,
    s21.pct_PN  AS pn_2021,  s26.pct_PN  AS pn_2026,  s26.pct_PN  - s21.pct_PN  AS pn_swing
FROM v_seat_results s21
JOIN v_seat_results s26 ON s21.seat = s26.seat
WHERE s21.election = 'SE-15' AND s26.election = 'SE-16';

-- ------------------------------------------------------------
-- v_voter_demog: voter roll by DUN, election year, ethnicity, sex, age group
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_voter_demog AS
SELECT
    '2021'          AS election_year,
    dun,
    ethnicity,
    sex,
    CASE
        WHEN (2021 - birth_year) BETWEEN 18 AND 24 THEN '18-24'
        WHEN (2021 - birth_year) BETWEEN 25 AND 34 THEN '25-34'
        WHEN (2021 - birth_year) BETWEEN 35 AND 49 THEN '35-49'
        WHEN (2021 - birth_year) BETWEEN 50 AND 64 THEN '50-64'
        ELSE '65+'
    END             AS age_group,
    COUNT(*)        AS voters
FROM voter_roll_2021
GROUP BY election_year, dun, ethnicity, sex, age_group

UNION ALL

SELECT
    '2026'          AS election_year,
    dun,
    ethnicity,
    sex,
    CASE
        WHEN (2026 - birth_year) BETWEEN 18 AND 24 THEN '18-24'
        WHEN (2026 - birth_year) BETWEEN 25 AND 34 THEN '25-34'
        WHEN (2026 - birth_year) BETWEEN 35 AND 49 THEN '35-49'
        WHEN (2026 - birth_year) BETWEEN 50 AND 64 THEN '50-64'
        ELSE '65+'
    END             AS age_group,
    COUNT(*)        AS voters
FROM voter_roll_2026
GROUP BY election_year, dun, ethnicity, sex, age_group;
