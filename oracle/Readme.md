# Oracle IOT POC

Oracle free is limited to 12GB but I wanted to see how far I could get.

## Field Size

For purposes of finding things, we only plan to care about 'yyyymmdd', so what's the cheapest way to store it?

Apparently number is best, date the second best and char/varchar the worst. I'm surprised given I thought hour/min/sec in date would have more overhead.

_int-vs-char-vs-date.sql_ puts a million values of sysdate in each form.

|Field Type|Bytes|
|----------|-----|
| Characters | 16,777,216 |
| Date | 15,728,640 |
| Number |  12,582,912 |

## Test Stipulations

Tests were ran in an LXC container with 4 cores on an i7 3770 with a SATA SSD.

As noted above, the Oracle Database Free has a 12GB limit. It turns out I can comfortably store 5,000 locations with 10 years of history. 10,0000 locations could be stored but I ran out of space trying to make an index.

I did tests two ways, at 1,000 records (to compare to the others) and 5,0000 (to see the "worst case" I could make) records each.

* Single-Threaded makes each location one at a time stored into a single non-partitioned table. An index is later made on location, date, and hour of day.
* Multi-Threaded uses Oracle jobs to insert up to four locations at a time, into a table partitioned on location ID. A _local bitmap index_ is later made on hour of day.

## Test Instrucitons

On a machine that has docker, it should be as simple as running _./run-from-host.sh_ which will spin up a Docker container, run tests and then shut the container down.

## Test Results

|Task                                                   |1k Single-Threaded|1k Multi-Threaded|5k Single-Threaded|5k Multi-Threaded|
|-------------------------------------------------------|------------------|-----------------|------------------|-----------------|
| Create Locations, 10 Years History                    | 10m 20s          | 06m 00s         | 51m 38s          | 27m 18s         |
| Search for Location -1 Rows (DNE)                     | 00m 06s          | 00m 00.09s      | 00m 30s          | 00m 00.4s       |
| Search for Location 12, Jan 2013-2017, 7am to 1pm     | 00m 02s          | 00m 00.02s      | 00m 24s          | 00m 00.04s      |
| Make Index                                            | 02m 34s          | 00m 19s         | N/A              |                 |
| Search for Location 18, Jan 2014-2018, 10am to 10pm   | 00m 00.04s       | 00m .03s        | N/A              | 27m 18s         |

That size limitation is a buzzkill but at least we can see how much the usage of parallel jobs helped the insert and partitions helped the fetch!

## Object Sizes

|Object|Megabytes|
|------|---------|
|1k Single IOT Entries Table| 2,147.48 |
|1k Single IOT Entries Index| 2,421.16 |
|1k Partitioned IOT Entries Table| 3,031.5 |
|1k Partitioned IOT Entries Index| 262.21 |
|5k Single IOT Entries Table| 10,742.66 |
|5k Partitioned IOT Entries Table| 13,336.44 |

Supposedly the 5k tests both bombed out making indexes, but I find the 5k table size a little sus.