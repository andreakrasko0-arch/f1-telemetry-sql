# f1-telemetry-sql
Relational database design, schema modeling, and SQL queries analyzing historical Formula 1 race data

# Formula 1 Relational Database & Historical Analytics

A normalized relational database engineered in SQLite to store, manage, and query historical Formula 1 performance data, classifications, and high-frequency lap-time telemetry.

Designed as the capstone database project for Harvard's **CS50 SQL**.

---

## Database Architecture

The schema spans 7 relational tables optimized for historical batch queries and telemetry lookups:

* **Core Entities:** `circuits`, `constructors`, `drivers`, `races`
* **Junction & Telemetry:** 
  * `results` — Links drivers, constructors, and race classifications (grid, finishes, points, status).
  * `lap_times` — High-density lap data (lap numbers, track positions, millisecond durations).
* **Audit & Integrity:** `result_logs` — Automated tracking via database triggers.

For the full specification, trade-offs, and ER diagram notes, see [`DESIGN.md`](./DESIGN.md).

---

## Schema Optimizations

* **Composite Indexing:** Indexed `lap_times(raceId, driverId)` to reduce lookup complexity from a full table scan $O(N)$ down to $O(\log N)$ on the largest dataset.
* **Foreign Key & Lookup Indexes:** Targeted secondary indexes on `results(driverId)`, `drivers(surname)`, and `races(year)` to speed up multi-table `JOIN` operations.
* **Database Triggers:** Automated `AFTER INSERT` trigger (`log_new_result`) writing directly to `result_logs`.

---

## Pre-Built Analytical Views

The database includes dedicated SQL views to simplify reporting:

* `winner` — Instant lookup of Grand Prix winners without repetitive multi-table joins.
* `FASTEST_LAPS` — Telemetry aggregates combining race data, driver records, and lap pace.
* `comeback_wins` — Filters historical victories achieved from P10 or lower on the starting grid.
* `best_drivers` — Career point aggregates generating an all-time championship leaderboard.

---

## Repository Structure

* `schema.sql` — DDL statements for table definitions, data constraints, indexes, and triggers.
* `queries.sql` — Analytical SQL queries demonstrating filtering, multi-table `JOIN`s, and aggregations.
* `DESIGN.md` — Comprehensive design specification, schema breakdown, and architectural constraints.

---

## Tech Stack

* **Engine:** SQLite 3
* **Language:** SQL
* **Techniques:** Schema Normalization, Composite Indexes, SQL Views, Database Triggers, Foreign Key Constraints
