## ================================================================================
## ubuntu-base
## ================================================================================

FROM ubuntu:20.04 AS trinitycore-base

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git clang cmake make gcc g++ p7zip-full tzdata curl wget mariadb-client \
    libmariadbclient-dev \
    libssl-dev libbz2-dev \
    libreadline-dev \
    libncurses-dev libboost-all-dev \
    libmariadb-client-lgpl-dev-compat && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang 100

## ================================================================================
## trinitycore-build
## ================================================================================

FROM trinitycore-base AS trinitycore-build

RUN cd /srv && git clone -b master https://github.com/TrinityCore/TrinityCore.git trinitycore-source
## $(nproc)
RUN cd /srv/trinitycore-source && \
    mkdir build && \
    cd ./build && \
    cmake ../ -DCMAKE_INSTALL_PREFIX=/srv/trinitycore && \
    make -j 4 && \
    make -j 4 install && \
    make clean

## ================================================================================
## trinitycore-server
## ================================================================================

FROM trinitycore-build

COPY entrypoint.sh /srv/trinitycore/entrypoint.sh
RUN chmod +x /srv/trinitycore/entrypoint.sh
RUN mv -f /srv/trinitycore/etc/worldserver.conf.dist /srv/trinitycore/etc/worldserver.conf && \
    mv -f /srv/trinitycore/etc/bnetserver.conf.dist /srv/trinitycore/etc/bnetserver.conf
RUN curl -s https://api.github.com/repos/TrinityCore/TrinityCore/releases | \
    grep "browser_download_url" | \
    grep -v "world_3" | \
    head -1 | \
    cut -d '"' -f 4 | \
    wget -qi - -O /srv/trinitycore/bin/tdb.7z
RUN cd /srv/trinitycore/bin && 7z x ./tdb.7z && rm -f ./tdb.7z

CMD ["/srv/trinitycore/entrypoint.sh"]
