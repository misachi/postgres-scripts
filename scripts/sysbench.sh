#!/bin/bash

set -e

check_version() {
if [ "$VERSION_STR" = "" ]; then
    echo "Version is not set. This will be the version number for the image tag e.g account/image-1.0.1 where 1.0.1 is the version"
    echo "Use 'export VERSION_STR=1.0.0' to set it"
    exit 1
fi
}

check_vars() {
    if [ "$PORT" = "" ]; then
        echo "PORT is not set"
        exit 1
    fi

    if [ "$USER" = "" ]; then
        echo "USER is not set"
        exit 1
    fi

    if [ "$DATABASE" = "" ]; then
        echo "DATABASE is not set"
        exit 1
    fi

    if [ "$PASSWORD" = "" ]; then
        echo "PASSWORD is not set"
        exit 1
    fi

    if [ "$HOST" = "" ]; then
        echo "HOST is not set"
        exit 1
    fi

    if [ "$TABLESIZE" = "" ]; then
        echo "TABLESIZE is not set"
        exit 1
    fi

    if [ "$MY_IP" = "" ]; then
        echo "Unknown IP address"
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
                --pgsql-user=$USER \
                --threads=10 \
                --pgsql-password=$PASSWORD \
                --pgsql-db=$DATABASE \
                prepare
                ;;
        r) # read
            sysbench oltp_read_only \
                --tables=10 \
                --table-size=$TABLESIZE \
                --db-driver=pgsql \
                --pgsql-host=$HOST \
                --pgsql-port=$PORT \
                --pgsql-user=$USER \
                --pgsql-password=$PASSWORD \
                --pgsql-db=$DATABASE \
                --threads=16 \
                --report-interval=2 \
                --time=60 \
                run
                ;;
        w) # write
            sysbench oltp_write_only \
                --tables=10 \
                --table-size=$TABLESIZE \
                --db-driver=pgsql \
                --pgsql-host=$HOST \
                --pgsql-port=$PORT \
                --pgsql-user=$USER \
                --pgsql-password=$PASSWORD \
                --pgsql-db=$DATABASE \
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
                --pgsql-user=$USER \
                --pgsql-password=$PASSWORD \
                --pgsql-db=$DATABASE \
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