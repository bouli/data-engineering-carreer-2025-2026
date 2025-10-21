FROM python:3.9

WORKDIR /app

COPY ingestion-data.py ingestion-data.py
COPY requirements.txt requirements.txt

RUN apt-get update && apt-get install -y wget
RUN pip install -r requirements.txt

ENTRYPOINT [ "python", "ingestion-data.py" ]
