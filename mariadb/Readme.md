# MariaDB IOT POC

This is a MariaDB version of my postgres-iot-poc repo.

Once I realized PostgreSQL didn't have the concept of built-in jobs/events nor "background processes" (at least not without plugins), going to try MariaDB events just to see what I could do with insert speeds.

## Test Stipulations

Tests were ran in an LXC container with 4 cores on an i7 3770 with a SATA SSD.

As noted above, the Oracle Database Free has a 12GB limit. It turns out I can comfortably store 5,000 locations with 10 years of history. 10,0000 locations could be stored but I ran out of space trying to make an index.

I did a test at 20k locations to compare with Postgres, and then I did three tests with 1k records:

* For Loop - Location by location make its history
* One Shot - Stage a temp table of markers, then use a sequence table and a cross join to make a giant insert into select.
* Events - Insert up to 4 locations at a time via MySQL events (seems to be a parallel to what I'm used to with Oracle jobs)

## Test Instrucitons

On a machine that has docker, it should be as simple as running _./run-from-host.sh_ which will spin up a Docker container, run tests and then shut the container down.

## Test Results

|Task                                                   |1k For Loop       |1k Events        |1k One Shot       |20k For Loop     |
|-------------------------------------------------------|------------------|-----------------|------------------|-----------------|
| Create Locations, 10 Years History                    | 09m 26s          | 08m 16s         | 07m 58s          | 03h 17m 34s     |
| Search for Location -1 Rows (DNE)                     | 00m 50s          | 01m 44s         | 01m 03s          | 00h 18m 18s     |
| Search for Location 12, Jan 2013-2017, 7am to 1pm     | 00m 59s          | 01m 51s         | 01m 15s          | 00h 19m 20s     |
| Make Index                                            | 02m 55s          | 03m 46s         | 03m 39s          | 01h 57m 16s     |
| Search for Location 18, Jan 2014-2018, 10am to 10pm   | 00m 39s          | 00m 39s         | 00m 44s          | 00h 00m 39s     |

The events didn't seem to help as much as they did in Oracle And the indexes didn't seem to help much, until you compare it to scanning the 20k records without it!

## Object Sizes

I forgot to print sizes.