FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install

COPY . /app

EXPOSE

ENTRYPOINT ["entrypoint.sh"]
