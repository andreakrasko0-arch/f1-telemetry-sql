-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

-- Find specific driver details by surname or code
SELECT "driverId", "driverRef", "number", "code", "forename", "surname", "dob", "nationality", "url" FROM "drivers"
WHERE "surname" = 'Verstappen' OR "code" = 'VER';

-- List all Grand Prix winners with year and points scored
SELECT "races"."year", "drivers"."forename", "drivers"."surname", "results"."points"
FROM "results"
JOIN "races" ON "races"."raceId" = "results"."raceId"
JOIN "drivers" ON "results"."driverId" = "drivers"."driverId"
WHERE "results"."position" = 1;

-- Find the 5 fastest lap times recorded on circuit 1
SELECT "lap_times"."milliseconds", "races"."year", "drivers"."forename", "drivers"."surname"
FROM "lap_times"
JOIN "races" ON "races"."raceId" = "lap_times"."raceId"
JOIN "drivers" ON "lap_times"."driverId" = "drivers"."driverId"
WHERE "races"."circuitId" = 1
ORDER BY "lap_times"."milliseconds" ASC LIMIT 5;

-- Find race wins where the driver started from 10th position or lower on the grid
SELECT "results"."position", "results"."grid", "races"."year", "drivers"."forename", "drivers"."surname", "results"."points"
FROM "results"
JOIN "races" ON "races"."raceId" = "results"."raceId"
JOIN "drivers" ON "results"."driverId" = "drivers"."driverId"
WHERE "results"."position" = 1 AND "results"."grid" >= 10;

-- Rank drivers based on total career points scored
SELECT "drivers"."forename", "drivers"."surname", SUM("results"."points") AS "total_points"
FROM "results"
JOIN "drivers" ON "results"."driverId" = "drivers"."driverId"
GROUP BY "drivers"."driverId"
ORDER BY "total_points" DESC
LIMIT 10;
