set serveroutput on;

from iot_test_log;

declare
	type r_results_rec is record(
		row_count number
		, first_date number
		, last_date number
		, avg_temp number
		, median_temp number
	);
	v_results r_results_rec;

	v_rows number; -- cheating for first case
	
	v_timer timestamp;

	procedure print_results(p_rec in r_results_rec) as
	begin
		dbms_output.put_line(
			'Rows: ' || v_results.row_count || chr(10)
			|| 'Avg Temp: ' || v_results.avg_temp || chr(10)
			|| 'Median Temp: ' || v_results.median_temp
		);
	end print_results;
	
begin
	select 'Insert timing'
	for rec in (
		select min(datetime) as start, max(datetime) as end, max(datetime) - min(datetime) as duration from iot_test_log
	) loop
		dbms_output.put_line('Start: ' || to_char(rec.start, 'yyyy-mm-dd hh24:mi:ss') || ', End: ' || to_char(rec.end, 'yyyy-mm-dd hh24:mi:ss') || ', Duration: ' || to_char(rec.duration));
	end loop;
	

	dbms_output.put_line('Looking for location -1');
	v_timer := systimestamp;
	select count(1) into v_rows from iot_entries where iot_loc = -1;
	dbms_output.put_line('Found ' || v_rows);
	dbms_output.put_line('Took ' || (systimestamp - v_timer));
	dbms_output.put_line(chr(10));

	dbms_output.put_line('Loc 12 from 1/1/13 to 1/1/17, 7am to 1pm');
	v_timer := systimestamp;
	select
		count(1) as row_count
		, min(iot_date) as first_date
		, max(iot_date) as last_date
		, round(avg(temperature), 2) as avg_temp
		, median(temperature) as median_temp
	into v_results
	from iot_entries
	where iot_loc = 12
		and iot_date between 20130101 and 20170101
		and iot_hour_of_day between 7 and 13;
	
	print_results(v_results);	
	dbms_output.put_line('Took ' || (systimestamp - v_timer));
    dbms_output.put_line(chr(10));

	
	dbms_output.put_line('Making Bitmap Index On Hour');
	v_timer := systimestamp;
	execute immediate 'create bitmap index idx_entries_hour on iot_entries(iot_hour_of_day) local';
	dbms_output.put_line('Index creation took ' || (systimestamp - v_timer));
	dbms_output.put_line(chr(10));

	dbms_output.put_line('Loc 18 from 1/1/14 to 1/1/18, 10am to 10pm (after index)');
	v_timer := systimestamp;
	select
		count(1) as row_count
		, min(iot_date) as first_date
		, max(iot_date) as last_date
		, round(avg(temperature), 2) as avg_temp
		, median(temperature) as median_temp
	into v_results
	from iot_entries
	where iot_loc = 18
		and iot_date between 20140101 and 20180101
		and iot_hour_of_day between 10 and 22;
	print_results(v_results);	
	dbms_output.put_line('Took ' || (systimestamp - v_timer));
	dbms_output.put_line(chr(10));
end;
/

-- because I hate the way sqlplus displays in "console", wrap it
declare
begin
    for rec in (
        select segment_name, round(sum(bytes) / 1000 / 1000, 2) as megabytes
        from user_segments
        where segment_name in ('IOT_ENTRIES', 'IDX_ENTRIES_HOUR')
            -- to get the all the partitioned
            and (
                segment_type like 'IND%'
                or segment_type like 'TAB%'
            )
        group by segment_name
    ) loop
        dbms_output.put_line(rec.segment_name || '        ' || rec.megabytes || 'mb');
    end loop;
end;
/

-- let the index linger, drop will get it.
exit;