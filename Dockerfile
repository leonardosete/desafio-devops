FROM python:3.6-slim

COPY base-test-api/Pipfile ./
RUN pip3 install --upgrade pip
RUN pip3 install pipenv && pipenv install

WORKDIR /app
COPY base-test-api /app

ENTRYPOINT ["pipenv", "run", "python", "start.py", "runserver"]