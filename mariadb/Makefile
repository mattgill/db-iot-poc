all: build seed1k-loop select
test1k-events: build seed1k-events select
test1k-loop: build seed1k-loop select
test1k-oneshot: build seed1k-oneshot select
test20k-loop: build seed20k-loop select


build:
	mariadb -s --host=localhost --user=root --password=password < 00-scaffold.sql
seed1k-events:
	mariadb -s --host=localhost --user=root --password=password < 01-seed-1k-events.sql
seed1k-loop:
	mariadb -s --host=localhost --user=root --password=password < 01-seed-1k-loop.sql
seed20k-loop:
	mariadb -s --host=localhost --user=root --password=password < 01-seed-20k-loop.sql
seed1k-oneshot:
	mariadb -s --host=localhost --user=root --password=password < 01-seed-1k-oneshot.sql
select:
	mariadb -s --host=localhost --user=root --password=password < 02-select.sql
clean:
	mariadb -s --host=localhost --user=root --password=password < cleanup.sql