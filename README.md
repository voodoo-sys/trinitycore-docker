# trinitycore-docker

### Overview

Dockerized build and run for trinitycore master branch.

https://github.com/TrinityCore/TrinityCore

### Instruction

1. build trinitycore-server image (see ./trinitycore-server:latest/README.md)

2. build trinitycore-db image (see ./trinitycore-db:latest/README.md)

3. extract client data (see ./trinitycore-server:latest/README.md)
   - this will probably take a long time

4. edit trinitycore/trinitycore-bnetserver.env
   - replace the `__IP_ADDRESS__` with ip address of your pc/server

```
BNETSERVER_CONF='LoginREST.LocalAddress=__IP_ADDRESS__|LoginRESTExternalAddress=__IP_ADDRESS__'
```

5. run the trinitycore

```
cd ./trinitycore
docker-compose up -d
```

6. patch realmlist

once databases are populated in step 5, patch the realmlist - replace `__IP_ADDRESS__` with ip address of your pc/server

```
docker exec -it trinitycore-db mysql -u trinity -ptrinity -h 127.0.0.1 -P 3306 -e 'UPDATE auth.realmlist SET address = "__IP_ADDRESS__", localAddress = "__IP_ADDRESS__";'
```

### Hints

Attach to worldserver console

```
docker attach trinitycore-worldserver
```


Detach from console

```
Ctrl + P
Ctrl + Q
```
