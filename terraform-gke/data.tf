data "external" "gke_service_account" {
  program = ["bash", "./scripts/get-svc-account-name.sh"]
  working_dir = "../"
}