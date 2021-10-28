FROM python:3.6.8

COPY requirements.txt  /app/requirements.txt
RUN pip install -r /app/requirements.txt

COPY . /app

ENTRYPOINT python /app/app.py
