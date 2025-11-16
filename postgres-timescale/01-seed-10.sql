do $$
declare
	v_locs integer := 10;
	v_years_back integer := 10;
	v_timer timestamp; 
begin
	raise notice '%', 'Locations: ' || v_locs || ', Years Back: ' || v_years_back;
	
	truncate table iot_test_log;
	truncate table iot_giant;

	v_timer := now();
	insert into iot_test_log(datetime, activity_type, msg, duration)
	values (now(), 'Data Generation', 'Start', null);
	commit;
	
	for l_loc in 1 .. v_locs loop
		call create_location_history(l_loc, v_years_back);
	end loop;
	insert into iot_test_log(datetime, activity_type, msg, duration)
	values (now(), 'Data Generation', 'Finish', (now() - v_timer));
end;
$$;