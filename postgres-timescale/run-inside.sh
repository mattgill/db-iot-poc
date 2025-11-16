if [[ -z `which make` ]]; then
    echo "Installing make (one-time thing)..."
    apk add make > /tmp/install-results.txt 2>&1
fi;

sleep 2
cp /code/.pgpass ~/.pgpass
chmod 600 ~/.pgpass

cd $(dirname $0)
make -s test10 | tee results/results10.txt
make -s test1k | tee results/results1k.txt
make -s test20k | tee results/results20k.txt
