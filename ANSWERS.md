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
- Após realizado o [fork] do repositório no GitHub, execute em sua máquina o bash script a seguir [usando_branch_master]:
    * Path = "./scripts"

[1-create-project.sh]

- Variáveis importantes:
    * [NEW_PROJECT_ID] = Essa variável já está definida, mas se desejar alterar, é importante ler as orientações
    ao término do script, sobre os arquivos que precisam estar com essa mesma informação para tudo funcionar
    corretamente.
    
    * [BUCKET_NAME] = Por padrão, será o mesmo nome do projeto [NEW_PROJECT_ID], mas caso dê algum erro (nome de bucket já em uso),
    basta alterá-la dentro do script [1-create-project.sh] e no arquivo [provider.tf].

Ao término da execução do script, será gerado o arquivo [svc-$NEW_PROJECT_ID-private-key.json] na raiz do projeto.

Esse arquivo será utilizado na etapa seguinte:
- Configurando Secrets no Repositório:
    * No github, na home do projeto/repositório que foi realizado o fork, clique na opção [Settings] que fica ao lado de [Insights];
    * Dentro das opções na coluna [General], navegue na sessão até chegar na opção "Actions": [Security] >> [Secrets] >> [Actions];
    * Clique em [New_Repository_Secret] >> E digite/cole o valor abaixo:
        - Defina: [GCP_TERRAFORM_SVC_ACCOUNT] ## Esse é o valor configurado nos arquivos de workflows.
    * Em [Value], cole o conteúdo do arquivo [svc-$NEW_PROJECT_ID-private-key.json] e clique em [Add_Secret].

- Ativando Issues no repositório:
    * No github, na home do projeto/repositório que foi realizado o fork, clique na opção [Settings] >> [Features] >> [Issues]
        - Deixa marcado a opção dentro de [Issues] para que seja possível utilizar esse recurso na esteira, pois será preciso
            para realizar a aprovação no fluxo de deploys.

Feito isso, agora seu projeto/repo terá o acesso necessário para quando for executar os workflows do GitHub Actions.

## SCRIPT 2 ##
  * 2-external-static-ip.sh [mandatório] - Definirá 5 IPs estáticos [externos] - necessário nos LBs do GKE/Ingress Controller.
            
   - 3 IPs = 3 Load Balancers = 1 para cada ambiente (dev/hlg/prd)
   - 2 IPs = 2 LBs = grafana e prometheus

## SCRIPT 3 ##
  * 3-buy-domain.sh [mandatório] - Fará a compra de um domínio através da GCP e ativará o serviço Cloud DNS do Google.
        
    - Escolha um domínio para que seja verificado e estando disponível, basta seguir com o processo de configuração
      do Cloud DNS e posteriormente, a compra do domínio.
    
## SCRIPT 4 ##
   * 4-set-dns-records.sh [mandatório] - Criará registros na zona de DNS do Google - Cloud DNS.
    -   Execute o script 3 vezes para definir as 3 entradas/registros necessárias.
        * entradas a serem definidas, por exemplo:
          - flask-app-dev.[dominio]
          - flask-app-hlg.[dominio]
          - flask-app-prd.[dominio]
          - grafana.[dominio]
          - prometheus.[dominio]
            
        - Esses hostnames estão pré-definidos nos arquivos/manifestos do k8s:
            - desafio-devops/k8s/deploy-dev.yaml -> [definir] o mesmo valor que for atribuído no DNS
            - desafio-devops/k8s/deploy-hlg.yaml -> [definir] o mesmo valor que for atribuído no DNS
            - desafio-devops/k8s/deploy-prd.yaml -> [definir] o mesmo valor que for atribuído no DNS
            - desafio-devops/k8s-monitoring/grafana.yaml -> [definir] o mesmo valor que for atribuído no DNS
            - desafio-devops/k8s-monitoring/prometheus.yaml -> [definir] o mesmo valor que for atribuído no DNS
            

        - A definição do registro será preciso para a etapa de geração de certificado SSL
             que está na parte do deploy/criação dos recursos do K8s (GKE).
        
        - No workflow de deploy, durante a criação dos recursos do kubernetes será criado 3 certificados via [annotations].
### NOTA IMPORTANTE ###
* Já estão pré-configurados os valores citados abaixo, mas caso sejam alterados, deve seguir a orientação:

 Os arquivos abaixo, todos [DEVEM] possuir o mesmo valor que foi definido dentro da variável [$NEW_PROJECT_ID]:

 * leosete-desafio-devops/.github/workflows/1-gke.yaml ->> PROJECT_ID: [colocar_nome_do_projeto]
 * leosete-desafio-devops/.github/workflows/2-deploy.yaml  ->> PROJECT_ID: [colocar_nome_do_projeto]
 * leosete-desafio-devops/.github/workflows/3-rollback.yaml  ->> PROJECT_ID: [colocar_nome_do_projeto]
 * leosete-desafio-devops/k8s/deploy-dev.yaml  ->> us-central1-docker.pkg.dev/[valor_antigo] == us-central1-docker.pkg.dev/[colocar_nome_do_projeto]
 * leosete-desafio-devops/k8s/deploy-hlg.yaml  ->> us-central1-docker.pkg.dev/[valor_antigo] == us-central1-docker.pkg.dev/[colocar_nome_do_projeto]
 * leosete-desafio-devops/k8s/deploy-prd.yaml  ->> us-central1-docker.pkg.dev/[valor_antigo] == us-central1-docker.pkg.dev/[colocar_nome_do_projeto]
 * leosete-desafio-devops/terraform-gke/provider.tf  ->> bucket = "[valor_antigo]" == bucket = "[colocar_nome_do_projeto]"
 * leosete-desafio-devops/terraform-gke/variables.tf ->> default = "[valor_antigo]" == default = "[colocar_nome_do_projeto]"
    


## DICA ##
## Esse comando pode ajudar na substituição dos valores antigos pelos novos ###
find ** -type f -print0 | xargs -0 sed -i "" "s/OLD_VALUE/NEW_PROJECT_ID/g"
                                                [valor_antigo]/[novo_nome_do_projeto]
## VSCODE ##
Ou utilizar o find [VSCODE] e realizar a substituição.
### FIM DA NOTA ###
## PROXIMA ETAPA ##
- Criação da infra do GKE via Terraform:
    * Será executado através do Github Actions

### BREVE ENTENDIMENTO DOS ARQUIVOS DE WORKFLOW DO GITHUB ACTIONS ###

Foram gerados 3 workflows (pipelines/esteiras) no path:

-  ./github/workflows:
    * 1-gke.yaml ->> Responsável por executar o Terraform que criará o cluster GKE.
    * 2-deploy.yaml  ->> Responsável por realizar o fluxo de CI/CD do App.
    * 3-rollback.yaml  ->> Responsável por realizar o rollback do App em Produção - GKE (K8s).
        - Não adicionei rollback para os ambientes de [dev] e [hlg] por teoricamente não serem "prioritários" 
        na hora de um rollback.

## IMPORTANTE ##
* Definir o valor da variável [APPROVERS] que está dentro arquivo de wokflow [2-deploy.yaml].
    - trocar o valor = [YOUR_GIT_USER]
    - é o usuário que fará a aprovação das issues.

- ./github/workflows:
    * [CODEOWNERS] >> Esse arquivo define permissões no repositório, é indicado colocar ao menos o seu usuário nele.
        [exemplo]: "* @leonardosete" >> exatamente conforme dentro das " ", o * significa permissão em todos os arquivos.       
    - trocar o valor = [YOUR_GIT_USER]

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

- [2-DEPLOY-APP]
    * Criar qualquer um dos 3 branches abaixo:
       - hotfix
       - feature
       - release
    
    * Realizer um commit + push, com isso o workflow dará início.
    ## OBSERVAÇÃO ##
    * Após a criação dos branchs ou de apenas 1 deles, é possível rodar [Run_workflow] na caixinha verde de forma correta.
        - Esses branches são necessários para o funcionamento do semantic version.
            - release = major
             - feature = minor
                - hotfix = patch
    
    * Com isso, será possível realizar a criação dos recursos necessários para rodar o app:
        - build
        - teste
        - publish
        - deploy (existe a necessidade de aprovação no fluxo - através de issue aberta automaticamente)
            * criará os recursos no GKE: 
                - Load Balancers através do ingress controller [gce]
                - criará os objetos do Kubernetes: namespaces, deployments, services, hpa, ingress resources, managed certificate           [criará_os_certificados_no_GCP].

    * deploy ->> [aprovação]:
        * nos jobs de deploy [dev,hlg,prd], uma issue será aberta automaticamente para que seja aprovada pelo usuário que foi
        informado ao início da execução do workflow, e deverá responder o comentário conforme a orientação na própria issue.
        * Podendo ser as respostas:
           [approved], [approve], [lgtm], [yes] to continue workflow or [denied], [deny], [no] to cancel.
        * Defina a resposta e selecione [Close_with_comment].

    * Aguardar alguns minutos para que o ingress-controller (Load Balancers) estejam totalmente configurados e
        assim poder testar o acesso ao app nos ambientes de dev/hlg e prd:

        https://flask-app-dev.[dominio_definido]/api/ping
        https://flask-app-hlg.[dominio_definido]/api/ping
        https://flask-app-prd.[dominio_definido]/api/ping


* Para configurar que o app atenda somente requisições via HTTPS, após a primeira execução do deploy
    habilite/descomente nos arquivos de [deploy-*.yaml] a linha abaixo:

     kubernetes.io/ingress.allow-http: "false" ## Only enable this, after the LB's creation

* Conecte-se ao cluster e aplique essa alteração via linha de comando:
    kubectl apply -f [leosete-desafio-devops]/k8s/deploy-dev.yaml --namespace leosete-sre-apps-dev
    kubectl apply -f [leosete-desafio-devops]/k8s/deploy-hlg.yaml --namespace leosete-sre-apps-hlg
    kubectl apply -f [leosete-desafio-devops]/k8s/deploy-prd.yaml --namespace leosete-sre-apps-prd

## FIM DO TESTE ##

## OBSERVAÇÃO SOBRE OS WORKFLOWS ##
* Ambos foram definidos para serem executados somente em cenários específicos:

## WORKFLOW 1 ##
name: 1-CREATE-INFRA-GKE
on:
  workflow_dispatch:
    inputs:
      should-destroy:
        description: 'Run: terraform destroy -auto-approve?'
        default: false
        required: false
        type: boolean
      should-destroy-yes:
        description: 'Are you Sure? Run: terraform destroy -auto-approve?'
        default: false
        required: false
        type: boolean
## Será executado apenas de forma manual (Run workflow) ##
* Escolhi essa abordagem - executar worklow com [Run_workflow], pois também adicionei 2 steps que perguntam se deseja deletar a infra. Só marque essas opções, se desejar destruir o cluster GKE.

## WORKFLOW 2 ##

name: 2-DEPLOY-APP
on:
  push: 
    branches: [release*, feature*, hotfix*]
  workflow_dispatch:
## Será executado de forma manual (Run workflow) e via push ##
* Escolhi essa abordagem - executar manualmente com [Run_workflow] e
através de [push] nos branches [release*,feature*,hoftfix*]

* Será aberto 4 issues:
 - para aprovar deploy em dev (kubernetes - GKE)
 - para aprovar deploy em hlg (kubernetes - GKE)
 - para aprovar deploy em prd (kubernetes - GKE)
 - para aprovar a realização do merge do branch atual para o branch master.

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

## Github Actions ##
https://trstringer.com/github-actions-manual-approval/
https://github.com/marketplace/actions/merge-branch
https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#example-defining-outputs-for-a-job

## kubernetes.io/ingress.allow-http ##
https://cloud.google.com/kubernetes-engine/docs/concepts/ingress-xlb?hl=pt-br
https://cloud.google.com/kubernetes-engine/docs/how-to/updating-apps