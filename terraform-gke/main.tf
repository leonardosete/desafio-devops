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

## TESTE ##
module "gke_private-cluster" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  project_id                 = "${var.project_id}"
  name                       = "${var.cluster_name}-${var.env_name}"
  region                     = "${var.region}"
  regional                   = true
  release_channel            = "${var.release_channel}"
  network                    = module.gcp-network.network_name
  subnetwork                 = module.gcp-network.subnets_names[0]
  ip_range_pods              = var.ip_range_pods_name
  ip_range_services          = var.ip_range_services_name
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  enable_private_endpoint    = false
  enable_private_nodes       = true
  master_ipv4_cidr_block     = "10.0.0.0/28"
  grant_registry_access      = true

  node_pools = [
    {
      name                      = "${var.node_pools_name}"
      machine_type              = "${var.node_pools_machine_type}"
      min_count                 = 2
      max_count                 = 6
      local_ssd_count           = 0
      spot                      = false
      disk_size_gb              = 50
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      enable_gvnic              = false
      auto_repair               = true
      auto_upgrade              = true
      service_account           = "project-service-account@${var.project_id}.iam.gserviceaccount.com"
      preemptible               = false
      initial_node_count        = 3
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "default-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}

## /TESTE/ ##



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

# module "gke_private-cluster" {
#   source                 = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
#   project_id             = var.project_id
#   name                   = "${var.cluster_name}-${var.env_name}"
#   regional               = true
#   region                 = var.region
#   network                = module.gcp-network.network_name
#   subnetwork             = module.gcp-network.subnets_names[0]
#   ip_range_pods          = var.ip_range_pods_name
#   ip_range_services      = var.ip_range_services_name
#   release_channel        = var.release_channel
  
#   create_service_account  = true
#   grant_registry_access  = true
#   service_account        = var.cluster_admin
#   registry_project_ids   = [ var.repository_id ]

#   node_pools = [
#     {
#       name                      = "node-pool"
#       machine_type              = "e2-medium"
#       node_locations            = "us-central1-b,us-central1-c,us-central1-f"
#       min_count                 = 1
#       max_count                 = 3
#       disk_size_gb              = 50
#     },
#   ]
# }


