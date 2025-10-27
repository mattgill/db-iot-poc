# Postgres Timescale POC

## Test Instructions

*Note*: I used 'password' as the database password. This isn't going anywhere important so I didn't mind.

On a machine that has docker, it should be as simple as running _./run-from-host.sh_ which will spin up a Docker container, run tests and then shut the container down.

## Test Results

|Task                                                   |1k Records  |20k Records  |
|-------------------------------------------------------|------------|-------------|
| Create Locations, 10 Years History                    | 00h 17m 58s| 08h 45m 33s |
| Search for Location -1 Rows (DNE)                     | 00h 00m 07s| 00h 00m 51s |
| Search for Location 12, Jan 2013-2017, 7am to 1pm     | 00h 00m 2s | 00h 00m 43s |
| Make Index                                            | 00h 02m 55s| 01h 08m 09s |
| Search for Location 18, Jan 2014-2018, 10am to 10pm   | 00h 00m 01s| 00h 00m 01s |



You can see the object cache helping out at a small enough table size but at a 20k size the index comes through with flying colors.

*Despite efforts I couldn't get the size of the indexes.*

| Measurement | Size |
| ----------- | ---- |
| 1k Table | 13GB |
| 1k Index | |
| 1k Table Row Count | 86,400,000 |
| 20k Table | 257GB |
| 20k Index | |
| 20k Table Row Count | 1,728,000,000 |

It took up the most space and had the longest insert times by miles, and Citus still ate it for breakfast when it came to search for things.
