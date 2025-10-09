# Class DE 1.2.2

Video: https://www.youtube.com/watch?v=2JM-ziJt0WI&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=4

### Creating Postgres Instance with Docker

The first task is to create a __Postgres__ instance using __Docker__. For this class we are using _postgres:13_ .

In your _terminal_, type this:
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


```python
# de_1.2.2.z-parquet_to_csv.py
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
python parquet_to_csv.py raw_data/yellow_tripdata_2021-01.parquet raw_data/yellow_tripdata_2021-01.csv
```

Than, we read the CSV, in this case, just 100 lines, to define our _schema_. We convert the fields we need to datetime (this ones are read as text from pandas for _CSV_. In _parquet_ it wouldn't be necessary.), and create the table at the database. (SQLAlchemy is a helper to check what's happening)


```python
# de_1.2.2.py
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


```python
# de_1.2.2.py
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
