-- then we pull a sample query from giant table
-- Retrieve the data for a certain date AND time period: all records for a certain Location ID between the dates 01.01.2013 and 01.01.2017 and between 07:00 and 13:00.

\echo 'Insert timing'
select min(datetime) as start, max(datetime) as end, max(datetime) - min(datetime) as duration
from iot_test_log;

\echo 'Starting seeks...'
\echo

-- 19 seconds to find nothing
\echo 'Loc -1 from 1/1/13 to 1/1/17, 7am to 1pm'

\timing
SELECT count(1) as entries
 FROM iot_giant
where iot_loc = -1
	and iot_datetime between to_date('2013-01-01', 'yyyy-mm-dd') and to_date('2017-01-01', 'yyyy-mm-dd')
	and iot_hour_of_day between 7 and 13
;
\echo

\echo 'Loc 12 from 1/1/13 to 1/1/17, 7am to 1pm'
select count(1), min(iot_loc), max(iot_loc), min(iot_datetime), max(iot_datetime), avg(temperature)
	-- really? not a thing?
	--, med(temperature)
	, percentile_cont(.5) within group (order by temperature) as median
from iot_giant
where iot_loc = 12
	and iot_datetime between to_date('2013-01-01', 'yyyy-mm-dd') and to_date('2017-01-01', 'yyyy-mm-dd')
	and iot_hour_of_day between 7 and 13
;
\echo

-- as I assume the range will be the last we can use
-- 3 threads in top at 100% on lappy...20 minutes
\echo 'Making Index on Loc, Hour, Date';
create index idx_giant on iot_giant(iot_loc, iot_hour_of_day, iot_datetime);
\echo

-- .034 seconds
\echo 'Loc 18 from 1/1/14 to 1/1/18, 10am to 10pm (after index)'
select count(1), min(iot_loc), max(iot_loc), min(iot_datetime), max(iot_datetime), avg(temperature)
	--, med(temperature)
	, percentile_cont(.5) within group (order by temperature) as median
from iot_giant
where iot_loc = 18
	and iot_datetime between to_date('2014-01-01', 'yyyy-mm-dd') and to_date('2018-01-01', 'yyyy-mm-dd')
	and iot_hour_of_day between 10 and 22
;
\echo

\echo
SELECT pg_size_pretty( pg_total_relation_size('iot_giant')) as table_size;
SELECT pg_size_pretty( pg_total_relation_size('idx_giant')) as index_size;
select coalesce(max(iot_entry_id), 0) as max_entry_id from iot_giant;
\timing

-- drop for future runs
drop index idx_giant;