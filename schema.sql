-- Represents race circuits and tracks
CREATE TABLE "circuits"(
    "circuitId" INTEGER PRIMARY KEY,
    circuitRef TEXT NOT NULL,
    name TEXT NOT NULL,
    location TEXT,
    country TEXT,
    lat REAL,
    lng REAL,
    alt INTEGER,
    url TEXT
);
-- Represents F1 constructors and teams
CREATE TABLE "constructors"(
    constructorId INTEGER PRIMARY KEY,
    constructorRef TEXT NOT NULL,
    name TEXT NOT NULL,
    nationality TEXT NOT NULL,
    url TEXT
);
-- Represents F1 drivers
CREATE TABLE "drivers"(
    driverId INTEGER PRIMARY KEY,
    driverRef TEXT NOT NULL,
    number INTEGER,
    code TEXT NOT NULL,
    forename TEXT NOT NULL,
    surname TEXT NOT NULL,
    dob TEXT,
    nationality TEXT NOT NULL,
    url TEXT
);
-- Represents detailed lap times and telemetry
CREATE TABLE "lap_times"(
    "raceId" INTEGER,
    driverId INTEGER,
    lap INTEGER,
    position INTEGER,
    time TEXT,
    milliseconds REAL,
    FOREIGN KEY ("raceId") REFERENCES "races"("raceId"),
    FOREIGN KEY ("driverId") REFERENCES "drivers"("driverId")
);
-- Represents race events
CREATE TABLE "races"(
    raceId INTEGER PRIMARY KEY,
    year INTEGER,
    round INTEGER,
    circuitId INTEGER,
    name text,
    date TEXT,
    time TEXT,
    url TEXT,
    fp1_date TEXT,
    fp1_time TEXT,
    fp2_date TEXT,
    fp2_time TEXT,
    fp3_date TEXT,
    fp3_time TEXT,
    quali_date TEXT,
    quali_time TEXT,
    sprint_date TEXT,
    sprint_time TEXT,
    FOREIGN KEY ("circuitId") REFERENCES "circuits"("circuitId")

);
-- Represents race results for drivers and teams
CREATE TABLE "results"(
    resultId INTEGER PRIMARY KEY,
    raceId INTEGER NOT NULL,
    driverId INTEGER NOT NULL,
    constructorId INTEGER NOT NULL,
    number INTEGER,
    grid REAL,
    position INTEGER,
    positionText TEXT,
    positionOrder INTEGER,
    points REAL,
    laps INTEGER,
    time TEXT,
    milliseconds REAL,
    fastestLap INTEGER,
    rank INTEGER,
    fastestLapTime TEXT,
    fastestLapSpeed TEXT,
    statusId INTEGER NOT NULL,
    FOREIGN KEY ("raceId") REFERENCES "races"("raceId"),
    FOREIGN KEY ("driverId") REFERENCES "drivers"("driverId"),
    FOREIGN KEY ("constructorId") REFERENCES "constructors"("constructorId")
);

-- Represents an audit log for newly added race results
CREATE TABLE "result_logs" (
    "id" INTEGER PRIMARY KEY,
    "resultId" INTEGER,
    "action" TEXT,
    "log_date" NUMERIC DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX "lap_times_idx" ON "lap_times"("raceId","driverId");
CREATE INDEX "drivers_result_idx" ON "results"("driverId");
CREATE INDEX "drivers_surname_idx" ON "drivers"("surname");
CREATE INDEX "races_year_idx" ON "races"("year");

CREATE VIEW "winner" AS
SELECT "races"."year", "drivers"."forename", "drivers"."surname", "results"."points"
FROM "results"
JOIN "races" ON "races"."raceId" = "results"."raceId"
JOIN "drivers" ON "results"."driverId" = "drivers"."driverId"
WHERE "results"."position" = 1;

CREATE VIEW "FASTEST_LAPS" AS
SELECT "lap_times"."milliseconds", "races"."year", "drivers"."forename", "drivers"."surname", "races"."circuitId"
FROM "lap_times"
JOIN "races" ON "races"."raceId" = "lap_times"."raceId"
JOIN "drivers" ON "lap_times"."driverId" = "drivers"."driverId";

CREATE VIEW "comeback_wins" AS
SELECT "results"."position", "results"."grid", "races"."year", "drivers"."forename", "drivers"."surname", "results"."points"
FROM "results"
JOIN "races" ON "races"."raceId" = "results"."raceId"
JOIN "drivers" ON "results"."driverId" = "drivers"."driverId"
WHERE "results"."position" = 1 AND "results"."grid" >= 10;

CREATE VIEW "best_drivers" AS
SELECT "drivers"."forename", "drivers"."surname", SUM("results"."points") AS "total_points"
FROM "results"
JOIN "drivers" ON "results"."driverId" = "drivers"."driverId"
GROUP BY "drivers"."driverId"
ORDER BY "total_points" DESC;

-- TRIGGER: Automatically logs whenever a new result is inserted
CREATE TRIGGER "log_new_result"
AFTER INSERT ON "results"
BEGIN
    INSERT INTO "result_logs" ("resultId", "action")
    VALUES (NEW."resultId", 'INSERTED');
END;
