```shell
docker run -it \
    -e PGADMIN_DEFAULT_EMAIL=<*_user_email> \
    -e PGADMIN_DEFAULT_PASSWORD=<*_password> \
    -p <*_local_port_5432>:80 \
    -v $(pwd)/local_folder:/var/lib/postgresql/data \
    --name <instance_name> \
    --network=<network_name> \
    dpage/pgadmin4
```
