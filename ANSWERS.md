Coloque aqui suas respostas, observações e o que mais achar necessário. Mais uma vez, boa sorte!


## DOC UTILIZADA ##
https://learnk8s.io/terraform-gke


## RBAC - IMPORTANTE ##
https://cloud.google.com/kubernetes-engine/docs/best-practices/rbac


## CREATE SERVICE ACCOUNT ON GCP

gcloud projects add-iam-policy-binding tembici-sre \
    --member="serviceAccount:SERVICE_ACCOUNT_ID@PROJECT_ID.iam.gserviceaccount.com" \
    --role="ROLE_NAME"