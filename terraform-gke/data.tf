data "external" "gke_service_account" {
  program = ["bash", "./tembici-desafio-devops/scripts/get-svc-account-name.sh"]
  # working_dir = "../"
}