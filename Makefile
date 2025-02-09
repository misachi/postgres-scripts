install_docker:
	./scripts/install/docker.sh

install_sysbench:
	./scripts/install/sysbench.sh

install_pg:
	@echo "Downloading Postgres from source"
	@./scripts/install/pg.sh
	@cp Dockerfile postgres

build_pg:
	@echo "Building PG Image"
	@./scripts/install_pg.sh -b

run_pg:
	@./scripts/install_pg.sh -r

build: install_pg build_pg

sys_prep:
	@-./scripts/sysbench.sh -c
	@-./scripts/sysbench.sh -p

sys_read:
	@./scripts/sysbench.sh -r

sys_write:
	@./scripts/sysbench.sh -w

sys_read_write:
	@./scripts/sysbench.sh -m

build_mysql:
	@echo "Downloading Mysql from source"
	@./scripts/install/mysql.sh
	@docker build --no-cache -t mysql/test-0.0.1 -f Dockerfile.mysql .

run_mysql:
	@echo "Creating mysql container"
	@docker run -d -p 3306:3306 --restart=always --cap-add=CAP_SYS_NICE --cap-add=SYS_PTRACE --name mysql-0.0.1 \
		mysql/test-0.0.1 /bin/bash -c 'if [ ! -d "/usr/local/mysql/data" ]; then /usr/local/mysql/bin/mysqld --initialize --user=mysql; fi && rm -f /usr/local/mysql/data/`hostname`.pid && /usr/local/mysql/bin/mysqld_safe --malloc-lib=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4.5.16 --pid-file=/usr/local/mysql/data/`hostname`.pid --user=mysql'

sys_mysql_prep:
	@-./scripts/sysbench_mysql.sh -p

sys_mysql_read:
	@./scripts/sysbench_mysql.sh -r

sys_mysql_write:
	@./scripts/sysbench_mysql.sh -w

sys_mysql_read_write:
	@./scripts/sysbench_mysql.sh -m

clean:
	@echo "Removing postgres directory"
	@-rm -rf postgres

clean_mysql:
	@echo "Removing mysql directory"
	@-rm -rf mysql-server
