# Mounts data volume on XFS filesystem

docker volume create --opt type=none --opt o=bind --opt device=/mnt/xfs_d/pg18 xfs_pg18_1

docker run -d \
        --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -p 5432:5432 -v xfs_pg18_1:/usr/local/pgsql \
        --init --ulimit core=-1 --mount type=bind,source=${CORE_DUMP_DIR},target=${CORE_DUMP_DIR} \
        --name postgres-test-${VERSION_STR} postgres/test-${VERSION_STR} /bin/bash -c 'if [ ! -d "/usr/local/pgsql/data" ]; then /usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data initdb; fi && /usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data -l logfile start && tail -f /dev/null'


# docker run -d \
#         --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -p 5432:5432 \
#         --init --ulimit core=-1 --mount type=bind,source=${CORE_DUMP_DIR},target=${CORE_DUMP_DIR} \
#         --name postgres-test-${VERSION_STR} postgres/test-${VERSION_STR} /bin/bash -c 'if [ ! -d "/usr/local/pgsql/data" ]; then /usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data initdb; fi && /usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data -l logfile start && tail -f /dev/null'
