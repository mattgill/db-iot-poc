-- if we only need yyyymmdd...which is smallest to store?
-- granted if not a full date object code might need to be clever about range lookups....
create table test_num as
select to_number(to_char(sysdate, 'yyyymmdd')) as iot_date
from dual
connect by level <= 1000000;

create table test_date as
select sysdate as iot_date
from dual
connect by level <= 1000000;

create table test_char as
select to_char(sysdate, 'yyyymmdd') as iot_date
from dual
connect by level <= 1000000;

/*
TEST_CHAR
  16,777,216

TEST_DATE
  15,728,640

TEST_NUM
  12,582,912
*/

-- in any other case I'd likely use user_segments, but I'm already SYS for this test
select segment_name, bytes
from dba_segments
where owner = 'SYS'
    and segment_name in ('TEST_NUM', 'TEST_CHAR', 'TEST_DATE')
order by segment_name;

drop table test_num;
drop table test_date;
drop table test_char;

/*
TEST_CHAR
  16777216

TEST_DATE
  15728640

TEST_NUM
  12582912
*/

-- because we need to leave sqlplus
exit;