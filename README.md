## desafio devops.

O critério de avaliação desse teste é analisar as formas de pensar, organizar e desenvolver do candidato, qualidade de código e simplicidade serão avaliados também. Sinta-se livre para desenvolver linhas de raciocino, comentar, etc... E em caso de dúvidas, nos envie um email.

## forma de entrega.

Fork o repositório e altere o arquivo ANSWERS.md com as respostas e observações que achar necessário para rodar o código e possíveis considerações adicionais.

## objetivos.
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

Dito isso, você deverá Dockerizar a aplicação e provisionar os recursos necessarios na GCP (será um adicional se utilizar Terraform), de forma que possamos recriar toda sua infraestrutura em nossa conta de forma simples. também faz parte do escopo colocar esta aplicação em um fluxo de CI que realize teste neste código e o deploy da aplicação. Leve em conta que seria um ambiente muito próximo à produção, portanto, escalabilidade, segurança, monitoramento e logging será levado em consideração na nossa análise. Sinta-se livre para usar as ferramentas que julgue necessário.

**Boa sorte!**
