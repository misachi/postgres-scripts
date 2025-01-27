#/bin/sh

check_pg_exists() {
    if [ -d "postgres" ]; then
        echo "postgres directory already exists"
        exit 1
    fi
}

check_pg_exists
git clone https://github.com/postgres/postgres.git