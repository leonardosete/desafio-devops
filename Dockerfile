# start by pulling the python image
FROM python:3.6-alpine

# Run Tests
ENV BASE_API_ENV=test pipenv run pytest

# switch working directory
WORKDIR /app

# install the dependencies and packages in the requirements file
RUN pip install pipenv

# copy every content from the local file to the image
COPY ./base-test-api /app

# configure the container to run in an executed manner
ENTRYPOINT [ "python" ]

CMD ["pipenv run python start.py runserver" ]
