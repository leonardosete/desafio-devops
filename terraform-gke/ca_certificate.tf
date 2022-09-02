provider tls{}

resource "tls_private_key" "example" {
#   algorithm   = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "example" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name  = var.tls_cert_cn
    organization = var.tls_cert_org
  }
}

resource "google_privateca_ca_pool" "default" {
  name = var.pvt_ca_ca_pool_default_name
  location = var.region
  tier = var.pvt_ca_ca_pool_default_tier
  project = var.project_id
  publishing_options {
    publish_ca_cert = true
    publish_crl = true
  }

  issuance_policy {
    baseline_values {
      ca_options {
        is_ca = false
      }
      key_usage {
        base_key_usage {
          digital_signature = true
          key_encipherment = true
        }
        extended_key_usage {
          server_auth = true
        }
      }
    }
  }
}

resource "google_privateca_certificate_authority" "default" {
  certificate_authority_id = var.pvt_ca_crt_auth_default_ca_id
  location = var.region
  project = var.project_id
  pool = var.pvt_ca_ca_pool_default_name
  config {
    subject_config {
      subject {
        country_code = "us" ## Type your values ##
        organization = "google" ## Type your values ##
        organizational_unit = "enterprise" ## Type your values ##
        locality = "mountain view" ## Type your values ##
        province = "california" ## Type your values ##
        street_address = "1600 amphitheatre parkway" ## Type your values ##
        postal_code = "94109" ## Type your values ##
        common_name = var.tls_cert_cn ## Type your values ##
      }
    }
    x509_config {
      ca_options {
        is_ca = true
      }
      key_usage {
        base_key_usage {
          cert_sign = true
          crl_sign = true
        }
        extended_key_usage {
          server_auth = true
        }
      }
    }
  }
  type = "SELF_SIGNED"
  key_spec {
    algorithm = "RSA_PKCS1_4096_SHA256"
  }
}

resource "google_privateca_certificate" "default" {
  pool = var.pvc_ca_ca_pool_default_name
  certificate_authority = var.pvc_ca_crt_auth_default_ca_id
  project = var.project_id
  location = var.region
  lifetime = var.pvc_ca_crt_default_lifetime
  name = var.pvc_ca_crt_default_name
  pem_csr = tls_cert_request.example.cert_request_pem
}