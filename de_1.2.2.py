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


print('inserting data')
n_lines = len(pd.read_csv('raw_data/yellow_tripdata_2021-01.csv'))
chunksize = 100000

df_iter = pd.read_csv('raw_data/yellow_tripdata_2021-01.csv', iterator=True, chunksize=chunksize)
for i in range(math.ceil(n_lines / chunksize)):
    df = next(df_iter)
    df.to_sql(name='yellow_taxi_data', con=engine, if_exists='append')
    print(f'chunk {i + 1} from {math.ceil(n_lines / chunksize)} inserted')

print('insertion finished')
