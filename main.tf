locals {
  resource_prefix = var.deployment_name != "" ? var.deployment_name : random_string.resource_prefix[0].result
  waf_image_url = "${module.commons.constants.gcp.image_url_prefix}${module.commons.builds[var.waf_version]}"
  mgt_network   = var.vpc_network
  mx_tag        = "${local.resource_prefix}-mx"
  mx_fw_rules = merge(
    length(var.ui_access_source_ranges) > 0 ? {
      UI = {  
        name          = "${local.resource_prefix}-mx-ui-access"
        direction     = "INGRESS"
        network       = local.mgt_network
        source_ranges = var.ui_access_source_ranges
        source_tags   = []
        target_tags = [
          local.mx_tag
        ]
        allow = [
          {
            protocol = "tcp"
            ports = [
              "8083"
            ]
          }
        ]
      }
    } : {},
    length(var.ssh_access_source_ranges) > 0 ? {
      SSH = {
        name          = "${local.resource_prefix}-mx-ssh-access"
        direction     = "INGRESS"
        network       = local.mgt_network
        source_ranges = var.ssh_access_source_ranges
        source_tags   = []
        target_tags = [
          local.mx_tag
        ]
        allow = [
          {
            protocol = "tcp"
            ports = [
              "22"
            ]
          }
        ]
      }
    } : {}
  )
  mx_secret_id  = google_secret_manager_secret.mx_admin_secret.secret_id
  management_ip = google_compute_instance.mx_instance.network_interface[0].network_ip
}

data "google_client_config" "this" {}

data "google_compute_subnetwork" "data_mx_subnet" {
  name   = var.subnet_name
  region = data.google_client_config.this.region
}

module "commons" {
  source = "imperva/wafgateway-commons/google"
  version = "1.2.1"
}

resource "random_string" "resource_prefix" {
  count = var.deployment_name != "" ? 0 : 1
  length  = 4
  special = false
  upper = false
  numeric = false
}

resource "google_service_account" "deployment_service_account" {
  account_id = "${local.resource_prefix}-mx-svc-acc"
}

resource "google_secret_manager_secret" "mx_admin_secret" {
  secret_id = "${local.resource_prefix}-mx-secret"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "mx_admin_secret_version" {
  secret      = google_secret_manager_secret.mx_admin_secret.id
  secret_data = var.mx_password
}

resource "google_secret_manager_secret_iam_member" "mx_admin_secret_iam_member" {
  secret_id = local.mx_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.deployment_service_account.email}"
}

resource "google_compute_instance" "mx_instance" {
  depends_on = [
    google_secret_manager_secret_version.mx_admin_secret_version
  ]
  name                = "${local.resource_prefix}-mx"
  description         = "Imperva WAF Management Server (Deployment ID: ${local.resource_prefix})"
  zone                = var.zone
  deletion_protection = var.enable_termination_protection
  tags = [
    local.mx_tag
  ]
  machine_type = var.instance_type
  boot_disk {
    initialize_params {
      image = local.waf_image_url
    }
  }
  network_interface {
    subnetwork = var.subnet_name
    network_ip = var.private_ip_address
    dynamic "access_config" {
      for_each = var.external_ip_address != "" || var.external_ip_network_tier != "" ? [1] : []
      content {
        nat_ip   = var.external_ip_address
        network_tier = var.external_ip_network_tier
      }
    }
  }
  metadata = {
    startup-script         = data.template_cloudinit_config.mx_gcp_deploy.rendered
    block-project-ssh-keys = var.block_project_ssh_keys
  }
  service_account {
    email = google_service_account.deployment_service_account.email
    scopes = [
      "cloud-platform"
    ]
  }
  lifecycle {
    precondition {
      condition = data.google_compute_subnetwork.data_mx_subnet.private_ip_google_access
      error_message = module.commons.validation.gcp.subnet.private_google_access.error_message
    }
  }
}

resource "time_sleep" "await_mx_ftl" {
  depends_on = [
    google_compute_instance.mx_instance
  ]
  create_duration = "20m"
}

resource "google_compute_firewall" "mx_firewall" {
  for_each      = local.mx_fw_rules
  name          = each.value.name
  network       = each.value.network
  direction     = each.value.direction
  source_ranges = each.value.source_ranges
  source_tags   = each.value.source_tags
  target_tags   = each.value.target_tags
  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }
}