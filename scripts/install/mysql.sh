#/bin/sh

check_dir_exists() {
    if [ -d "mysql-server" ]; then
        echo "mysql directory already exists"
        exit 0
    fi
}

check_dir_exists
git clone --depth=1 https://github.com/mysql/mysql-server.git