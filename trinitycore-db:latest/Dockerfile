FROM mariadb:10.7.1-focal

RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*
RUN wget https://raw.githubusercontent.com/TrinityCore/TrinityCore/master/sql/create/create_mysql.sql -O /docker-entrypoint-initdb.d/0-tc_create_mysql.sql
RUN cat /docker-entrypoint-initdb.d/0-tc_create_mysql.sql | grep -e "CREATE USER" -e "GRANT" | sed 's|localhost|127.0.0.1|g' > /docker-entrypoint-initdb.d/1-tc_create_mysql.sql
RUN cat /docker-entrypoint-initdb.d/0-tc_create_mysql.sql | grep -e "CREATE USER" -e "GRANT" | sed 's|localhost|%|g' > /docker-entrypoint-initdb.d/2-tc_create_mysql.sql
