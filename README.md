Scripts I use when tinkering with Postgres. Contains scripts for downloading Postgres from source, compiling and running in a docker container. Also contains scripts for running [sysbench](https://github.com/akopytov/sysbench) for simple workloads(reads, writes, and read/writes).
Can be useful for testing how different Postgres configurations affect performance(queries, transactions etc), when running with Sysbench

**This has only been tested on a machine running Ubuntu Linux(specifically Ubuntu jammy, but should probably work on most Ubuntu platforms)**

Some requirements are:
1. Make build tool (apt get install make)
2. Docker (can be installed with `make install_docker` or check the [docker page](https://docs.docker.com/engine/install/ubuntu/))
3. Sysbench (can be installed with `make install_sysbench`)


These environment variables would need to be set before running below commands:

1. PORT - port the postmaster will be listening on(default 5432)
2. USER, DATABASE, PASSWORD - To be used by Sysbench. Should all probably be set to `sbtest`
3. HOST - IP address of the instance running the Postgres server
4. TABLESIZE - How big the tables for running with Sysbench should be. Each table will have `TABLESIZE` rows
5. MY_IP - IP address of the client(Where Sysbench will be run from)

Example:
```
export PORT=5432
export USER=sbtest
export DATABASE=sbtest
export PASSWORD=sbtest
export HOST=192.168.44.21
export TABLESIZE=1000000
export MY_IP=192.168.44.21
```

Some useful commands:

```
make build # will download current postgres from source and set up a running postgres container

make sys_prep # will setup requirements for sysbench(creates sbtest user and database) -- requires Sysbench

make sys_read # Runs a simple read only workload -- requires Sysbench

make sys_write # Runs a simple write only workload -- requires Sysbench

make sys_read_write # Runs a simple mix of read and write workloads -- requires Sysbench
```