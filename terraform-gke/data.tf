data "external" "gke_service_account" {
  program = ["bash", "${path.root}/../scripts/get-svc-account-name.sh"]
  # working_dir = "../"
}