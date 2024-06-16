declare
begin
    execute immediate 'drop table iot_entries';
exception when others then
    if sqlcode != -942 then
        raise;
    end if;
end;
/

create table iot_entries(
    -- iot_entry_id -- not going to fill this to save bytes
    iot_loc number(5)
    , iot_date number(8) -- wouldn't normally use this type but every bite is counting
    , iot_hour_of_day number(2)
    , temperature number(5, 2)
)
partition by list(iot_loc) automatic (
	partition l0 values (0)
);


create or replace procedure create_location_history(p_loc_id in number, p_years_back in number)
as
	v_hours_back integer := p_years_back * 365 * 24; -- i'll lose leap days but meh
begin

    insert into iot_entries(iot_loc, iot_date, iot_hour_of_day, temperature)
    with cte as (
        select
            level
            , systimestamp - interval '1' hour * level as iot_datetime
        from dual
        connect by level <= v_hours_back
    )
    select
        p_loc_id
        , to_number(to_char(iot_datetime, 'yyyymmdd'))
        , to_number(to_char(iot_datetime, 'hh24'))
        , round(dbms_random.value(0, 110), 2) as temperature
	from cte;
	commit;
end create_location_history;
/

-- spawn jobs per location
create or replace procedure create_location_histories(p_locs in number, p_years_back in number, p_threads in number)
as
	v_active_threads number := 0;
    v_timer timestamp := systimestamp;
begin
    dbms_output.put_line(p_locs || ' locations, ' || p_years_back || ' years back, ' || p_threads || ' threads');

	for l_loc_id in 1 .. p_locs loop
		-- if you don't have slots, wait for an opening
		while (v_active_threads >= p_threads) loop
			dbms_session.sleep(.25);
			select count(1) into v_active_threads from dba_scheduler_jobs where owner = 'SYS' and job_name like 'CREATE_LOC_%';
		end loop;
	
		-- go!
		dbms_scheduler.create_job(
			job_name => 'CREATE_LOC_' || l_loc_id
			-- just because I want to auto-drop and start immediate, I'm going to anon block this as opposed to calling the proc and setting arguments
			, job_type => 'PLSQL_BLOCK'
			, job_action => 'begin create_location_history(' || l_loc_id || ', ' || p_years_back || '); end;'
			, enabled => true
			, auto_drop => true
		);
		v_active_threads := v_active_threads + 1;
	end loop;

    -- so now everything has been spawned. don't return until we are done
    while (v_active_threads > 0) loop
        dbms_session.sleep(.25);
        select count(1) into v_active_threads from dba_scheduler_jobs where owner = 'SYS' and job_name like 'CREATE_LOC_%';
    end loop;

    dbms_output.put_line('Creating ' || p_locs || ' locations took ' || (systimestamp - v_timer));
end create_location_histories;
/

-- because sqlplus
exit;