"""
ETL Script: Load Melaka PRN CSVs into MySQL
--------------------------------------------
Requirements:
    pip install mysql-connector-python

Usage:
    python 03_load_data.py

Edit the DB_CONFIG section below with your MySQL credentials.
"""

import csv
import mysql.connector
from mysql.connector import Error
from datetime import datetime

# ── CONFIGURE YOUR MYSQL CONNECTION HERE ─────────────────────
DB_CONFIG = {
    "host":     "localhost",
    "port":     3306,
    "user":     "root",          # change if different
    "password": "Harith050604", # change to your MySQL password
    "database": "prn_melaka",
    "charset":  "utf8mb4",
}
# ─────────────────────────────────────────────────────────────

DATA_DIR = r"C:\Users\Usera\Desktop\intern\PRN MELAKA"

FILES = {
    "election_results": f"{DATA_DIR}\\headline_ballots.csv",
    "voter_roll_2021":  f"{DATA_DIR}\\mlk_se15_2021.csv",
    "voter_roll_2026":  f"{DATA_DIR}\\mlk_se16_2026.csv",
}

BATCH_SIZE = 5000


def parse_int(val, default=None):
    try:
        return int(val)
    except (ValueError, TypeError):
        return default


def parse_float(val, default=None):
    try:
        return float(val)
    except (ValueError, TypeError):
        return default


def parse_date(val):
    try:
        return datetime.strptime(val, "%Y-%m-%d").date()
    except (ValueError, TypeError):
        return None


def load_election_results(conn, path):
    cursor = conn.cursor()
    cursor.execute("TRUNCATE TABLE election_results")
    conn.commit()

    sql = """
        INSERT INTO election_results
            (election_date, election, state, seat, ballot_order, candidate_uid,
             name_on_ballot, candidate_name, sex, ethnicity, age,
             party_on_ballot, party_uid, party, coalition_uid, coalition,
             votes, votes_perc, rank_pos, result)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
    """

    batch, total = [], 0
    with open(path, encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row["state"] != "Melaka":
                continue
            batch.append((
                parse_date(row["date"]),
                row["election"],
                row["state"],
                row["seat"],
                parse_int(row["ballot_order"]),
                row["candidate_uid"],
                row["name_on_ballot"],
                row["name"],
                row["sex"][:1] if row["sex"] else None,
                row["ethnicity"],
                parse_int(row["age"]),
                row["party_on_ballot"],
                row["party_uid"],
                row["party"],
                row["coalition_uid"],
                row["coalition"],
                parse_int(row["votes"]),
                parse_float(row["votes_perc"]),
                parse_int(row["rank"]),
                row["result"],
            ))
            if len(batch) >= BATCH_SIZE:
                cursor.executemany(sql, batch)
                conn.commit()
                total += len(batch)
                batch = []
                print(f"  election_results: {total:,} rows inserted...", end="\r")

    if batch:
        cursor.executemany(sql, batch)
        conn.commit()
        total += len(batch)

    print(f"  election_results: {total:,} rows inserted.           ")
    cursor.close()


def load_voter_roll(conn, table, path, year):
    cursor = conn.cursor()
    cursor.execute(f"TRUNCATE TABLE {table}")
    conn.commit()

    sql = f"""
        INSERT INTO {table}
            (uid, birth_year, sex, ethnicity, ethnicity_modelled,
             state, parlimen, dun, dm_vr, dm, pm, saluran)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
    """

    batch, total = [], 0
    with open(path, encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            batch.append((
                row["uid"],
                parse_int(row["birth_year"]),
                row["sex"],
                row["ethnicity"],
                parse_int(row["ethnicity_is_modelled"], 0),
                row["state"],
                row["parlimen"],
                row["dun"],
                row["dm_vr"],
                row["dm"],
                row["pm"],
                parse_int(row["saluran"]),
            ))
            if len(batch) >= BATCH_SIZE:
                cursor.executemany(sql, batch)
                conn.commit()
                total += len(batch)
                batch = []
                print(f"  {table}: {total:,} rows inserted...", end="\r")

    if batch:
        cursor.executemany(sql, batch)
        conn.commit()
        total += len(batch)

    print(f"  {table}: {total:,} rows inserted.           ")
    cursor.close()


def main():
    print("Connecting to MySQL...")
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        print(f"  Connected to {DB_CONFIG['host']}:{DB_CONFIG['port']} / {DB_CONFIG['database']}\n")
    except Error as e:
        print(f"  ERROR: {e}")
        print("  Check DB_CONFIG credentials and make sure the database exists (run 01_schema.sql first).")
        return

    print("Loading election_results (Melaka only)...")
    load_election_results(conn, FILES["election_results"])

    print("Loading voter_roll_2021 (495k rows, may take ~1 min)...")
    load_voter_roll(conn, "voter_roll_2021", FILES["voter_roll_2021"], 2021)

    print("Loading voter_roll_2026 (687k rows, may take ~2 min)...")
    load_voter_roll(conn, "voter_roll_2026", FILES["voter_roll_2026"], 2026)

    conn.close()
    print("\nDone! All tables loaded.")
    print("Next: run 02_views.sql in MySQL Workbench, then connect Power BI.")


if __name__ == "__main__":
    main()
