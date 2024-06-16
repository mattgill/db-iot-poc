use iot;

set global event_scheduler=on;

delimiter //

/*
create event create_locs_t1
on schedule at current_timestamp
do call create_location_history(1);

call create_location_history(1);

Select * from information_schema.events;
*/

-- i think i'm getting lock contention....
-- this took 9 minutes (SSD) to do 1k and the per file entries are taking longer than the second they were before.
-- if I take off the auto-inc/PK I see multiple CPUs used, but we only made it down to 8 minutes.
-- just 10 minutes one at a time...
begin not atomic
	declare v_locs integer default 1000;
	declare v_years_back integer default 10;
	declare v_timer timestamp default now();
	declare l_loc integer default 1;
	declare v_blackhole varchar(100) default '';

	declare v_max_threads integer default 4;
	declare v_curr_threads integer default 0;
	declare v_event_name_prefix varchar(100) default 'create_locs_t';
	
	select concat('Locations: ', v_locs, ', Years Back: ', v_years_back);
	
	truncate table iot_test_log;
	truncate table iot_giant;

	-- since this is physical it can be reused by every event
	call create_timeline(v_years_back);

	insert into iot_test_log(datetime, activity_type, msg, elapsed_seconds)
	values (now(), 'Data Generation', 'Start', null);
	commit;

	for l_loc in 1 .. v_locs do
		-- wait for availability if required
	 	`threadHold`: while v_curr_threads >= v_max_threads do
	 		select count(1) into v_curr_threads from information_schema.events where event_name like 'create_locs_t%';
	 		if v_curr_threads < v_max_threads then
	 			leave `threadHold`;
	 		end if;
	 		-- sleep(5); -- grr
			select(sleep(.1)) into v_blackhole from dual; -- sleep .5 was 1m 49s for 100 locs, sleep .2 was  not much different
			-- for reference 100 single thread was 2m 5s.
	 	end while; -- end hold
		
	 	-- all systems go
		execute immediate concat('create event create_locs_t', l_loc, '
on schedule at current_timestamp
do call create_location_history(', l_loc, ')');
			
		set v_curr_threads = v_curr_threads + 1;
	end for; -- location loop

	insert into iot_test_log(datetime, activity_type, msg, elapsed_seconds)
	values (now(), 'Data Generation', 'Finish', timestampdiff( second, v_timer, now()) );

	select concat('Took ', timestampdiff( second, v_timer, now() ), ' second');
end;
//