FROM python:3.6

WORKDIR /app
COPY base-test-api/ /app
RUN pip3 install pipenv && pipenv install
# RUN BASE_API_ENV=test pipenv run pytest

EXPOSE 8080

ENTRYPOINT ["pipenv", "run", "python", "start.py", "runserver"]


# FROM python:3.6

# RUN apt-get update && python -m pip install --upgrade pip

# COPY base-test-api/ /app/

# WORKDIR /app

# RUN pip3 install pipenv

# RUN PIPENV_VENV_IN_PROJECT=1  pipenv install

# EXPOSE 8080

# ENTRYPOINT ["pipenv", "run", "python", "start.py", "runserver"]