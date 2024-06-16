use iot;

delimiter //

begin not atomic
	declare v_locs integer default 20000;
	declare v_years_back integer default 10;
	declare v_timer timestamp default now();
	declare l_loc integer default 1;

	select concat('Locations: ', v_locs, ', Years Back: ', v_years_back);
	
	truncate table iot_test_log;
	truncate table iot_giant;
	call create_timeline(v_years_back);


	insert into iot_test_log(datetime, activity_type, msg, elapsed_seconds)
	values (now(), 'Data Generation', 'Start', null);
	commit;
	
	while l_loc <= v_locs do
		call create_location_history(l_loc);
		set l_loc = l_loc + 1;
	end while;
	insert into iot_test_log(datetime, activity_type, msg, elapsed_seconds)
	values (now(), 'Data Generation', 'Finish', timestampdiff( second, v_timer, now()) );

	select concat('Took ', timestampdiff( second, v_timer, now() ), ' second');
end;
//
