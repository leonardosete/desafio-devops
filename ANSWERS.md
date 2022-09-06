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
    * [path:] "./scripts"
    * 1-create-project.sh [mandatório] - Criará os primeiros recursos necessários para dar início ao projeto.
    * 2-external-static-ip.sh [mandatório] - Definir IPs estáticos (externo) - usará nos LBs do GKE.
    * 3-buy-domain.sh [extras] - Se já possuir um domínio e puder utilizar, pode pular esse script.
    * 4-set-dns-records.sh [extras] - Registar no DNS a aplicação para acessar via hostname ao invés de IP.

## ORIENTAÇÃO DE USO DOs SCRIPTS ##

O script [1-create-project.sh] é interativo.

- Com isso começará a instalação dos componentes básicos do gcloud CLI.
- Variável importante:
    * [NEW_PROJECT_ID] = Essa variável já está definida, mas se desejar alterar, é importante ler as orientações
    ao término do script, sobre os arquivos que precisam estar com essa mesma informação para tudo funcionar
    corretamente.

Os valores definidos nas variáveis pré-definidas, não necessitam de alteração - mas é possível alterá-los
caso deseje.

Ao término da execução do script, será gerado o arquivo [svc-$NEW_PROJECT_ID-private-key.json].

Esse arquivo será utilizado na etapa seguinte:
- Configurando Secrets no Repositório:
    * No github, na home do projeto/repositório que foi realizado o fork, clique na opção [Settings] que fica ao lado de [Insights];
    * Dentro das opções na coluna [General], navegue na sessão até chegar na opção "Actions": [Security] >> [Secrets] >> [Actions];
    * Clique em [New Repository Secret] >> Crie um nome baseado na finalidade dessa secret:
        - Defina: [GCP_TERRAFORM_SVC_ACCOUNT] ## Esse é o valor configurado nos arquivos de workflows.
    * Em [Value], cole o conteúdo do arquivo [svc-$NEW_PROJECT_ID-private-key.json] e clique em [Add Secret].

Feito isso, agora seu projeto/repo terá o acesso necessário para quando for executar os workflows do GitHub Actions.

 ### CONTINUAR A PARTE DOS OUTROS SCRIPTS ###

- 

Foram gerados alguns workflows (pipelines/esteiras) no path:

-  ./github/workflows:
    * 1-gke.yaml ## Criar/deletar a infraestrutura (cluster GKE) via Terraform.
    * 2-flask-app.yaml ## Realizar o fluxo de CI/CD da aplicação flask no GKE.
## Construção do Cluster GKE ##
- Utilizado o Terraform para provisionar a infraestrutura necessária para cenário de teste.
    * Documentações de apoio/referência: 
        https://learnk8s.io/terraform-gke
        https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/private-cluster

###### NOTAS ####
