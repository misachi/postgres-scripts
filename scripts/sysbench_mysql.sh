#!/bin/bash

set -ex

check_vars() {
    if [ "$PORT" = "" ]; then
        echo "Setting PORT to default 3306"
        PORT=3306
    fi

    if [ "$HOST" = "" ]; then
        echo "Setting HOST to localhost"
        HOST=localhost
    fi

    if [ "$TABLESIZE" = "" ]; then
        echo "Using defailt TABLESIZE=1000000"
        TABLESIZE=1000000
    fi

}

echo "Checking environment variables"
check_vars

while getopts ":prwm" option; do
    case $option in
        p) # prepare
            sysbench oltp_read_write \
                --tables=10 \
                --table-size=$TABLESIZE \
                --db-driver=mysql \
                --mysql-host=$HOST \
                --mysql-port=$PORT \
                --mysql-user=sbtest \
                --threads=10 \
                --mysql-password=sbtest \
                --mysql-db=sbtest \
                prepare
                ;;       
        r) # read
            sysbench oltp_read_only \
                --tables=10 \
                --table-size=$TABLESIZE \
                --db-driver=mysql \
                --mysql-host=$HOST \
                --mysql-port=$PORT \
                --mysql-user=sbtest \
                --mysql-password=sbtest \
                --mysql-db=sbtest \
                --mysql-ssl=off \
                --threads=16 \
                --report-interval=2 \
                --time=60 --db-debug=on \
                run 
                ;;
        w) # write
            sysbench oltp_write_only \
                --tables=10 \
                --table-size=$TABLESIZE \
                --db-driver=mysql \
                --mysql-host=$HOST \
                --mysql-port=$PORT \
                --mysql-user=sbtest \
                --mysql-password=sbtest \
                --mysql-db=sbtest \
                --mysql-ssl=off \
                --threads=16 \
                --report-interval=2 \
                --time=60 \
                run
                ;;
        m) # read and write mix
            sysbench oltp_read_write \
                --tables=10 \
                --table-size=$TABLESIZE \
                --db-driver=mysql \
                --mysql-host=$HOST \
                --mysql-port=$PORT \
                --mysql-user=sbtest \
                --mysql-password=sbtest \
                --mysql-db=sbtest \
                --mysql-ssl=off \
                --threads=16 \
                --report-interval=2 \
                --time=60 \
                run
                ;;
        \?) # Invalid Option
            echo "Invalid Option"
            exit;;
    esac
done