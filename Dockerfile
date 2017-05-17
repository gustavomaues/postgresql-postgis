FROM debian

MAINTAINER Gustavo Lobato<gustavomaues@gmail.com>

ENV PATH=/opt/postgresql/bin:$PATH; \
    LD_LIBRARY_PATH=/opt/postgresql/bin:$LD_LIBRARY_PATH; \
    PGDATA=/opt/postgresql/data

RUN apt-get update; 

# Instale as dependências:
RUN apt-get install --yes libreadline6-dev build-essential zlib1g-dev \
    libxml2 libxml2-dev libproj-dev libjson0-dev libgdal1-dev libgeos-3.5.0
    
RUN wget -c -P /usr/local/src/ https://ftp.postgresql.org/pub/source/v9.6.3/postgresql-9.6.3.tar.gz; \
    tar xvzf /usr/local/src/postgresql-9.6.3.tar.gz -C /usr/local/src/; \
    cd postgresql-9.6.3/; \
    ./configure --prefix=/opt/postgresql/; \
    make -j `grep -c cpu[0-9] /proc/stat`; \
    make install;\
    ln -s /opt/postgresql /usr/local/pgsql; \
    useradd --system --user-group --no-create-home -p postgres --shell /bin/bash postgres; \
    mkdir /usr/local/pgsql/data; \
    chown postgres. -R /usr/local/pgsql/data/; \
    ln -s /usr/local/pgsql/lib/* /usr/local/lib/; \
    cp /usr/local/src/postgresql-9.6.3/contrib/start-scripts/linux /etc/init.d/postgresql; \
    chmod +x /etc/init.d/postgresql; \
    wget -c -P /usr/local/src/ http://postgis.net/stuff/postgis-2.3.3dev.tar.gz; \
    tar xvzf /usr/local/src/postgis-2.3.3dev.tar.gz -C /usr/local/src/; \
    cd /usr/local/src/postgis-2.3.3dev/; \
    ./configure --prefix=/opt/postgis --with-pgconfig=/opt/postgresql/bin/pg_config; \
    make; \
    make install; \
    rm -R /usr/local/src/postgresql-9.6.3.tar.gz /usr/local/src/postgis-2.3.3dev.tar.gz

USER postgres

RUN initdb -E utf8 --locale=pt_BR.utf8 -D $PGDATA
