import pandas as pd
import sys

if len(sys.argv) == 3:
    df = pd.read_parquet(sys.argv[1])
    df.to_csv(sys.argv[2], index=False)
else:
    print("!!! Usage: python parquet_to_csv.py <input_file> <output_file>")
