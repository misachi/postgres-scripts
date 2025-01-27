# Set the right flag using `DOCKER_DEFAULT_PLATFORM` to build the right image for your platform
FROM ubuntu:latest

# Prepare the directories required
ENV APP_HOME=/home ID=991 USR=postgres USR_HOME=/home/postgres PG_FILES=/usr/local/pgsql/ BASH_PROFILE=/etc/bash.bashrc

# Permissions
RUN groupadd -g ${ID} ${USR} && \
    useradd -r -u ${ID} -g ${USR} ${USR}

ADD postgres ${USR_HOME}
WORKDIR ${USR_HOME}
RUN chown -R ${USR}:${USR} ${USR_HOME}


# Requirements installations
RUN apt-get update && apt-get install -y g++ gdb \
            zlib1g-dev \
            make curl \
            tar gzip \
            liblz4-dev \
            git nano \
            libreadline-dev \
            flex bison libicu-dev

# Required by LZ4
RUN apt-get install --reinstall -y pkg-config

# Build and Install Postgres
RUN CFLAGS="-O3 -ggdb3" ./configure --without-icu --enable-debug --with-lz4 && \
        make  && \
        make all && \
        make install

# Putting executables in our PATH to make things easier later
RUN echo "export PATH=$PATH:/usr/local/pgsql/bin/" >>  ${BASH_PROFILE} && \
        chown -R ${USR}:${USR} ${PG_FILES}
USER ${USR}

# Post-Installation
RUN ${PG_FILES}/bin/pg_ctl -D /usr/local/pgsql/data initdb
CMD [ "pg_ctl", "-D", "/usr/local/pgsql/data", "-l logfile", "start" ]
