cp /code/.pgpass ~/.pgpass
psql -q -U postgres -h database -w postgres -f 01-seed.sql
psql -q -U postgres -h database -w postgres -f 02-select.sql
