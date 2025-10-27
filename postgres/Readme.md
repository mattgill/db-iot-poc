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
| Create Locations, 10 Years History                    | 07m 47s    | 02h 47m 57s |
| Search for Location -1 Rows (DNE)                     | 00m 19s    | 29m 14s     |
| Search for Location 12, Jan 2013-2017, 7am to 1pm     | 00m 01.5s  | 05m 54s     |
| Make Index                                            | 01m 11s    | 44m 39s     |
| Search for Location 18, Jan 2014-2018, 10am to 10pm   | 00m 00s    | 00m 00s     |

You can see the object cache help but it doesn't make subsequent queries instant at 20k in size.

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
