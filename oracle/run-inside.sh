cd $(dirname $0)
pwd
# sqlplus -S sys/password@localhost as sysdba @int-vs-char-vs-date.sql

# I don't know what this container is based on, but it runs as 'oracle'.
# oracle cannot write a file in this mount, but root can so....
su -c "./run-sql-plus-commands.sh"


