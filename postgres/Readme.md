# Postgres IOT POC

I started with Postgres first, given I was aware with Oracle's Free limitations.


I originally wanted to compare a giant table versus a partitioned table, but there is more overhead in Postgres with partitions than I expected (Oracle seemed to "hide" it to an extent).

I left the script in at 01b-seed-partition.sql but as you can see in comments, I gave up after I what I think was spending 8 hours making underlying tables (which makes no sense I know, I just haven't figured out where I went wrong yet).

## Test Instructions

*Note*: I used 'password' as the database password. This isn't going anywhere important so I didn't mind.

On a machine that has docker, it should be as simple as running _./run-from-host.sh_ which will spin up a Docker container, run tests and then shut the container down.

## Test Results

|Task                                                   |1k Records  |20k Records  |
|-------------------------------------------------------|------------|-------------|
| Create Locations, 10 Years History                    | N/A        | N/A         |
| Search for Location -1 Rows (DNE)                     | 00m 28s    | 16m 20s     |
| Search for Location 12, Jan 2013-2017, 7am to 1pm     | 00m 02s    | 04m 29s     |
| Make Index                                            | 00m 59s    | 28m 22s     |
| Search for Location 18, Jan 2014-2018, 10am to 10pm   | 00m 00s    | 00m 00s     |

I neglected to print the location creation time to screen.

You can see the object cache helping out at a small enough table size but at a 20k size the index comes through with flying colors.

| Measurement | Size |
| ----------- | ---- |
| 1k Table | 10.1 GB |
| 1k Index | 2.6 GB|
| 1k Table Row Count | 86,400,000 |
| 20k Table | 197 GB |
| 20k Index | 51 GB |
| 20k Table Row Count | 1,728,000,000 |

## Possible Improvements?

Had interest in one point about exploring BRIN indexes and then maybe columnar with [Cytus](https://www.citusdata.com/), but interest waned on the former and the latter didn't seem applicable in the end. This is totally "transactional" data IMO.
