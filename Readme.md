# Database IOT POC

I've been looking at revamping how we store data at work in Oracle, and came across this StackExchange post: https://dba.stackexchange.com/questions/188667/best-database-and-table-design-for-billions-of-rows-of-data

I decided to play around in Postgres at home (I would do it in Oracle, but the free version is limited to 12GB of data and this blows by that). I was curious what such a setup would look like and how much refactoring would be needed on my idea(s), if any.

I then added MariaDB to the mix and tried to see how far I can go in Oracle.

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

## Observations

Oracle showcases its prowress with threads (jobs) as far as insert speeds go. We couldn't see the index payoff at large scales due to the DB limitations.

Postgres and MariaDB were close on first search speeds, but Postgres seemed to make use of some kind of object caching to speed up subsequent reads. It's index prowress by comparison was exceptional, with sub-second response times (I don't know why MariaDB liked 39 seconds every time regardless of size).

While object sizes were recorded for Maria, Postgres took over 2x the size of Oracle to store 1k records, though admittedly the data types were hyper tweaked (numbers instead of date fields for dates for example) to squeeze as much out of Oracle's 12GB restriction.