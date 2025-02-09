#/bin/sh

check_pg_exists() {
    if [ -d "postgres" ]; then
        echo "postgres directory already exists"
        exit 0
    fi
}

check_pg_exists
git clone --depth=1 https://github.com/postgres/postgres.git