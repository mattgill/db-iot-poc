if [[ -z `which make` ]]; then
    echo "Installing make (one-time thing)..."
    apt update > /tmp/install-results.txt 2>&1
    apt install -y make >> /tmp/install-results.txt 2>&1
fi;

# would also set the working directory in the invocation...
cd $(dirname $0)

echo " "
echo " "

echo "1k Loop"
time make -s test1k-loop | tee results/results-test1k-loop.txt
echo " "
echo " "

echo "1k Events"
time make -s test1k-events | tee results/results-test1k-events.txt
echo " "
echo " "

echo "1k OneShot"
time make -s test1k-oneshot | tee results/results-test1k-oneshot.txt
echo " "
echo " "

echo "20k Loop"
time make -s test20k-loop | tee results/results-test20k-loop.txt
echo " "
echo " "

