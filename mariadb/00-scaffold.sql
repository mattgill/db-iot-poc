create database if not exists iot;
use iot;

-- default is 4...wasn't seeing as much movement as expected
-- set global thread_pool_size = 8;

-- from, to
-- select timestampdiff(second, now() - interval 1 hour,  now()) from dual;
-- select timestampdiff(hour, now() - interval 1 hour * 2,  now()) from dual;

drop table if exists iot_test_log;
create table if not exists iot_test_log(datetime timestamp, activity_type varchar(4000), msg varchar(4000), elapsed_seconds integer);

-- first we make a giant table
drop table if exists iot_giant;
create table if not exists iot_giant(
--	iot_entry_id bigint unsigned not null auto_increment 1
	iot_entry_id bigint
	, iot_loc bigint unsigned
	, iot_datetime timestamp
	, iot_date date
	, iot_hour_of_day integer
	, temperature decimal(7,2)
	-- lets assume watts for the past hour
	, elec_use decimal(10,2)
--	, primary key (iot_entry_id)
);

drop table if exists iot_test_timeline;
create table if not exists iot_test_timeline(iot_datetime timestamp, iot_date date, iot_hour_of_day smallint);

delimiter //
create or replace procedure create_timeline( in p_years_back integer)
begin
	-- declares need to be first
	declare v_hours_back integer;
	declare v_start_point timestamp default now();
	declare v_curr_hour integer default 0;
	
	set v_hours_back = p_years_back * 12 * 720;
	set v_curr_hour = v_hours_back;

	truncate table iot_test_timeline;

	insert into iot_test_timeline(
		iot_datetime
		, iot_date
		, iot_hour_of_day
	)
	with cte_hours as (
		select seq as minus_hours
		from seq_1_to_500000 -- this is egregious, i admit...if someone wants more than 50 years....they can edit :-)
		where seq <= v_hours_back
	)
	select
		v_start_point - interval minus_hours hour
		, cast(v_start_point - interval minus_hours hour as date)
		, extract( hour from (v_start_point - interval minus_hours hour) )
	from cte_hours;
	commit;
end;
//

-- so I see "Oracle mode" is a thing but feels like cheating.
create or replace procedure create_location_history( in p_loc_id integer)
begin
	declare v_file_timer timestamp default now();
	
	insert into iot_test_log(datetime, activity_type, msg, elapsed_seconds)
	values (now(), concat('Loc ', p_loc_id, ' Insert'), 'Start', null);

	insert into iot_giant(
		iot_entry_id
		, iot_loc
		, iot_datetime
		, iot_date
		, iot_hour_of_day
		, temperature
		, elec_use
	)
	select
		1
		, p_loc_id
		, iot_datetime
		, iot_date
		, iot_hour_of_day
		-- yes there will be irrational fluxuations....
		, round(rand() * 100, 2)
		, round(rand() * 10, 2)
	from iot_test_timeline;
	
	insert into iot_test_log(datetime, activity_type, msg, elapsed_seconds)
	values (
		now()
		, concat('Loc ', p_loc_id, ' Insert')
		, 'Finish'
		, timestampdiff( second, v_file_timer, now())
	);

	commit;
end;
//