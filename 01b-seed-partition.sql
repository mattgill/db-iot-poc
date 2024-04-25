-- then a partitioned table
-- the poster argues that location, day, and hour of are important.
-- i do like that Oracle lets you define a primary partition strategy and then a subpartition template _both_ in the create.
-- now if I wanted to be sneaky maybe I'd have the app generate a list of days and hours to be used as in-lists, though we could see that fall apart if the lists get big enough.

-- in Oracle I'd combine a range partition on iot_datetime and a list on loc and hour (yes the hour would invoke a iterator but probably still nice?)
-- I'll throw a local index on iot_datetime given the below.
-- I see you can create tables inside partitions to subdivide, but it's a lot of static prep IMO.
drop table iot_part;
create table iot_part(
	iot_entry_id integer -- primary key -- I'll steal from the other table
	, iot_loc integer
	, iot_datetime timestamp
	, iot_date date -- see below
	, iot_hour_of_day integer -- see below
	, temperature decimal(7,2)
	-- lets assume watts for the past hour
	, elec_use decimal(10,2)
	, primary key (iot_entry_id, iot_loc, iot_date, iot_hour_of_day) -- all partition keys must be part of the unique constraint
-- heh, can't use a list strategy on more than one col in Oracle apparently
-- PRIAMRY KEY constraints cannot be used when partition keys include expressions
--) partition by range(iot_loc, date(iot_datetime), extract(hour from iot_datetime));
-- man do I take Oracle's automatic partition clause for granted!
) partition by range(iot_loc, iot_date);


-- make partitions for the above
-- this takes over 8 hours....i gave up waiting.
do $$
declare
	v_locs integer := 2000;
	v_years_back integer := 10;
	v_hours_back integer := 10 * 12 * 720; -- i'm admittedly roughing it here

	v_start_point timestamp := now();
	v_timer timestamp;

	rec record;
	v_sql varchar;
begin
	v_timer := now();
	insert into iot_test_log(datetime, activity_type, msg, duration)
	values (now(), 'Partition Generation', 'Start', null);

	for l_loc in 1 .. v_locs loop
		-- in postgres the loop var needs to exist as a record type (see declare above)
		for rec in (
			select distinct
				l_loc as iot_loc
				, date(v_start_point - interval '1  hour' * v_row) as iot_date
			from generate_series(1, v_hours_back) v_row
		)
		loop
			v_sql := 'create table iot_part_l' || l_loc || '_d' || to_char(rec.iot_date, 'yyyymmdd') 
				|| ' partition of iot_part
				for values
					from (' || l_loc || ', cast(''' || rec.iot_date || ''' as date) )
					to (' || l_loc  || ', cast(''' || (rec.iot_date + interval '1 day') || ''' as date) )';
			
--			raise notice '%', v_sql;
			execute v_sql;
		end loop; -- implicit cursor end
	end loop; -- end loc
	
	insert into iot_test_log(datetime, activity_type, msg, duration)
	values (now(), 'Partition Generation', 'Finish', (now() - v_timer));
end; $$


declare
	v_sql varchar;
begin
	v_timer := now();

 	insert into iot_test_log(datetime, activity_type, msg, duration)
	values (now(), 'Data Copy to Partitioned', 'Start', null);

	-- this might be too greedy taking the whole thing at once, but not like I could explicit commit if i went file by file....
	v_timer := now();
	insert into iot_part(
		iot_entry_id
		, iot_loc
		, iot_datetime
		, iot_date
		, iot_hour_of_day
		, temperature
		, elec_use
	)
	select
		iot_entry_id
		, iot_loc
		, iot_datetime
		, iot_date
--		, extract(hour from iot_datetime) as iot_hour_of_day
		, iot_hour_of_day
		, temperature
		, elec_use
	from iot_giant
	order by iot_entry_id;

	insert into iot_test_log(datetime, activity_type, msg, duration)
	values (now(), 'Data Copy to Partitioned', 'Finish', (now() - v_timer));

end; $$


-- need  an index on the giant to try and cover this.
--create index 
