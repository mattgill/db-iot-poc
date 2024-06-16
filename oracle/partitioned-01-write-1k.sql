set serveroutput on;

-- 4 threads
exec create_location_histories(1000, 10, 4);

-- again because sqlplus
exit;