## Criado por Leonardo Sete ##

## INSTALAÇÃO DO GCLOUD CLI ##
Será necessário em primeiro lugar (caso não possua), baixar o [gcloud_CLI] através desse link:
https://cloud.google.com/sdk/docs/install


### /DETALHE IMPORTANTE ###
A abordagem adotada nesse projeto, parte do princípio que será utilizada uma [conta_nova] da GCP [recomendado],
sem projetos/serviços/APIs configurados. Por essa razão, foram criados 5 scripts [bash] para realizar o processo que acreditei
serem básicos para a configuração do ambiente na GCP.

Poderia ter adotado uma abordagem maior com terraform, mas acabei realizando um misto com bash + gcloud também.

### DETALHE IMPORTANTE/ ###

## CRIAÇÃO DE UM NOVO PROJETO GCP E OUTROS SERVIÇOS/APIS NECESSÁRIOS PARA O CENÁRIO DE TESTE ##
- Após realizado o [fork] do repositório no GitHub, execute em sua máquina o bash script a seguir:
    * Path = "./scripts"

    * 1-create-project.sh [mandatório] - Criará os primeiros recursos necessários para dar início ao projeto.
## ORIENTAÇÃO DE EXECUÇÃO DOS SCRIPTS ##

[1-create-project.sh]

- Variáveis importantes:
    * [NEW_PROJECT_ID] = Essa variável já está definida, mas se desejar alterar, é importante ler as orientações
    ao término do script, sobre os arquivos que precisam estar com essa mesma informação para tudo funcionar
    corretamente.
    
    * [BUCKET_NAME] = Por padrão, será o mesmo nome do projeto [NEW_PROJECT_ID]-tfstate, mas caso dê algum erro (nome de bucket já em uso),
    basta alterá-la dentro do script [1-create-project.sh].

Ao término da execução do script, será gerado o arquivo [svc-$NEW_PROJECT_ID-private-key.json].

Esse arquivo será utilizado na etapa seguinte:
- Configurando Secrets no Repositório:
    * No github, na home do projeto/repositório que foi realizado o fork, clique na opção [Settings] que fica ao lado de [Insights];
    * Dentro das opções na coluna [General], navegue na sessão até chegar na opção "Actions": [Security] >> [Secrets] >> [Actions];
    * Clique em [New Repository Secret] >> Crie um nome baseado na finalidade dessa secret:
        - Defina: [GCP_TERRAFORM_SVC_ACCOUNT] ## Esse é o valor configurado nos arquivos de workflows.
    * Em [Value], cole o conteúdo do arquivo [svc-$NEW_PROJECT_ID-private-key.json] e clique em [Add Secret].

- Ativando Issues no repositório:
    * No github, na home do projeto/repositório que foi realizado o fork, clique na opção [Settings] >> [Features] >> [Issues]
        - Deixa marcado a opção dentro de [Issues] para que seja possível utilizar esse recurso na esteira, pois será preciso
            para realizar a aprovação no fluxo de deploys.

Feito isso, agora seu projeto/repo terá o acesso necessário para quando for executar os workflows do GitHub Actions.

## SCRIPT 2 ##
  * 2-external-static-ip.sh [mandatório] - Definirá 3 IPs estáticos (externos) - usará nos LBs do GKE/Ingress Controller.
            
   - 3 IPs = 3 Load Balancers = 1 para cada ambiente (dev/hlg/prd)

## SCRIPT 3 - Apesar de opcional, recomendo que seja executado para garantir o funcionamento de todo fluxo ##
  * 3-buy-domain.sh [opcional] - Fará a compra de um domínio através da GCP e ativará o serviço Cloud DNS do Google.
        
    - Escolha um domínio para que seja verificado e estando disponível, basta seguir com o processo de configuração
            do Cloud DNS e posteriormente, a compra do domínio.
            * Caso não queria adquirir um domínio [usando_uma_conta_free_da_GCP], é possível utilizar o que já possuir.
    
## SCRIPT 4 - Apesar de opcional, recomendo que seja executado para garantir o funcionamento de todo fluxo ##
   * 4-set-dns-records.sh [opcional] - Criará registros na zona de DNS do Google - Cloud DNS.

       - Caso não tenha executado o script 3 e não queira ativar esse serviço, precisará configurar em uma zona já existente
        [manualmente] o registro dos 3 IPs estáticos, para que possamos acessar a aplicação de teste no final por [hostname].
            Seguirá a mesma lógica sobre a definição dentro dos arquivos/manifestos, quanto na zona de DNS.

        - Execute o script 3 vezes para definir as 3 entradas/registros necessárias.
            * entradas a serem definidas, por exemplo:
                - flask-app-tembici-dev.[dominio]
                - flask-app-tembici-hlg.[dominio]
                - flask-app-tembici-prd.[dominio]
            
        - Esses hostnames estão pré-definidos nos arquivos/manifestos do k8s:
            - tembici-desafio-devops/k8s/deploy-dev.yaml -> definir o mesmo valor que for atribuído no DNS
            - tembici-desafio-devops/k8s/deploy-hlg.yaml -> definir o mesmo valor que for atribuído no DNS
            - tembici-desafio-devops/k8s/deploy-prd.yaml -> definir o mesmo valor que for atribuído no DNS

        - A definição do registro será preciso para a etapa de geração de certificado SSL
             que está na parte do deploy/criação dos recursos do K8s (GKE).

### NOTA IMPORTANTE ###
 Os arquivos abaixo, todos [DEVEM] possuir o mesmo valor que foi definido na variável [$NEW_PROJECT_ID]:

 * tembici-desafio-devops/.github/workflows/1-gke.yaml ->> PROJECT_ID: [colocar_nome_do_projeto]
 * tembici-desafio-devops/.github/workflows/2-flasp-app.yaml  ->> PROJECT_ID: [colocar_nome_do_projeto]
 * tembici-desafio-devops/k8s/deploy-dev.yaml  ->> us-central1-docker.pkg.dev/[valor_antigo] == us-central1-docker.pkg.dev/[colocar_nome_do_projeto]
 * tembici-desafio-devops/k8s/deploy-hlg.yaml  ->> us-central1-docker.pkg.dev/[valor_antigo] == us-central1-docker.pkg.dev/[colocar_nome_do_projeto]
 * tembici-desafio-devops/k8s/deploy-prd.yaml  ->> us-central1-docker.pkg.dev/[valor_antigo] == us-central1-docker.pkg.dev/[colocar_nome_do_projeto]
 * tembici-desafio-devops/terraform-gke/provider.tf  ->> bucket = "[valor_antigo]" == bucket = "[colocar_nome_do_projeto]"
 * tembici-desafio-devops/terraform-gke/variables.tf ->> default = "[valor_antigo]" == default = "[colocar_nome_do_projeto]"
    
    - No workflow de deploy, durante a criação dos recursos do kubernetes será criado 3 certificados via [annotations].

## DICA ##
## Esse comando pode ajudar na substituição dos valores antigos pelos novos ###
find ** -type f -print0 | xargs -0 sed -i "" "s/OLD_VALUE/NEW_PROJECT_ID/g"
                                                [valor_antigo]/[novo_nome_do_projeto]
## VSCODE ##
Ou utilizar o find VSCODE e realizar a substituição.
### FIM DA NOTA ###
## PROXIMA ETAPA ##
- Criação da infra do GKE via Terraform:
    * Será executado através do Github Actions

### BREVE ENTENDIMENTO DOS ARQUIVOS DE WORKFLOW DO GITHUB ACTIONS ###

Foram gerados 2 workflows (pipelines/esteiras) no path:

-  ./github/workflows:
    * 1-gke.yaml ->> Responsável por executar o Terraform que criará o cluster GKE.
    * 2-flask-app.yaml  ->> Responsável por realizar o fluxo de CI/CD do App.

    [extra]
- ./github/workflows:
    * CODEOWNERS >> Esse arquivo define permissões no repositório, é indicado colocar ao menos o seu usuário nele.
        [exemplo]: "* @leonardosete" >> exatamente conforme dentro das " ", o * significa permissão em todos os arquivos.       

### EXECUTANDO GITHUB ACTIONS - WORKFLOWS ###

- Pela console do github [web], na aba de [Actions], e será preciso ativar os workflows clicando no botão
    verde no centro da tela: [I_understand_my_workflows,_go_ahead_and_enable_them]. Após isso, haverá duas 
        opções de workflows conforme descrito acima.
    
    * Execução do primeiro workflow:

- [1-CREATE-INFRA-GKE]
    * Para executar, basta selecionar o workflow e ir em [Run_workflow]
    * Deixar no branch master e clicar em [Run_workflow] na caixinha verde.

    - Existe duas opções de checkbox que servem para [destruir] o cluster, portanto use somente
    se for essa a intenção. [recomendado] após finalizar os testes.

- Após a criação da infra do GKE (aguarde o terraform finalizar), e então é possível rodar o segundo workflow:

- [2-DEPLOY-FLASK-APP]
    * Para executar, é necessário fornecer o [nome_de_usuário_do_github] que pode aprovar ou negar o fluxo de deploy
    e após isso, basta selecionar o workflow e ir em [Run_workflow]
    
    * Deixar no branch master e clicar em [Run_workflow] na caixinha verde.
    * Com isso, será possível realizar a criação dos recursos necessários para rodar o app:
        - build
        - teste
        - publish
        - deploy (existe a necessidade de aprovação no fluxo - através de issue aberta automaticamente)
            * criará os recursos no GKE: 
                - Load Balancers através do ingress controller [gce]
                - criará os namespaces, deployments, services, hpa, ingress resources, managed certificate [criará_os_certificados_no_GCP]

    * deploy ->> [aprovação]:
        * nos jobs de deploy, uma issue será aberta para que seja aprovada pelo usuário que foi
        informado ao início da execução do workflow, e deverá responder o comentário conforme a orientação na própria issue.
        * Podendo ser as respostas:
           [approved], [approve], [lgtm], [yes] to continue workflow or [denied], [deny], [no] to cancel.
        * Defina a resposta e selecione [Close_with_comment].

    * Aguardar alguns minutos para que o ingress-controller (Load Balancers) estejam totalmente configurados e
        assim poder testar o acesso ao app nos ambientes de dev/hlg e prd:

        https://flask-app-tembici-dev.[dominio_definido]/api/ping
        https://flask-app-tembici-hlg.[dominio_definido]/api/ping
        https://flask-app-tembici-prd.[dominio_definido]/api/ping

## FIM DO TESTE ##

## OBSERVAÇÃO SOBRE OS WORKFLOWS ##
* Ambos foram definidos para serem executados somente em cenários específicos:

## Será executado de forma manual (Run workflow) ou via pull request para o branch deploy-infra ##
* O branch [deploy-infra] não existe no projeto, mas caso deseje testar através do pull request, ele deverá ser criado.
    * Não adotei essa abordagem, apesar de deixar disponível - usei mais a forma "manual" [Run_workflow].
## WORKFLOW 1 ##
name: 1-CREATE-INFRA-GKE
on:
  pull_request:
    branches: [deploy-infra]
  workflow_dispatch:

## Será executado forma manual (Run workflow) ou via push para os branches = release, feature, hotfix, task ##
## WORKFLOW 2 ##
name: 2-DEPLOY-FLASK-APP
on:
  push:
    branches: [release, feature, hotfix, task]
  workflow_dispatch:

## OBS ##
* Essa abordagem pode ser modificada de acordo com a necessidade/entendimento de cada projeto.

###### NOTAS ####
## Construção do Cluster GKE ##
- Utilizado o Terraform para provisionar a infraestrutura necessária para cenário de teste.
    * Documentações de apoio/referência: 
        https://learnk8s.io/terraform-gke
        https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/private-cluster

## gcloud CLI ##
https://cloud.google.com/sdk/gcloud

## ManagedCertificate ##
https://github.com/GoogleCloudPlatform/gke-managed-certs

## gke-https-redirect ##
https://github.com/doitintl/gke-https-redirect
## Github Actions ##
https://trstringer.com/github-actions-manual-approval/