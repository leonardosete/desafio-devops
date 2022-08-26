data "external" "gke_service_account" {
  program = ["bash", "./get-svc-account-name.sh"]
  # working_dir = "../"
}