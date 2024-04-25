# Postgres IOT POC

I've been looking at revamping how we store data at work in Oracle, and came across this StackExchange post: https://dba.stackexchange.com/questions/188667/best-database-and-table-design-for-billions-of-rows-of-data

I decided to play around in Postgres at home (I would do it in Oracle, but the free version is limited to 12GB of data and this blows by that). I was curious what such a setup would look like and how much refactoring would be needed on my idea(s), if any.

## Problem Statement Copied From The Post

```
The information that I need to store (for now) is Location ID, Timestamp (Date and Time), Temperature and Electricity Usage.

About the amount of the data that needs to be stored, this is an approximation, but something along those lines:
20 000+ locations, 720 records per month (hourly measurements, approximately 720 hours per month), 120 months (for 10 years back) and many years into the future. Simple calculations yield the following results:

	20 000 locations x 720 records x 120 months (10 years back) = 1 728 000 000 records.

These are the past records, new records will be imported monthly, so that's approximately 20 000 x 720 = 14 400 000 new records per month.

The total locations will steadily grow as well.

On all of that data, the following operations will need to be executed:

1. Retrieve the data for a certain date AND time period: all records for a certain Location ID between the dates 01.01.2013 and 01.01.2017 and between 07:00 and 13:00.
2. Simple mathematical operations for a certain date AND time range, e.g. MIN, MAX and AVG temperature and electricity usage for a certain Location ID for 5 years between 07:00 and 13:00.
```

## Instructions

*Note*: I used 'password' as the database password. This isn't going anywhere important so I didn't mind.

Spin up a server and the "client" containers.

```
docker-compose up
```

Then pop into the "client" container:

```
docker container exec -it postgres-iot-poc_postgres-client_1 /bin/bash
```

And run:

```
bash /code/run.sh
```

## Alternative Approaches

I originally wanted to compare a giant table versus a partitioned table, but there is more overhead in Postgres with partitions than I expected (Oracle seemed to "hide" it to an extent).

I left the script in at 01b-seed-partition.sql but as you can see in comments, I gave up after I what I think was spending 8 hours making underlying tables (which makes no sense I know, I just haven't figured out where I went wrong yet).

## Results

Script was run in a Proxmox container with 4 CPUs, 8GB of RAM and a 500GB hard drive section. Host is a i7-3770 CPU and a 2TB mechanical hard drive.

| Activity | Time |
| -------- | ---- |
| Insert 10 years of hourly data for 20,000 locations | 05h 45m 40s |
| Select : Location that doesn't exist, between 1/1/13 and 1/1/17, hours between 7am and 1pm | 01h 06m 41s  |
| Select : Location that does exist, between 1/1/13 and 1/1/17, hours between 7am and 1pm | 00h 40m 26s |
| Make Index on Location, Hour, Date | 01h 19m 34s |
| Select : Location that does exist, between 1/1/14 and 1/1/18, hours between 10am and 10pm | 00h 00m 01s |
| Select : Location that does exist, between 1/1/14 and 1/1/18, hours between 10am and 10pm | 00h 00m 01s |

I think a form of caching helped the second fetch, but still wasn't good. More details in _results.txt_.

**(Overly Simplistic) Conclusion:**  Indexes are nice.

| Measurement | Size |
| ----------- | ---- |
| Table | 197GB |
| Index | 51GB |
| Table Row Count | 1,728,000,000 |

## Possible Improvements

Had interest in one point about exploring BRIN indexes and then maybe columnar with [Cytus](https://www.citusdata.com/), but interest waned on the former and the latter didn't seem applicable in the end. This is totally "transactional" data IMO.
