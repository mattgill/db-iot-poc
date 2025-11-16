drop table if exists iot_test_log;
create table if not exists iot_test_log(datetime timestamp, activity_type varchar(4000), msg varchar(4000), duration interval);

-- first we make a giant table
drop table if exists iot_giant;
create table if not exists iot_giant(
	iot_entry_id serial
	, iot_loc integer
	, iot_datetime timestamptz -- needed for timescale
	, iot_date date
	, iot_hour_of_day integer
	, temperature decimal(7,2)
	-- lets assume watts for the past hour
	, elec_use decimal(10,2)
	, primary key (iot_entry_id, iot_datetime) -- include time column in PK for hypertable partitioning
);

select create_hypertable('iot_giant', 'iot_datetime');

create or replace procedure create_location_history( p_loc_id integer, p_years_back integer)
language plpgsql
as $$
declare
	v_hours_back integer := p_years_back * 12 * 720; -- i'm admittedly roughing it here
	v_start_point timestamp := now();

	v_file_timer timestamp;
begin
	v_file_timer := now();
	insert into iot_test_log(datetime, activity_type, msg, duration)
	values (now(), 'File ' || p_loc_id || ' Insert', 'Start', null);

	insert into iot_giant(
		iot_loc
		, iot_datetime
		, iot_date
		, iot_hour_of_day
		, temperature
		, elec_use
	)
	select
		p_loc_id as iot_loc
		, v_start_point - interval '1  hour' * v_row as iot_datetime
		, date(v_start_point - interval '1  hour' * v_row) as iot_date
		, extract(hour from (v_start_point - interval '1  hour' * v_row)) as iot_hour_of_day
		-- between 20 and 110. yes there will be irrational fluxuations....
		-- lifted from here: https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-random-range/
--			, 1 as temperature
--			, 2 as elec_use
		, round(cast(random()* (110 - 20 + 1) + 20 as numeric), 2) as temperature
		-- and between 1 - 10 for the wattage
		, round(cast(random()* (10 - 1 + 1) + 1 as numeric), 4) as elec_use
	-- give me a table of v_hours_back entries
	-- and I admit, this beats a connect by to generate numbers!
	from generate_series(1, v_hours_back) v_row
	order by v_row;

	insert into iot_test_log(datetime, activity_type, msg, duration)
	values (now(), 'File ' || p_loc_id || ' Insert', 'Finish', (now() - v_file_timer));

	commit;

end; $$


