use iot;

select ' ';
select 'Table Records';
set profiling=1;
select count(1) as table_records, sum(case when iot_loc = 12 then 1 else 0 end) as loc12_recs from iot_giant \G
set profiling=0;

select ' ';
select 'Loc -1 from 1/1/13 to 1/1/17, 7am to 1pm (Invalid Loc, Nothing Should Be Found)';
set profiling=1;
SELECT count(1) as entries
FROM iot_giant
where iot_loc = -1
	and iot_datetime between str_to_date('2013-01-01', '%Y-%m-%d') and str_to_date('2017-01-01', '%Y-%m-%d')
	and iot_hour_of_day between 7 and 13
\G
set profiling=0;


select ' ';
select 'Loc 12 from 1/1/13 to 1/1/17, 7am to 1pm';
set profiling=1;
select distinct count(1) over (partition by iot_loc) as row_count
	, min(iot_datetime)  over (partition by iot_loc) as first_date
	, max(iot_datetime)  over (partition by iot_loc) as last_date
	, avg(temperature)  over (partition by iot_loc) as avg_temp
	, median(temperature) over (partition by iot_loc) as median_temp
from iot_giant
where iot_loc = 12
	and iot_datetime between str_to_date('2013-01-01', '%Y-%m-%d') and str_to_date('2017-01-01', '%Y-%m-%d')
	and iot_hour_of_day between 7 and 13
\G
set profiling=0;

select ' ';
select 'Making Index on Loc, Hour, Date';
set profiling=1;
create index idx_giant on iot_giant(iot_loc, iot_hour_of_day, iot_datetime);
set profiling=0;

-- .034 seconds
select ' ';
select 'Loc 18 from 1/1/14 to 1/1/18, 10am to 10pm (after index)';
set profiling=1;
select distinct count(1) over (partition by iot_loc) as row_count
	, min(iot_datetime)  over (partition by iot_loc) as first_date
	, max(iot_datetime)  over (partition by iot_loc) as last_date
	, avg(temperature)  over (partition by iot_loc) as avg_temp
	, median(temperature) over (partition by iot_loc) as median_temp
from iot_giant
where iot_loc = 18
	and iot_datetime between str_to_date('2014-01-01', '%Y-%m-%d') and str_to_date('2018-01-01', '%Y-%m-%d')
	and iot_hour_of_day between 10 and 22
\G
set profiling=0;

/*
SELECT table_schema "DB Name",
        ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) "DB Size in MB" 
FROM information_schema.tables 
GROUP BY table_schema; 
*/



-- drop for future runs
set profiling=1;
drop index if exists idx_giant on iot_giant;
set profiling=0;

show profiles;

