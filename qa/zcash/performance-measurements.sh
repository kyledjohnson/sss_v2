#!/bin/bash
set -u


DATADIR=./benchmark-datadir
SHA256CMD="$(command -v sha256sum || echo shasum)"
SHA256ARGS="$(command -v sha256sum >/dev/null || echo '-a 256')"

function seventeenseventysix_rpc {
    ./src/seventeenseventysix-cli -datadir="$DATADIR" -rpcuser=user -rpcpassword=password -rpcport=5983 "$@"
}

function seventeenseventysix_rpc_slow {
    # Timeout of 1 hour
    seventeenseventysix_rpc -rpcclienttimeout=3600 "$@"
}

function seventeenseventysix_rpc_veryslow {
    # Timeout of 2.5 hours
    seventeenseventysix_rpc -rpcclienttimeout=9000 "$@"
}

function seventeenseventysix_rpc_wait_for_start {
    seventeenseventysix_rpc -rpcwait getinfo > /dev/null
}

function seventeenseventysixd_generate {
    seventeenseventysix_rpc generate 101 > /dev/null
}

function seventeenseventysixd_start {
    rm -rf "$DATADIR"
    mkdir -p "$DATADIR/regtest"
    touch "$DATADIR/seventeenseventysix.conf"
    ./src/seventeenseventysixd -regtest -datadir="$DATADIR" -rpcuser=user -rpcpassword=password -rpcport=5983 -showmetrics=0 &
    SEVENTEENSEVENTYSIXD_PID=$!
    seventeenseventysix_rpc_wait_for_start
}

function seventeenseventysixd_stop {
    seventeenseventysix_rpc stop > /dev/null
    wait $SEVENTEENSEVENTYSIXD_PID
}

function seventeenseventysixd_massif_start {
    rm -rf "$DATADIR"
    mkdir -p "$DATADIR/regtest"
    touch "$DATADIR/seventeenseventysix.conf"
    rm -f massif.out
    valgrind --tool=massif --time-unit=ms --massif-out-file=massif.out ./src/seventeenseventysixd -regtest -datadir="$DATADIR" -rpcuser=user -rpcpassword=password -rpcport=5983 -showmetrics=0 &
    SEVENTEENSEVENTYSIXD_PID=$!
    seventeenseventysix_rpc_wait_for_start
}

function seventeenseventysixd_massif_stop {
    seventeenseventysix_rpc stop > /dev/null
    wait $SEVENTEENSEVENTYSIXD_PID
    ms_print massif.out
}

function seventeenseventysixd_valgrind_start {
    rm -rf "$DATADIR"
    mkdir -p "$DATADIR/regtest"
    touch "$DATADIR/seventeenseventysix.conf"
    rm -f valgrind.out
    valgrind --leak-check=yes -v --error-limit=no --log-file="valgrind.out" ./src/seventeenseventysixd -regtest -datadir="$DATADIR" -rpcuser=user -rpcpassword=password -rpcport=5983 -showmetrics=0 &
    SEVENTEENSEVENTYSIXD_PID=$!
    seventeenseventysix_rpc_wait_for_start
}

function seventeenseventysixd_valgrind_stop {
    seventeenseventysix_rpc stop > /dev/null
    wait $SEVENTEENSEVENTYSIXD_PID
    cat valgrind.out
}

function extract_benchmark_data {
    if [ -f "block-107134.tar.xz" ]; then
        # Check the hash of the archive:
        "$SHA256CMD" $SHA256ARGS -c <<EOF
4bd5ad1149714394e8895fa536725ed5d6c32c99812b962bfa73f03b5ffad4bb  block-107134.tar.xz
EOF
        ARCHIVE_RESULT=$?
    else
        echo "block-107134.tar.xz not found."
        ARCHIVE_RESULT=1
    fi
    if [ $ARCHIVE_RESULT -ne 0 ]; then
        seventeenseventysixd_stop
        echo
        echo "Please generate it using qa/seventeenseventysix/create_benchmark_archive.py"
        echo "and place it in the base directory of the repository."
        echo "Usage details are inside the Python script."
        exit 1
    fi
    xzcat block-107134.tar.xz | tar x -C "$DATADIR/regtest"
}

# Precomputation
case "$1" in
    *)
        case "$2" in
            verifyjoinsplit)
                seventeenseventysixd_start
                RAWJOINSPLIT=$(seventeenseventysix_rpc zcsamplejoinsplit)
                seventeenseventysixd_stop
        esac
esac

case "$1" in
    time)
        seventeenseventysixd_start
        case "$2" in
            sleep)
                seventeenseventysix_rpc zcbenchmark sleep 10
                ;;
            parameterloading)
                seventeenseventysix_rpc zcbenchmark parameterloading 10
                ;;
            createjoinsplit)
                seventeenseventysix_rpc zcbenchmark createjoinsplit 10 "${@:3}"
                ;;
            verifyjoinsplit)
                seventeenseventysix_rpc zcbenchmark verifyjoinsplit 1000 "\"$RAWJOINSPLIT\""
                ;;
            solveequihash)
                seventeenseventysix_rpc_slow zcbenchmark solveequihash 50 "${@:3}"
                ;;
            verifyequihash)
                seventeenseventysix_rpc zcbenchmark verifyequihash 1000
                ;;
            validatelargetx)
                seventeenseventysix_rpc zcbenchmark validatelargetx 5
                ;;
            trydecryptnotes)
                seventeenseventysix_rpc zcbenchmark trydecryptnotes 1000 "${@:3}"
                ;;
            incnotewitnesses)
                seventeenseventysix_rpc zcbenchmark incnotewitnesses 100 "${@:3}"
                ;;
            connectblockslow)
                extract_benchmark_data
                seventeenseventysix_rpc zcbenchmark connectblockslow 10
                ;;
            *)
                seventeenseventysixd_stop
                echo "Bad arguments."
                exit 1
        esac
        seventeenseventysixd_stop
        ;;
    memory)
        seventeenseventysixd_massif_start
        case "$2" in
            sleep)
                seventeenseventysix_rpc zcbenchmark sleep 1
                ;;
            parameterloading)
                seventeenseventysix_rpc zcbenchmark parameterloading 1
                ;;
            createjoinsplit)
                seventeenseventysix_rpc_slow zcbenchmark createjoinsplit 1 "${@:3}"
                ;;
            verifyjoinsplit)
                seventeenseventysix_rpc zcbenchmark verifyjoinsplit 1 "\"$RAWJOINSPLIT\""
                ;;
            solveequihash)
                seventeenseventysix_rpc_slow zcbenchmark solveequihash 1 "${@:3}"
                ;;
            verifyequihash)
                seventeenseventysix_rpc zcbenchmark verifyequihash 1
                ;;
            trydecryptnotes)
                seventeenseventysix_rpc zcbenchmark trydecryptnotes 1 "${@:3}"
                ;;
            incnotewitnesses)
                seventeenseventysix_rpc zcbenchmark incnotewitnesses 1 "${@:3}"
                ;;
            connectblockslow)
                extract_benchmark_data
                seventeenseventysix_rpc zcbenchmark connectblockslow 1
                ;;
            *)
                seventeenseventysixd_massif_stop
                echo "Bad arguments."
                exit 1
        esac
        seventeenseventysixd_massif_stop
        rm -f massif.out
        ;;
    valgrind)
        seventeenseventysixd_valgrind_start
        case "$2" in
            sleep)
                seventeenseventysix_rpc zcbenchmark sleep 1
                ;;
            parameterloading)
                seventeenseventysix_rpc zcbenchmark parameterloading 1
                ;;
            createjoinsplit)
                seventeenseventysix_rpc_veryslow zcbenchmark createjoinsplit 1 "${@:3}"
                ;;
            verifyjoinsplit)
                seventeenseventysix_rpc zcbenchmark verifyjoinsplit 1 "\"$RAWJOINSPLIT\""
                ;;
            solveequihash)
                seventeenseventysix_rpc_veryslow zcbenchmark solveequihash 1 "${@:3}"
                ;;
            verifyequihash)
                seventeenseventysix_rpc zcbenchmark verifyequihash 1
                ;;
            trydecryptnotes)
                seventeenseventysix_rpc zcbenchmark trydecryptnotes 1 "${@:3}"
                ;;
            incnotewitnesses)
                seventeenseventysix_rpc zcbenchmark incnotewitnesses 1 "${@:3}"
                ;;
            connectblockslow)
                extract_benchmark_data
                seventeenseventysix_rpc zcbenchmark connectblockslow 1
                ;;
            *)
                seventeenseventysixd_valgrind_stop
                echo "Bad arguments."
                exit 1
        esac
        seventeenseventysixd_valgrind_stop
        rm -f valgrind.out
        ;;
    valgrind-tests)
        case "$2" in
            gtest)
                rm -f valgrind.out
                valgrind --leak-check=yes -v --error-limit=no --log-file="valgrind.out" ./src/seventeenseventysix-gtest
                cat valgrind.out
                rm -f valgrind.out
                ;;
            test_bitcoin)
                rm -f valgrind.out
                valgrind --leak-check=yes -v --error-limit=no --log-file="valgrind.out" ./src/test/test_bitcoin
                cat valgrind.out
                rm -f valgrind.out
                ;;
            *)
                echo "Bad arguments."
                exit 1
        esac
        ;;
    *)
        echo "Bad arguments."
        exit 1
esac

# Cleanup
rm -rf "$DATADIR"
