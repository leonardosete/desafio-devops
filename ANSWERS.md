## Criado por Leonardo Sete ##
## CRIAÇÃO DE UM NOVO PROJETO GCP E SERVICE ACCOUNT ##
Após realizado o fork do projeto/repo, execute em sua máquina o bash script a seguir:

sh ./scripts/create-project-and-svc-account.sh
## OBS - Arquivo consumido pelo script ##
./scripts/roles-svc-account.md

## ORIENTAÇÃO DE USO DO SCRIPT - create-project-and-svc-account.sh ##

Será necessário interagir com o script em 2 momentos:

- Confirmação da instalação do gcloud CLI:
    * Necessário digitar [y/Y] ou apenas a tecla [ENTER] para que o script siga.

- Fornecer o valor de 1 variável:
    * [NEW_PROJECT_ID] = Nome do novo projeto que será criado.

- VARIÁVEIS PRÉ-DEFINIDAS:
    * [BUCKET_NAME]="tembici-sre-tf-state" ## `Bucket to be created`
    * [KEY_FILE]="./svc-$NEW_PROJECT_ID-private-key.json" ## `The key/json file to be created to the Service Account`
    * [LIST_ROLES]=`cat ./roles-svc-account.md` ## `A list of the needed roles to be added to the new Service Account`
    * [SERVICE_ACCOUNT_ID]="terraform-svc-account" ## `The new Service Account to be created to run Terraform`
    * [SVC_DESCRIPTION]="Terraform Service Account" ## `Service Account Description`

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

Feito isso, agora seu projeto/repo terá o acesso necessário para executar os workflows do GitHub Actions.

Foram gerados alguns workflows (pipelines/esteiras) no path:
-  ./github/workflows:
    * 1-gke.yaml ## Criar/deletar a infraestrutura (cluster GKE) via Terraform.
    * 2-k8s-namespace.yaml ## Criar namespaces dentro do cluster GKE.
    * 3-flask-app.yaml ## Realizar o build/teste e deploy da aplicação flask (K8s) no namespace definido acima.
    * 4-flask-app-delete.yaml ## Deletar todos os manifestos/recursos (K8s) da aplicação.


## Construção do Cluster GKE ##
- Utilizado o Terraform para provisionar a infraestrutura necessária para cenário de teste.
    * Documentações de apoio/referência: 
        https://learnk8s.io/terraform-gke
        https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/private-cluster
        

##
## CONTINUAR A DOC ##
##
## RBAC - IMPORTANTE ##
https://cloud.google.com/kubernetes-engine/docs/best-practices/rbac