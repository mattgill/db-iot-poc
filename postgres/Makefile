all: build seed100 tselect
test1k: build seed1k select
test20k: build seed20k select

build:
	psql -q -U postgres -h database -w postgres -f 00-scaffold.sql
seed1k:
	psql -q -U postgres -h database -w postgres -f 01-seed-1k.sql
seed20k:
	psql -q -U postgres -h database -w postgres -f 01-seed-20k.sql
select:
	psql -q -U postgres -h database -w postgres -f 02-select.sql
clean:
	psql -q -U postgres -h database -w postgres -f cleanup.sql