data "external" "gke_service_account" {
#   program = ["bash", "${path.root}/scripts/getamiid.sh"]
  program = ["bash", "./scripts/get-svc-account-name.sh"]
}