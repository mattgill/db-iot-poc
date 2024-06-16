set serveroutput on;

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
);

declare
    v_locs number := 5000;
    v_years_back number := 10;

    type t_numbers is table of number;
    a_locs t_numbers := t_numbers();

    v_hours_back number := v_years_back * 12 * 720;
    v_timer timestamp;
begin
    for l_i in 1 .. v_locs loop
        a_locs.extend;
        a_locs(a_locs.last) := l_i;
    end loop;

    dbms_output.put_line(v_locs  || ' locations, ' || v_years_back || ' years back');
    v_timer := systimestamp;
    --forall l_l in 1 .. a_locs.count
    for l_l in 1 .. a_locs.count loop
        insert into iot_entries(iot_loc, iot_date, iot_hour_of_day, temperature)
        with cte as (
            select
                level
                , systimestamp - interval '1' hour * level as iot_datetime
            from dual
            connect by level <= v_hours_back
        )
        select
            a_locs(l_l)
            , to_number(to_char(iot_datetime, 'yyyymmdd'))
            , to_number(to_char(iot_datetime, 'hh24'))
            , round(dbms_random.value(0, 110), 2) as temperature
        from cte;
        commit;
    end loop;
    dbms_output.put_line('Location creation took ' || (systimestamp - v_timer));
end;
/

-- because sqlplus
exit;