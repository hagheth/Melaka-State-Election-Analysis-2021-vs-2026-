-- ============================================================
--  PRN MELAKA Database Schema
--  Covers: SE-15 (2021) and SE-16 (2026) Melaka State Elections
-- ============================================================

CREATE DATABASE IF NOT EXISTS prn_melaka
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE prn_melaka;

-- ------------------------------------------------------------
-- 1. Election results (candidate-level, Melaka all elections)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS election_results (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    election_date   DATE,
    election        VARCHAR(20),        -- e.g. SE-15, SE-16, BY-ELECTION
    state           VARCHAR(50),
    seat            VARCHAR(50),        -- DUN e.g. N.01 Kuala Linggi
    ballot_order    TINYINT,
    candidate_uid   VARCHAR(10),
    name_on_ballot  VARCHAR(150),
    candidate_name  VARCHAR(150),
    sex             CHAR(1),            -- M / F
    ethnicity       VARCHAR(30),
    age             TINYINT,
    party_on_ballot VARCHAR(30),
    party_uid       VARCHAR(20),
    party           VARCHAR(30),
    coalition_uid   VARCHAR(20),
    coalition       VARCHAR(20),
    votes           INT,
    votes_perc      DECIMAL(8,4),
    rank_pos        TINYINT,
    result          VARCHAR(30),        -- won / lost / lost_deposit / won_uncontested
    INDEX idx_election  (election),
    INDEX idx_seat      (seat),
    INDEX idx_coalition (coalition),
    INDEX idx_result    (result)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 2. Voter roll 2021 (SE-15)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS voter_roll_2021 (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    uid                 VARCHAR(20),
    birth_year          SMALLINT,
    sex                 VARCHAR(10),
    ethnicity           VARCHAR(30),
    ethnicity_modelled  TINYINT(1),
    state               VARCHAR(50),
    parlimen            VARCHAR(50),
    dun                 VARCHAR(50),        -- DUN seat
    dm_vr               VARCHAR(80),
    dm                  VARCHAR(80),
    pm                  VARCHAR(150),       -- polling centre
    saluran             TINYINT,
    INDEX idx_dun       (dun),
    INDEX idx_ethnicity (ethnicity),
    INDEX idx_sex       (sex),
    INDEX idx_birth     (birth_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 3. Voter roll 2026 (SE-16)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS voter_roll_2026 (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    uid                 VARCHAR(20),
    birth_year          SMALLINT,
    sex                 VARCHAR(10),
    ethnicity           VARCHAR(30),
    ethnicity_modelled  TINYINT(1),
    state               VARCHAR(50),
    parlimen            VARCHAR(50),
    dun                 VARCHAR(50),
    dm_vr               VARCHAR(80),
    dm                  VARCHAR(80),
    pm                  VARCHAR(150),
    saluran             TINYINT,
    INDEX idx_dun       (dun),
    INDEX idx_ethnicity (ethnicity),
    INDEX idx_sex       (sex),
    INDEX idx_birth     (birth_year)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
