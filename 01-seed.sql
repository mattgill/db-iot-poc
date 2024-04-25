-- step 0
-- setup a log table
drop table iot_test_log;
create table iot_test_log(datetime timestamp, activity_type varchar(4000), msg varchar(4000), duration interval);

-- first we make a giant table
drop table iot_giant;
create table iot_giant(
	iot_entry_id serial primary key
	, iot_loc integer
	, iot_datetime timestamp
	, iot_date date
	, iot_hour_of_day integer
	, temperature decimal(5,2)
	-- lets assume watts for the past hour
	, elec_use decimal(6,2)
);

\echo 'Starting data insert'

\timing
do $$
declare
	--v_locs integer := 20000;
	v_locs integer := 20000;
	v_years_back integer := 10;
	v_hours_back integer := v_years_back * 12 * 720; -- i'm admittedly roughing it here
	v_start_point timestamp := now();

	v_timer timestamp;

	rec record;
	v_sql varchar;
	v_file_timer timestamp;
begin
	raise notice '%', 'Locations: ' || v_locs || ', Years Back: ' || v_years_back;
	v_timer := now();
	insert into iot_test_log(datetime, activity_type, msg, duration)
	values (now(), 'Data Generation', 'Start', null);

	for l_loc in 1 .. v_locs loop
		v_file_timer := now();
		insert into iot_test_log(datetime, activity_type, msg, duration)
		values (now(), 'File ' || l_loc || ' Insert', 'Start', null);
	
		insert into iot_giant(
			iot_loc
			, iot_datetime
			, iot_date
			, iot_hour_of_day
			, temperature
			, elec_use
		)
		select
			l_loc as iot_loc
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
		values (now(), 'File ' || l_loc || ' Insert', 'Finish', (now() - v_file_timer));
	
		commit;
	end loop;
	
	insert into iot_test_log(datetime, activity_type, msg, duration)
	values (now(), 'Data Generation', 'Finish', (now() - v_timer));
end;
$$;

-- newlines
\echo
\echo