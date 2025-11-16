# Postgres Citus POC

## Test Instructions

*Note*: I used 'password' as the database password. This isn't going anywhere important so I didn't mind.

On a machine that has docker, it should be as simple as running _./run-from-host.sh_ which will spin up a Docker container, run tests and then shut the container down.

## Test Results

|Task                                                   |1k Records  |20k Records   |
|-------------------------------------------------------|------------|--------------|
| Create Locations, 10 Years History                    | 07m 47s    | 02h 13m 15s  |
| Search for Location -1 Rows (DNE)                     | 00m 00.184s| 00h 00m 03.6s|
| Search for Location 12, Jan 2013-2017, 7am to 1pm     | 00m 00.188s| 00h 00m 03.1s|
| Make Index                                            | 01m 55s    | 00h 42m 56s |
| Search for Location 18, Jan 2014-2018, 10am to 10pm   | 00m 00.249s| 00h 00m 03s |

It's wild to see the index not help, but it's kinda of duplication in a column store...

| Measurement | Size |
| ----------- | ---- |
| 1k Table | 5.473 GB |
| 1k Index | 2.6 GB|
| 1k Table Row Count | 86,400,000 |
| 20k Table | 107 GB |
| 20k Index | 51 GB |
| 20k Table Row Count | 1,728,000,000 |

Man 51GB on space that doesn't help? Wild.