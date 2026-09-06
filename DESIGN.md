
By Andrea

Video overview: https://youtu.be/aD2RQTuncQ4

1. Scope
The primary objective of this project is to design, implement, and optimize a relational database using SQLite to store, manage, and analyze historical Formula 1 performance data. Formula 1 is a sport driven entirely by data, generating massive amounts of information every Grand Prix weekend. This database provides a structured foundation for querying driver statistics, race classifications, and high-frequency lap-time telemetry.

The scope of this database includes:

Circuits: Geographical, spatial, and naming details for racetracks that host Grand Prix events.

Constructors: Information regarding constructor teams and manufacturers, such as Ferrari, Red Bull, and McLaren.

Drivers: Profiles for competing drivers, including names, permanent car numbers, nationalities, and broadcast identification codes.

Races: Event metadata across historical seasons, covering full race weekend schedules including Free Practice, Qualifying, Sprints, and Main Races.

Results: Final race classification records per driver, capturing grid positions, final finishing spots, championship points, and retirement reasons.

Lap Times: High-density telemetry data recording lap numbers, running positions, and lap durations measured in milliseconds.

Result Logs: An audit log table that automatically tracks new race result insertions for system integrity.

The following items are explicitly outside the scope of this database:

Commercial and financial metrics, such as team budgets, ticket pricing, sponsorship agreements, or driver contracts, as these are confidential and irrelevant to pure sporting analytics.

Live real-time weather tracking and streaming telemetry, because this database is architected for historical batch data analysis rather than live stream processing.

2. Functional Requirements
A user interacting with this database should be able to perform a wide variety of analytical queries, such as:

Searching for specific drivers using their surname or official 3-letter broadcast code, such as VER, HAM, or LEC.

Retrieving a complete historical record of all Grand Prix winners across different championship seasons.

Identifying the fastest individual lap times ever recorded at a specific circuit to analyze historical pace progression.

Analyzing complex race scenarios, such as comeback victories where a driver won a Grand Prix after starting 10th or lower on the grid.

Generating an all-time driver leaderboard based on accumulated career championship points.

Automatically recording an audit log entry whenever a new race result is inserted into the system.

Beyond the scope of user capabilities:
Users cannot stream live in-race telemetry, alter team operational budgets, purchase tickets, or execute predictive machine learning models natively within the SQL engine itself.

3. Representation
Entities and Schema Structure
The database schema consists of seven tables structured to minimize data redundancy while maintaining relational integrity.

Table: circuits

Stores physical racetrack information.

circuitId: INTEGER Primary Key to uniquely identify each circuit.

circuitRef: TEXT unique alphanumeric reference code (NOT NULL).

name, location, country: TEXT attributes storing venue details (name is NOT NULL).

lat, lng, alt: REAL and INTEGER values storing spatial coordinates and elevation above sea level.

url: TEXT containing a reference link to Wikipedia.

Table: constructors

Stores constructor team profiles.

constructorId: INTEGER Primary Key uniquely identifying each team.

constructorRef: TEXT reference string (NOT NULL).

name, nationality: TEXT fields storing the team's official name and home country (both NOT NULL).

url: TEXT reference link.

Table: drivers

Stores individual driver biographical data.

driverId: INTEGER Primary Key for each driver.

driverRef: TEXT reference string (NOT NULL).

number, code: INTEGER and TEXT attributes storing permanent racing numbers and 3-letter codes (code is NOT NULL).

forename, surname: TEXT attributes storing full names (both NOT NULL).

dob: TEXT storing dates of birth formatted in ISO-8601 (YYYY-MM-DD).

nationality, url: TEXT fields for origin (NOT NULL) and reference links.

Table: races

Stores event scheduling details across F1 history.

raceId: INTEGER Primary Key.

year, round: INTEGER values representing the season and round order.

circuitId: INTEGER Foreign Key referencing circuits(circuitId).

name, date, time: TEXT attributes storing Grand Prix names and schedules.

Additional TEXT columns store dates and times for Free Practice, Qualifying, and Sprint sessions.

Table: results

A junction table linking drivers, constructors, and races for final classifications.

resultId: INTEGER Primary Key.

raceId, driverId, constructorId: INTEGER Foreign Keys connecting events, drivers, and teams (all NOT NULL).

grid: REAL attribute storing starting position.

position, positionOrder: INTEGER attributes recording final classification and finishing order.

positionText: TEXT attribute representing classification status text.

points: REAL attribute recording awarded championship points.

laps, time, milliseconds: INTEGER, TEXT, and REAL fields storing duration and completion metrics.

fastestLap, rank, fastestLapTime, fastestLapSpeed: Telemetry attributes capturing the driver's best lap and speed (stored as TEXT).

statusId: INTEGER indicator representing completion or retirement reason (NOT NULL).

Table: lap_times

A high-volume telemetry table tracking individual lap times.

raceId, driverId: INTEGER Foreign Keys connecting to the race and driver tables.

lap, position: INTEGER fields recording the lap number and running position.

time: TEXT storing formatted lap time.

milliseconds: REAL storing lap duration in raw milliseconds for comparison.

Table: result_logs

An audit table for system monitoring.

id: INTEGER Primary Key.

resultId: INTEGER identifying the modified result.

action: TEXT describing the operation, such as 'INSERTED'.

log_date: NUMERIC field defaulting to CURRENT_TIMESTAMP.

Data Types and Constraints
INTEGER was selected for surrogate primary keys, seasons, round numbers, lap numbers, and positions because these represent discrete whole quantities.

TEXT was chosen for names, nationalities, 3-letter codes, dates, speeds, and external URLs.

REAL was applied to geographic coordinates, grid positions, championship points, and milliseconds where precision floating-point storage is needed.

PRIMARY KEY and FOREIGN KEY constraints strictly enforce referential integrity across related tables.

NOT NULL constraints were applied to essential attributes like driver surnames, constructor names, status IDs, and circuit references to prevent incomplete records.

Relationships
The entity relationship diagram below illustrates how entities interact across the database:

![F1 Database ERD](diagram_f1_cs50.png)

Detailed relationship breakdown:

One circuit hosts 0 to many races (1:N).

One race produces 0 to many result entries and contains 0 to many lap time records (1:N).

One driver participates in 0 to many race results and logs 0 to many lap times (1:N).

One constructor enters cars into 0 to many race results (1:N).

Inserting a row into the results table automatically triggers 0 to 1 log entry in the result_logs table via a database trigger.

4. Optimizations
To ensure high performance and simplify complex data retrieval, several database optimizations were implemented:

Indexes:

Created a composite index lap_times_idx on lap_times(raceId, driverId). Because lap_times contains the largest number of rows, this index drops lookup time complexity from a full table scan O(N) to logarithmic search O(log N).

Created secondary indexes on results(driverId), drivers(surname), and races(year) to accelerate multi-table JOIN operations and text filtering.

Views:

The winner view joins results, races, and drivers to allow instant querying of Grand Prix winners without re-writing complex JOIN clauses.

The FASTEST_LAPS view aggregates lap times with race and driver profiles for telemetry analysis.

The comeback_wins view filters victories achieved after starting from 10th grid position or lower.

The best_drivers view aggregates career points per driver to construct an all-time leaderboard.

Triggers:

Designed the log_new_result trigger, which fires AFTER INSERT on the results table to automatically log audit details into result_logs.

5. Limitations
While this schema effectively handles historical F1 analysis, certain limitations exist:

Static Ingestion: The database relies on batch static data insertions and is not designed for real-time WebSocket data streaming during live race events.

Driver Contracts: Results are linked to a single constructor per race. If a driver switches teams mid-season, the database tracks this across separate race rows, but lacks a dedicated table for long-term contract tracking.

Machine Learning Pipelines: The database stores raw historical performance data. To build predictive AI and ML models, such as predicting race strategies or tire degradation, an external data pipeline in Python would be required to extract the data and perform feature engineering.
