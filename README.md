## APP ##
Dentro do repositório tem uma aplicação Flask bem simples, é uma API que responde pong à rota /ping.

#### Para executar a aplicação é necessário python 3.6 e o pipenv, rode os seguintes comandos:
```
pipenv install
pipenv run python start.py runserver
```

#### Para executar os testes da aplicação rode o comando:
```
BASE_API_ENV=test pipenv run pytest
```

