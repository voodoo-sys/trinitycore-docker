# trinitycore-db:ubuntu-20.04

### Building

```
docker build --tag trinitycore-db:latest .
```

### Running

```
docker run -it --rm --net host -e MARIADB_RANDOM_ROOT_PASSWORD=true trinitycore-db:latest
```
