FROM python:3.6-slim-buster

WORKDIR /app
COPY base-test-api /app

RUN pip3 install --upgrade pip
RUN pip3 install pipenv 
RUN pipenv install

EXPOSE 8080

CMD ["pipenv", "run", "python", "start.py", "runserver"]
