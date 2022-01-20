# trinitycore-server:latest

### Building

```
docker build --tag trinitycore-server:latest .
```

### Extracting client data

replace "/path/to/world\ of\ warcraft\ client\ directory" with your own path to client directory

```
docker volume create trinitycore-worldserver-data

docker run -it --rm -e TC_COMPONENT=dataextract \
--mount source=trinitycore-worldserver-data,target=/srv/trinitycore/data \
-v /path/to/world\ of\ warcraft\ client\ directory:/srv/trinitycore/client \
trinitycore-server:latest
```

because this operation takes a long time, you should rather run it detached

```
docker volume create trinitycore-worldserver-data

docker run -d -it --rm -e TC_COMPONENT=dataextract \
--mount source=trinitycore-worldserver-data,target=/srv/trinitycore/data \
-v /path/to/world\ of\ warcraft\ client\ directory:/srv/trinitycore/client \
trinitycore-server:latest
```

### Running bnetserver

```
docker run -it --rm --net host -e TC_COMPONENT=bnetserver \
trinitycore-server:latest
```

### Running worldserver

```
docker run -it --rm --net host -e TC_COMPONENT=worldserver -e WORDLSERVER_CONF='DataDir="../data"' \
--mount source=trinitycore-worldserver-data,target=/srv/trinitycore/data \
trinitycore-server:latest
```

### Environment

* WORLDSERVER_CONF

  * Default:
  * Description: Pipe separated pairs variable=value for worldserver.conf (lines starting with `variable =` will be replaced, otherwise will be appended)
  * Example: `WORLDSERVER_CONF='DataDir=../data'`


* BNETSERVER_CONF

  * Default:
  * Description: Pipe separated pairs variable=value for bnetserver.conf (lines starting with `variable =` will be replaced, otherwise will be appended)
  * Example: `BNETSERVER_CONF='LoginREST.LocalAddress=192.168.1.10|LoginRESTExternalAddress=192.168.1.10'`


* TC_COMPONENT

  * Default:
  * Description: Which trinitycore component should be run. Supported values: bnetserver, worldserver, dataextract
  * Example: `TC_COMPONENT=dataextract`


* TC_DB_USER

  * Default: trinity
  * Description: Trinitycore database user
  * Example:

* TC_DB_PASSWORD

  * Default: trinity
  * Description: Trinitycore database password
  * Example:


* TC_DB_HOST

  * Default: 127.0.0.1
  * Description: Trinitycore database host
  * Example:


* TC_DB_PORT

  * Default: 3306
  * Description: Trinitycore database post
  * Example:


* TC_DB_WAIT

  * Default: 300
  * Description: How long (in seconds) to wait for database before running bnetserver or worldserver
  * Example:
