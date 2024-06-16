use iot;

delimiter //

begin not atomic
	declare v_locs integer default 1000;
	declare v_years_back integer default 10;
	declare v_timer timestamp default now();
	declare l_loc integer default 1;

	select concat('Locations: ', v_locs, ', Years Back: ', v_years_back);
	
	truncate table iot_test_log;
	truncate table iot_giant;
	call create_timeline(v_years_back);

	-- 1 shot to end them
	insert into iot_giant(
		iot_loc
		, iot_datetime
		, iot_date
		, iot_hour_of_day
		, temperature
		, elec_use
	)
	with cte_locs as (
		select seq as loc_id
		-- from seq_1_to_100 -- 46 seconds
		from seq_1_to_20000 -- 466 seconds
	)
	select
		cl.loc_id
		, t.iot_datetime
		, t.iot_date
		, t.iot_hour_of_day
		-- yes there will be irrational fluxuations....
		, round(rand() * 100, 2)
		, round(rand() * 10, 2)
	from cte_locs cl
	cross join iot_test_timeline t
	where cl.loc_id <= v_locs;
	
	select concat('Took ', timestampdiff( second, v_timer, now() ), ' second');
end;
//