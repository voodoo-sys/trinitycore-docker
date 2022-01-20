#!/bin/bash

## ================================================================================================================================================================
## helpers
## ================================================================================================================================================================

function waitForDatabase() {

    TC_DB_USER="${TC_DB_USER:-trinity}"
    TC_DB_PASSWORD="${TC_DB_PASSWORD:-trinity}"
    TC_DB_HOST="${TC_DB_HOST:-127.0.0.1}"
    TC_DB_PORT="${TC_DB_PORT:-3306}"

    TC_DB_WAIT=${TC_DB_WAIT:-300}
    waitStart=$(date +%s)
    waitDeadline=$((waitStart + TC_DB_WAIT))

    echo -n "[Entrypoint][Info][$(logDate)] Waiting for database"
    while true; do
        mysql -u "${TC_DB_USER}" -p"${TC_DB_PASSWORD}" -h "${TC_DB_HOST}" -P "${TC_DB_PORT}" -e "select now() as time_now;" 1> /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            break;
        fi

        if [[ $(date +%s) > ${waitDeadline} ]]; then
            echo
            echo "[Entrypoint][Error][$(logDate)] Waiting for database timed out."
            exit 1
        fi
        sleep 3
        echo -n "."
    done
    echo "OK"

}

function logDate() {
    date +%Y-%m-%d\ %H:%M:%S
}

## ================================================================================================================================================================
## dataextract
## ================================================================================================================================================================

if [[ "${TC_COMPONENT}" == "dataextract" ]]; then

    set -e

    if [[ ! -d /srv/trinitycore/data ]]; then
        mkdir /srv/trinitycore/data
    fi

    if [[ ! -d /srv/trinitycore/client ]]; then
        echo "[Entrypoint][Error][$(logDate)] Client directory not found."
    fi

    cd /srv/trinitycore/client
    echo "[Entrypoint][Info][$(logDate)] Starting mapextractor."
    /srv/trinitycore/bin/mapextractor
    cp -r Cameras dbc maps gt /srv/trinitycore/data

    echo "[Entrypoint][Info][$(logDate)] Starting vmap4extractor."
    /srv/trinitycore/bin/vmap4extractor
    mkdir vmaps
    echo "[Entrypoint][Info][$(logDate)] Starting vmap4assembler."
    /srv/trinitycore/bin/vmap4assembler Buildings vmaps
    cp -r vmaps /srv/trinitycore/data

    mkdir mmaps
    echo "[Entrypoint][Info][$(logDate)] Starting mmaps_generator."
    /srv/trinitycore/bin/mmaps_generator
    cp -r mmaps /srv/trinitycore/data

    exit 0

## ================================================================================================================================================================
## bnetserver
## ================================================================================================================================================================

elif [[ "${TC_COMPONENT}" == "bnetserver" ]]; then

    ## apply changes to bnetserver.conf
    bncFile="/srv/trinitycore/etc/bnetserver.conf"
    if [[ ! -z ${BNETSERVER_CONF} ]]; then
        echo "[Entrypoint][Info][$(logDate)] Processing BNETSERVER_CONF."
        IFS1=$IFS; IFS="|";
        for sProperty in ${BNETSERVER_CONF}; do
            spVariable="${sProperty%%=*}"
                echo "[Entrypoint][Info][$(logDate)] Processing property \"${spVariable}\"."
                spLine=$(cat "${bncFile}" 2>/dev/null | grep -e "^${spVariable}=" 2>/dev/null)
                if [[ ! -z ${spLine} ]]; then
                    echo "[Entrypoint][Info][$(logDate)] Property line found in bnetserver.conf - replacing."
                    sed -i "s|${spVariable}=.*|${sProperty}|g" "${bncFile}"
                else
                    echo "[Entrypoint][Info][$(logDate)] Property line not found in bnetserver.conf - appending."
                    echo "" >> "${bncFile}"
                    echo "${sProperty}" >> "${bncFile}"
                fi
        done
        IFS=$IFS1
    fi

    waitForDatabase

    cd /srv/trinitycore/bin
    exec ./bnetserver

## ================================================================================================================================================================
## worldserver
## ================================================================================================================================================================

elif [[ "${TC_COMPONENT}" == "worldserver" ]]; then

    wscFile="/srv/trinitycore/etc/worldserver.conf"

    if [[ ! -z ${WORLDSERVER_CONF} ]]; then
        echo "[Entrypoint][Info][$(logDate)] Processing WORLDSERVER_CONF."
        IFS1=$IFS; IFS="|";
        for sProperty in ${WORLDSERVER_CONF}; do
            spVariable="${sProperty%%=*}"
                echo "[Entrypoint][Info][$(logDate)] Processing property \"${spVariable}\"."
                spLine=$(cat "${wscFile}" 2>/dev/null | grep -e "^${spVariable}[ \t]*=" 2>/dev/null)
                if [[ ! -z ${spLine} ]]; then
                    echo "[Entrypoint][Info][$(logDate)] Property line found in worldserver.conf - replacing."
                    sed -i "s|${spVariable}[ \t]*=.*|${sProperty}|g" "${wscFile}"
                else
                    echo "[Entrypoint][Info][$(logDate)] Property line not found in worldserver.conf - appending."
                    echo "" >> "${wscFile}"
                    echo "${sProperty}" >> "${wscFile}"
                fi
        done
        IFS=$IFS1
    fi

    waitForDatabase
    cd /srv/trinitycore/bin
    exec ./worldserver

fi
