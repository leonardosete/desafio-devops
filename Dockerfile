FROM python:3.6

RUN apt-get update && python -m pip install --upgrade pip

COPY base-test-api/* /app/

WORKDIR /app

RUN pip3 install pipenv && pipenv install

ENV ASPNETCORE_URLS=http://+:8080 DOTNET_RUNNING_IN_CONTAINER=true

EXPOSE 8080

ENTRYPOINT ["pipenv", "run", "python", "start.py", "runserver"]