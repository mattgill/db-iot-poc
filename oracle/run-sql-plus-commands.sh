echo " "
echo " "

echo "Single Table / Single-Thread Tests"
echo " "
sqlplus -S 'sys/password@localhost' as sysdba @single-01-write-1k.sql > results/results-1k-single-thread.txt
sqlplus -S 'sys/password@localhost' as sysdba @single-02-select.sql >> results/results-1k-single-thread.txt
sqlplus -S 'sys/password@localhost' as sysdba @single-03-drop.sql  >> results/results-1k-single-thread.txt
exit

echo "5k Single Table / Single-Thread Tests"
echo " "
sqlplus -S 'sys/password@localhost' as sysdba @single-01-write-5k.sql > results/results-5k-single-thread.txt
sqlplus -S 'sys/password@localhost' as sysdba @single-02-select.sql >> results/results-5k-single-thread.txt
sqlplus -S 'sys/password@localhost' as sysdba @single-03-drop.sql  >> results/results-5k-single-thread.txt


echo "Partitioned Table / Multi-Thread Tests"
echo " "
sqlplus -S 'sys/password@localhost' as sysdba @partitioned-00-scaffold.sql > results/results-1k-multi-thread.txt
sqlplus -S 'sys/password@localhost' as sysdba @partitioned-01-write-1k.sql >> results/results-1k-multi-thread.txt
sqlplus -S 'sys/password@localhost' as sysdba @partitioned-02-select.sql >> results/results-1k-multi-thread.txt
sqlplus -S 'sys/password@localhost' as sysdba @partitioned-03-drop.sql >> results/results-1k-multi-thread.txt


echo "5k Partitioned Table / Multi-Thread Tests"
echo " "
sqlplus -S 'sys/password@localhost' as sysdba @partitioned-00-scaffold.sql > results/results-5k-multi-thread.txt
sqlplus -S 'sys/password@localhost' as sysdba @partitioned-01-write-5k.sql >> results/results-5k-multi-thread.txt
sqlplus -S 'sys/password@localhost' as sysdba @partitioned-02-select.sql >> results/results-5k-multi-thread.txt
sqlplus -S 'sys/password@localhost' as sysdba @partitioned-03-drop.sql >> results/results-5k-multi-thread.txt

echo " "
echo " "
