```shell
docker run -it \
    --network=<*_destiny_network> \
    url2pg:v0.0.2 \
    --user=<postgres_user:default=root> \
    --password=<postgres_password:default=root> \
    --host=<postgres_host:default=localhost> \
    --port=<postgres_port:default=5432> \
    --db=<*_db> \
    --table_name=<*_destiny_table> \
    --url_file=<*_source_url>
```
