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

clean:
	@echo "Removing postgres directory"
	@-rm -rf postgres
