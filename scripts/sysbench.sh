#!/bin/bash

set -e

check_version() {
if [ "$VERSION_STR" = "" ]; then
    echo "Image version is not set. We'll default to '0.0.1'"
    VERSION_STR=0.0.1
fi
}

check_vars() {
    if [ "$PORT" = "" ]; then
        echo "Setting PORT to default 5432"
        PORT=5432
    fi

    if [ "$HOST" = "" ]; then
        echo "Setting HOST to localhost"
        HOST=localhost
    fi

    if [ "$TABLESIZE" = "" ]; then
        echo "Using defailt TABLESIZE=1000000"
        TABLESIZE=1000000
    fi

    if [ "$MY_IP" = "" ]; then
        echo "Client IP address missing: Use: 'ip addr' or other utility to get address"
        exit 1
    fi
}

check_version
echo "Checking environment variables"
check_vars

while getopts ":cprwm" option; do
    case $option in
        c) # Create test database and user
            # docker exec postgres-test-$VERSION_STR bash -c 'echo -e "alter role postgres password '\'pass1234\'';" >> run.sql'
            docker exec postgres-test-$VERSION_STR bash -c 'echo -e "create user sbtest login createdb password '\'sbtest\'';" >> run.sql'

            docker exec postgres-test-$VERSION_STR bash -c "/usr/local/pgsql/bin/psql -f run.sql"
            docker exec postgres-test-$VERSION_STR bash -c "/usr/local/pgsql/bin/createdb sbtest -O sbtest"

            container_ip_address=`docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' postgres-test-$VERSION_STR`
            addresses_entry="echo -e \"listen_addresses = '$container_ip_address, localhost'\" >> /usr/local/pgsql/data/postgresql.conf"
            docker exec postgres-test-$VERSION_STR bash -c "$addresses_entry"

            host_entry="echo -e 'host sbtest sbtest $MY_IP/24 md5' >> /usr/local/pgsql/data/pg_hba.conf"
            docker exec postgres-test-$VERSION_STR bash -c "$host_entry"
            docker restart postgres-test-$VERSION_STR
            ;;
        p) # prepare
            sysbench oltp_read_write \
                --tables=10 \
                --table-size=$TABLESIZE \
                --db-driver=pgsql \
                --pgsql-host=$HOST \
                --pgsql-port=$PORT \
                --pgsql-user=sbtest \
                --threads=10 \
                --pgsql-password=sbtest \
                --pgsql-db=sbtest \
                prepare
                ;;
        r) # read
            sysbench oltp_read_only \
                --tables=10 \
                --table-size=$TABLESIZE \
                --db-driver=pgsql \
                --pgsql-host=$HOST \
                --pgsql-port=$PORT \
                --pgsql-user=sbtest \
                --pgsql-password=sbtest \
                --pgsql-db=sbtest \
                --threads=16 \
                --report-interval=2 \
                --time=60 --db-debug=on \
                run
                ;;
        w) # write
            sysbench oltp_write_only \
                --tables=10 \
                --table-size=$TABLESIZE \
                --db-driver=pgsql \
                --pgsql-host=$HOST \
                --pgsql-port=$PORT \
                --pgsql-user=sbtest \
                --pgsql-password=sbtest \
                --pgsql-db=sbtest \
                --threads=16 \
                --report-interval=2 \
                --time=60 \
                run
                ;;
        m) # read and write mix
            sysbench oltp_read_write \
                --tables=10 \
                --table-size=$TABLESIZE \
                --db-driver=pgsql \
                --pgsql-host=$HOST \
                --pgsql-port=$PORT \
                --pgsql-user=sbtest \
                --pgsql-password=sbtest \
                --pgsql-db=sbtest \
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
