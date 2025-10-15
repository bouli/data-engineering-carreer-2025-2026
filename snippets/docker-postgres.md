```shell
docker run -it \
    -e POSTGRES_USER=<*_user> \
    -e POSTGRES_PASSWORD=<*_password> \
    -e POSTGRES_DB=<*_database_name> \
    -p <*_local_port_5432>:5432 \
    -v $(pwd)/local_folder:/var/lib/postgresql/data \
    --name <instance_name> \
    --network=<network_name> \
    postgres:<version>
```
