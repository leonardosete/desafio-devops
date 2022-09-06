## Criado por Leonardo Sete ##

## INSTALAÇÃO DO GCLOUD CLI ##
Será necessário em primeiro lugar (caso não possua), baixar o [gcloud_CLI] através desse link:
https://cloud.google.com/sdk/docs/install


### /DETALHE IMPORTANTE ###
A abordagem adotada nesse projeto, parte do princípio que será utilizada uma [conta_nova] da GCP [recomendado],
sem projetos/serviços/APIs configurados. Por essa razão, foram criados 5 scripts [bash] para realizar o processo que acreditei
serem básicos para a configuração do ambiente na GCP. 
### DETALHE IMPORTANTE/ ###

## CRIAÇÃO DE UM NOVO PROJETO GCP E OUTROS SERVIÇOS/APIS NECESSÁRIOS PARA O CENÁRIO DE TESTE ##
- Após realizado o [fork] do repositório no GitHub, execute em sua máquina o bash script a seguir:
    * Path = "./scripts"

    * 1-create-project.sh [mandatório] - Criará os primeiros recursos necessários para dar início ao projeto.
         * 2-external-static-ip.sh [mandatório] - Definirá 3 IPs estáticos (externos) - usará nos LBs do GKE/Ingress Controller.
            - 3 IPs = 3 Load Balancers = 1 para cada ambiente (dev/hlg/prd)

    * 3-buy-domain.sh [opcional] - Fará a compra de um domínio através da GCP e ativará o serviço Cloud DNS do Google.
        - Defina um domínio para que seja verificado e estando disponível, basta seguir com o processo de configuração
            do Cloud DNS e posteriormente, a compra do domínio.
            * Caso não queria adquirir um domínio (usando uma conta free da GCP), é possível utilizar o que já possuir.
    
    * 4-set-dns-records.sh [opcional] - Criará registros na zona de DNS do Google - Cloud DNS.
        - Execute o script 3 vezes para definir as 3 entradas/registros necessárias.
            * entradas a serem definidas, por exemplo:
                - flask-app-tembici-dev.[dominio]
                - flask-app-tembici-hlg.[dominio]
                - flask-app-tembici-prd.[dominio]
            
            * Esses hostnames estão pré-definidos nos arquivos/manifestos do k8s:
                - tembici-desafio-devops/k8s/deploy-dev.yaml -> definir o mesmo valor que for atribuído no DNS
                - tembici-desafio-devops/k8s/deploy-hlg.yaml -> definir o mesmo valor que for atribuído no DNS
                - tembici-desafio-devops/k8s/deploy-prd.yaml -> definir o mesmo valor que for atribuído no DNS

        - Caso não tenha executado o script 3 e não queira ativar esse serviço, precisará configurar em uma zona já existente
        [manualmente] o registro dos 3 IPs estáticos, para que possamos acessar a aplicação de teste no final, via hostname.
            Seguirá a mesma lógica sobre a definição dentro dos arquivos/manifestos, quanto na zona de DNS.

        - A definição do registro será preciso para a etapa de geração de certificado SSL
             que está na parte do deploy/criação dos recursos do K8s (GKE).

## ORIENTAÇÃO PÓS USO DOS SCRIPTS ##

[1-create-project.sh]

- Variáveis importantes:
    * [NEW_PROJECT_ID] = Essa variável já está definida, mas se desejar alterar, é importante ler as orientações
    ao término do script, sobre os arquivos que precisam estar com essa mesma informação para tudo funcionar
    corretamente.
    
    * [BUCKET_NAME] = Por padrão, será o mesmo nome do projeto [NEW_PROJECT_ID], mas caso dê algum erro (nome de bucket já em uso),
    basta alterá-la dentro do script [1-create-project.sh].

Ao término da execução do script, será gerado o arquivo [svc-$NEW_PROJECT_ID-private-key.json].

Esse arquivo será utilizado na etapa seguinte:
- Configurando Secrets no Repositório:
    * No github, na home do projeto/repositório que foi realizado o fork, clique na opção [Settings] que fica ao lado de [Insights];
    * Dentro das opções na coluna [General], navegue na sessão até chegar na opção "Actions": [Security] >> [Secrets] >> [Actions];
    * Clique em [New Repository Secret] >> Crie um nome baseado na finalidade dessa secret:
        - Defina: [GCP_TERRAFORM_SVC_ACCOUNT] ## Esse é o valor configurado nos arquivos de workflows.
    * Em [Value], cole o conteúdo do arquivo [svc-$NEW_PROJECT_ID-private-key.json] e clique em [Add Secret].

Feito isso, agora seu projeto/repo terá o acesso necessário para quando for executar os workflows do GitHub Actions.


### NOTA IMPORTANTE ###
 Os arquivos abaixo, todos [DEVEM] estar com o mesmo valor que foi definido na variável [$NEW_PROJECT_ID]
 * tembici-desafio-devops/.github/workflows/1-gke.yaml ->> PROJECT_ID: [colocar_nome_do_projeto]
 * tembici-desafio-devops/.github/workflows/2-flasp-app.yaml  ->> PROJECT_ID: [colocar_nome_do_projeto]
 * tembici-desafio-devops/k8s/deploy-dev.yaml  ->> us-central1-docker.pkg.dev/[valor_antigo] == us-central1-docker.pkg.dev/[colocar_nome_do_projeto]
 * tembici-desafio-devops/k8s/deploy-hlg.yaml  ->> us-central1-docker.pkg.dev/[valor_antigo] == us-central1-docker.pkg.dev/[colocar_nome_do_projeto]
 * tembici-desafio-devops/k8s/deploy-prd.yaml  ->> us-central1-docker.pkg.dev/[valor_antigo] == us-central1-docker.pkg.dev/[colocar_nome_do_projeto]
 * tembici-desafio-devops/terraform-gke/provider.tf  ->> bucket = "[valor_antigo]" == bucket = "[colocar_nome_do_projeto]"
 * tembici-desafio-devops/terraform-gke/variables.tf ->> default = "[valor_antigo]" == default = "[colocar_nome_do_projeto]"

## DICA ##
## Esse comando pode ajudar na substituição dos valores antigos pelos novos ###
find ** -type f -print0 | xargs -0 sed -i "" "s/OLD_VALUE/NEW_PROJECT_ID/g"
                                                [valor_antigo]/[novo_nome_do_projeto]
### FIM DA NOTA ###

### GITHUB ACTIONS FILES ###

Foram gerados alguns workflows (pipelines/esteiras) no path:

-  ./github/workflows:
    * 1-gke.yaml 
    * 2-flask-app.yaml


## OBSERVAÇÃO SOBRE OS WORKFLOWS ##
* Ambos foram definidos para serem executados somente em cenários específicos:

## Será executado apenas de forma manual ou via pull request para o branch deploy-infra ##
name: 1-CREATE-INFRA-GKE
on:
  pull_request:
    branches: [deploy-infra]
  workflow_dispatch:

## Será executado apenas de forma manual ou via push para os branches = release, feature, hotfix, taska ##
name: 2-DEPLOY-FLASK-APP
on:
  push:
    branches: [release, feature, hotfix, task]
  workflow_dispatch:


* Essa abordagem pode ser modificada de acordo com a necessidade/entendimento de cada projeto.
  Deixei dessa forma para "dificultar" um pouco no caso da criação/destruição da infra e 
  no caso do deploy, baseado em minha experiência com os times que atuei.

### EXECUTANDO GITHUB ACTIONS WORKFLOWS ###
    Pela console do github (web), na aba de "Actions", haverá 2 opções de workflows conforme descrito acima:

- 1-CREATE-INFRA-GKE ->> Responsável por executar o Terraform que criará o cluster GKE.
    * Para executar, basta selecionar o workflow e ir em [Run_workflow]
    * Deixar no branch master e clicar em [Run_workflow] na caixinha verde.

    - Existe duas opções de checkbox que servem para [destruir] o cluster, portanto use somente
    se for essa a intenção.

- 2-DEPLOY-FLASK-APP ->> Responsável por realizar o fluxo de CI/CD do App.  
    * Ao término da criação do cluster, ja será possível executar o segundo workflow [2-DEPLOY-FLASK-APP]
        * Com isso, será possível realizar a criação dos recursos necessários para rodar o app:
        - build
        - teste
        - publish
        - deploy (existe a necessidade de aprovação no fluxo - através de issue aberta automaticamente)
            * criará os recursos no GKE: 
                - Load Balancers através do ingress controller [gce]
                - criará os namespaces, deployments, services, hpa, ingress resources, managed certificate [criará_os_certificados_no_GCP]
    * deploy ->> aprovação:
        - é necessário configurar no arquivo "CODEOWNERS" os usuários que podem aprovar ou negar o fluxo de deploy.

###### NOTAS ####
## Construção do Cluster GKE ##
- Utilizado o Terraform para provisionar a infraestrutura necessária para cenário de teste.
    * Documentações de apoio/referência: 
        https://learnk8s.io/terraform-gke
        https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/private-cluster

## gcloud CLI ##
https://cloud.google.com/sdk/gcloud


## Github Actions ##
https://trstringer.com/github-actions-manual-approval/