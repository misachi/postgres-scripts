#!/bin/sh

set -eux

CORE_DUMP_DIR="/tmp"

check_version() {
if [ "$VERSION_STR" = "" ]; then
    echo "Image version is not set. We'll default to '0.0.1'"
    VERSION_STR=0.0.1
fi
}

run_container() {
    docker run -d \
        --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -p 5432:5432 \
        --init --ulimit core=-1 --mount type=bind,source=${CORE_DUMP_DIR},target=${CORE_DUMP_DIR} \
        --name postgres-test-${VERSION_STR} postgres/test-${VERSION_STR} /bin/bash -c '/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data -l logfile start && tail -f /dev/null'
}

echo "Core dumps directory set to ${CORE_DUMP_DIR}"
echo "${CORE_DUMP_DIR}/core.%e.%t" | sudo tee /proc/sys/kernel/core_pattern

while getopts ":br" option; do
    case $option in
        b) # build image and run container
            check_version
            echo "Building Postgres Image for version ${VERSION_STR}"

            if [ -d "postgres" ]; then
                docker build -f postgres/Dockerfile -t postgres/test-${VERSION_STR} .
            else
                docker build -t postgres/test-${VERSION_STR} .
            fi
            run_container
            ;;
        r) # Only Run Container
            check_version
            run_container
            ;;
        \?) # Invalid Option
            echo "Invalid Option"
            exit;;
    esac
done
