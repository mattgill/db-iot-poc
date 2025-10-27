if [[ -z `which make` ]]; then
    echo "Installing make (one-time thing)..."
    # default citus is debian not alpine. alpine doesn't have columnar.
    apt update > /dev/null 2>&1
    apt install -y build-essential > /tmp/install-results.txt 2>&1
    
fi;

sleep 2
cp /code/.pgpass ~/.pgpass
chmod 600 ~/.pgpass

cd $(dirname $0)
pwd
make -s test10 | tee results/results10.txt
make -s test1k | tee results/results1k.txt
make -s test20k | tee results/results20k.txt
