```shell
docker run -it \
    --network=<*_destiny_network> \
    url2pg:v0.0.2 \
    --user=root \
    --password=root \
    --host=<*_destiny_host> \
    --port=5432 \
    --db=<destiny-db-*> \
    --table_name=<destiny-table> \
    --url_file=<destiny-url>
```
