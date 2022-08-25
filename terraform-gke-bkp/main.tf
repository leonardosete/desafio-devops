module "gke_auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  depends_on   = [module.gke_private-cluster]
  project_id   = var.project_id
  location     = module.gke_private-cluster.location
  cluster_name = module.gke_private-cluster.name
}
resource "local_file" "kubeconfig" {
  content  = module.gke_auth.kubeconfig_raw
  filename = "kubeconfig-${var.env_name}"
}

module "gcp-network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 4.0"
  project_id   = var.project_id
  network_name = "${var.network}-${var.env_name}"
  subnets = [
    {
      subnet_name   = "${var.subnetwork}-${var.env_name}"
      subnet_ip     = "10.10.0.0/16"
      subnet_region = var.region
    },
  ]
  secondary_ranges = {
    "${var.subnetwork}-${var.env_name}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "10.20.0.0/16"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "10.30.0.0/16"
      },
    ]
  }
}

module "gke_private-cluster" {
  source                 = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id             = "${var.project_id}"
  name                   = "${var.cluster_name}-${var.env_name}"
  regional               = true
  region                 = "${var.region}"
  network                = module.gcp-network.network_name
  subnetwork             = module.gcp-network.subnets_names[0]
  ip_range_pods          = "${var.ip_range_pods_name}"
  ip_range_services      = "${var.ip_range_services_name}"
  release_channel        = "${var.release_channel}"
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
#   create_service_account  = true
  grant_registry_access  = true
#   service_account        = var.cluster_admin
#   registry_project_ids   = [ var.repository_id ]

  node_pools = [
    {
      name                      = "${var.node_pools_name}"
      machine_type              = "${var.node_pools_machine_type}"
      min_count                 = "${var.node_pools_min_count}"
      max_count                 = "${var.node_pools_max_count}"
      disk_size_gb              = "${var.node_pools_disk_size_gb}"
      disk_type                 = "${var.node_pools_disk_type}"
      image_type                = "${var.node_pools_image_type}"
      auto_upgrade              = true
      preemptible               = true
      initial_node_count        = 1
    },
  ]
}