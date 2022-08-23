FROM python:3.10-slim-buster

WORKDIR /app

COPY requirements.txt requirements.txt

RUN python3 -m venv tutorial-env
RUN source tutorial-env/bin/activate

RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt

COPY . .

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]