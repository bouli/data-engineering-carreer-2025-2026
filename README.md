# Studies Plan w/ Mentor 2025/2026

This project is used as an intent to refresh my knoledge in Data Engineering.
Course: https://github.com/DataTalksClub/data-engineering-zoomcamp


#### Many thanks to @cassiobolba who is helping me in this journey.

----
## First Approach to Docker

First, let's have a quick check in a Dockerfile and a simple usage.
> [Dockerfile](Dockerfile)
```Dockerfile
FROM python:3.9

WORKDIR /app

COPY pipeline.py pipeline.py

RUN pip install pandas

ENTRYPOINT [ "bash" ]
```

## Creating a Postgres Instance and Ingesting Data

### Creating Postgres Instance with Docker

The first task is to create a __Postgres__ instance using __Docker__. For this class we are using _postgres:13_ .

In your _terminal_, type this:
> [snippets/docker-postgres.md](snippets/docker-postgres.md)
```shell
docker run -it \
    -e POSTGRES_USER=root \
    -e POSTGRES_PASSWORD=root \
    -e POSTGRES_DB=ny_taxi \
    -p 5432:5432 \
    -v $(pwd)/ny_taxi_data_postgres_data:/var/lib/postgresql/data \
    postgres:13
```

### Testing Postgress connection

It's a good idea check connection with _Postgres DB_. The class suggest to use __pgcli__ we can find on using pip. So on __terminal__:
```shell
pip install pgcli
pgcli -u root -h localhost -p 5432 -d ny_taxi
```

### Create table and insert data on Postgres

Let's create the table based on the CSV we have download from NYC TLC https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page . Nowadays, they are using _paquet_. I know we can use paquet directely, but for "academic purposes", I'm converting to CSV:

> [convertion-parquet_to_csv.py](convertion-parquet_to_csv.py)
```python
import pandas as pd
import sys

if len(sys.argv) == 3:
    df = pd.read_parquet(sys.argv[1])
    df.to_csv(sys.argv[2], index=False)
else:
    print("!!! Usage: python parquet_to_csv.py <input_file> <output_file>")
```

On _terminal_:
```shell
python convertion-parquet_to_csv.py raw_data/yellow_tripdata_2021-01.parquet raw_data/yellow_tripdata_2021-01.csv
```

Than, we read the CSV, in this case, just 100 lines, to define our _schema_. We convert the fields we need to datetime (this ones are read as text from pandas for _CSV_. In _parquet_ it wouldn't be necessary.), and create the table at the database. (SQLAlchemy is a helper to check what's happening)


> [ingestion-data.py](ingestion-data.py)
```python
import pandas as pd
from sqlalchemy import create_engine
import math

print('creating table')
df = pd.read_csv('raw_data/yellow_tripdata_2021-01.csv', nrows=100)

engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')

df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

print('schema', pd.io.sql.get_schema(df, 'ny_taxi', con=engine))

df.head(n=0).to_sql(name='yellow_taxi_data', con=engine, if_exists='replace')
```

And finally we insert data. using interator. The video uses an exception to stop the data insertion loop, but I decided to make it a little bit more elegant.


> [ingestion-data.py](ingestion-data.py)
```python
print('inserting data')
n_lines = len(pd.read_csv('raw_data/yellow_tripdata_2021-01.csv'))
chunksize = 100000

df_iter = pd.read_csv('raw_data/yellow_tripdata_2021-01.csv', iterator=True, chunksize=chunksize)
for i in range(math.ceil(n_lines / chunksize)):
    df = next(df_iter)
    df.to_sql(name='yellow_taxi_data', con=engine, if_exists='append')
    print(f'chunk {i + 1} from {math.ceil(n_lines / chunksize)} inserted')

print('insertion finished')

```
## Managing Postgres with PGADMIN

Now it's time to add a pg-admin, a web-based tool to manage postgres databases. \
Since we are using Docker and pg-admin it's a different container, we need to
connect them using a Docker Network.

### Creating a docker network;
> [snippets/docker-network.md](snippets/docker-network.md)
```shell
docker network create pg-network
```

### Installing, configuring and using of pg-admin;
> [snippets/docker-pgadmin.md](snippets/docker-pgadmin.md)
```shell
docker run -it \
    -e PGADMIN_DEFAULT_EMAIL=admin@admin.com \
    -e PGADMIN_DEFAULT_PASSWORD=root \
    -p 8080:80 \
    --name pg-admin \
    --network=pg-network \
    dpage/pgadmin4
```

----
## Dockerizing Our Script

Now, let's "dockerize" our data ingestion script. \
In the past script, the program is depending on us to convert the parquet files
and to execute the script. Here we are, first, changing the way to execute and
to making it more "customizible". We add the possibility to pass parameters to
the script via bash using the native lib [`argparse`](https://docs.python.org/3/library/argparse.html), receiving the parameters,
passing to a function _main()_ to finally execute it:
> [ingestion-data.py](ingestion-data.py)
```python
import argparse
# (...)

def main(params):
    user=params.user
    password=params.password
    host=params.host
    port=params.port
    db=params.db
    table_name=params.table_name
    url_file=params.url_file

    # (...)

parser = argparse.ArgumentParser(
    description='Ingest CSV or Parquet file data to a Postgres table',
)

if __name__ == '__main__':
    parser.add_argument('--user', help='user name for postgres', default='root')
    parser.add_argument('--password', help='password for postgres', default='root')
    parser.add_argument('--host', help='host for postgres', default='localhost')
    parser.add_argument('--port', help='port for postgres', default='5432')
    parser.add_argument('--table_name', help='name of the table to write data to', required=True)
    parser.add_argument('--db', help='database name for postgres', required=True)
    parser.add_argument('--url_file', help='url to the csv or parquet file', required=True)

    args = parser.parse_args()
    main(args)

```

Let's try to make the things a little bit clear to our user and for future debugging
making logs! For this, we will use the simple native lib [`logging`](https://docs.python.org/3/library/logging.html):

> [ingestion-data.py](ingestion-data.py)
```python
import logging
# (...)

logging.basicConfig(level=logging.INFO)
# (...)
    def main(args)
    # (...)
    logger = logging.getLogger()
    logger.info("Ingestion-Data script started")
    # (...)
```

Let's update our [Dockerfile](Dockerfile) to install the our script dependencies:

> [Dockerfile](Dockerfile)
```Dockerfile
FROM python:3.9

WORKDIR /app

COPY ingestion-data.py ingestion-data.py
COPY requirements.txt requirements.txt

RUN apt-get update && apt-get install -y wget
RUN pip install -r requirements.txt

ENTRYPOINT [ "python", "ingestion-data.py" ]

```

Now, let's build our Docker image:
> [snippets/docker-build.md](snippets/docker-build.md)
```shell
docker build -t url2pg:v0.0.2 .
```

And finally test and execute it:

> [snippets/docker-data-ingestion.md](snippets/docker-data-ingestion.md)
```shell
docker run -it \
    --network=pg-network \
    --name taxi_ingest_container \
    url2pg:v0.0.2 \
    --user=root \
    --password=root \
    --host=pg-database \
    --port=5432 \
    --db=ny_taxi \
    --table_name=yellow_taxi_data \
    --url_file=https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2021-01.parquet
```

----
## Using Docker Compose

Let's make our first `docker-compose` file to start our database and pg-admin:

> [docker-compose.yaml](docker-compose.yaml)
```yaml
services:
  pg-database:
    image: postgres:13
    environment:
      - POSTGRES_USER=root
      - POSTGRES_PASSWORD=root
      - POSTGRES_DB=ny_taxi
    ports:
      - "5432:5432"
    volumes:
      - "./ny_taxi_postgres_data:/var/lib/postgresql/data:rw"
  pg-admin:
    image: dpage/pgadmin4
    environment:
      - PGADMIN_DEFAULT_EMAIL=admin@admin.com
      - PGADMIN_DEFAULT_PASSWORD=root
    ports:
      - "8080:80"

```
And than we just execute docker compose:

> [docker-compose-up.md](docker-compose-up.md)
```shell
docker compose up
```

In this case, we don't need to specify the network, docker compose creates it's
own network. \
To understand better, I deleted the default network and tried to start compose
again. We will have an error. For these, we need to force the recreation:

> [docker-compose-up.md](docker-compose-up.md)
```shell
docker compose up --force-recreate
```

----
## Pushing to Docker Hub

I decided to add this docker image in my docker hub profile.
So, I created the repository at hub, and pushed my image:
> [snippets/docker-push.md](snippets/docker-push.md)
```shell
docker push cesarbouli/url2pg:v0.0.2
```

Docker Hub Repository: [https://hub.docker.com/r/cesarbouli/url2pg](https://hub.docker.com/r/cesarbouli/url2pg)
