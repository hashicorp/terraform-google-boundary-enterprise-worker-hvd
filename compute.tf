# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

data "google_compute_image" "boundary" {
  name    = var.image_name
  project = var.image_project
}

data "google_compute_zones" "up" {
  project = var.project_id
  status  = "UP"
}

data "google_compute_network" "vpc" {
  name    = var.vpc
  project = var.vpc_project_id != null ? var.vpc_project_id : var.project_id
}

#-----------------------------------------------------------------------------------
# User Data (cloud-init) arguments
#-----------------------------------------------------------------------------------
locals {
  custom_user_data_template = fileexists("${path.cwd}/templates/${var.custom_user_data_template}") ? "${path.cwd}/templates/${var.custom_user_data_template}" : "${path.module}/templates/${var.custom_user_data_template}"
  custom_data_args = {

    # https://developer.hashicorp.com/boundary/docs/configuration/worker

    # Boundary settings
    boundary_version         = var.boundary_version
    systemd_dir              = "/etc/systemd/system",
    boundary_dir_bin         = "/usr/bin",
    boundary_dir_config      = "/etc/boundary.d",
    boundary_dir_home        = "/opt/boundary",
    boundary_upstream_port   = var.boundary_upstream_port
    boundary_upstream        = var.boundary_upstream
    hcp_boundary_cluster_id  = var.hcp_boundary_cluster_id != null ? var.hcp_boundary_cluster_id : ""
    worker_is_internal       = var.worker_is_internal
    enable_session_recording = var.enable_session_recording
    worker_tags              = lower(replace(jsonencode(merge(var.common_labels, var.worker_tags)), ":", "="))
    additional_package_names = join(" ", var.additional_package_names)

    # KMS settings
    key_ring_project     = var.project_id
    key_ring_region      = var.key_ring_location != null || data.google_client_config.default.region != null ? var.key_ring_location != null ? var.key_ring_location : data.google_client_config.default.region : var.region
    worker_key_ring_name = var.key_ring_name != null ? var.key_ring_name : ""
    worker_crypto_name   = var.key_name != null ? var.key_name : ""
  }
}

data "cloudinit_config" "boundary_cloudinit" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "boundary_custom_data.sh"
    content_type = "text/x-shellscript"
    content      = templatefile(local.custom_user_data_template, local.custom_data_args)
  }
}

#-----------------------------------------------------------------------------------
# Instance Template
#-----------------------------------------------------------------------------------
resource "google_compute_instance_template" "boundary" {
  name_prefix    = "${var.friendly_name_prefix}-boundary-template-"
  machine_type   = var.machine_type
  can_ip_forward = true

  disk {
    source_image = data.google_compute_image.boundary.self_link
    auto_delete  = true
    boot         = true
    disk_size_gb = var.disk_size_gb
    disk_type    = "pd-ssd"
    mode         = "READ_WRITE"
    type         = "PERSISTENT"
  }

  network_interface {
    subnetwork = var.subnet_name
  }

  metadata = {
    user-data          = data.cloudinit_config.boundary_cloudinit.rendered
    user-data-encoding = "base64"
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = google_service_account.boundary.email
  }

  labels = var.common_labels
  tags   = ["boundary-worker"]

  lifecycle {
    create_before_destroy = true
  }
}

#-----------------------------------------------------------------------------------
# Instance Group
#-----------------------------------------------------------------------------------
resource "google_compute_region_instance_group_manager" "boundary" {
  name                      = "${var.friendly_name_prefix}-boundary-ig-mgr"
  base_instance_name        = "${var.friendly_name_prefix}-boundary-vm"
  distribution_policy_zones = data.google_compute_zones.up.names
  target_size               = var.instance_count

  version {
    instance_template = google_compute_instance_template.boundary.self_link
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.boundary_auto_healing.self_link
    initial_delay_sec = var.initial_delay_sec
  }

  update_policy {
    minimal_action               = "REPLACE"
    type                         = "PROACTIVE"
    instance_redistribution_type = var.worker_is_internal ? "PROACTIVE" : "NONE"
    replacement_method           = var.worker_is_internal ? "SUBSTITUTE" : "RECREATE"
    max_surge_fixed              = var.worker_is_internal ? length(data.google_compute_zones.up.names) : 0
    max_unavailable_fixed        = length(data.google_compute_zones.up.names)
  }

  dynamic "stateful_external_ip" {
    for_each = var.worker_is_internal == true ? [] : [1]

    content {
      interface_name = "nic0"
      delete_rule    = "ON_PERMANENT_INSTANCE_DELETION"
    }
  }
}

resource "google_compute_health_check" "boundary_auto_healing" {
  name                = "${var.friendly_name_prefix}-boundary-autohealing-health-check"
  check_interval_sec  = 30
  healthy_threshold   = 2
  unhealthy_threshold = 7
  timeout_sec         = 10

  http_health_check {
    port         = 9203
    request_path = "/health"
  }
}

#-----------------------------------------------------------------------------------
# Firewall
#-----------------------------------------------------------------------------------
resource "google_compute_firewall" "allow_ssh" {
  count = var.cidr_ingress_ssh_allow != null ? 1 : 0

  name        = "${var.friendly_name_prefix}-${data.google_compute_network.vpc.name}-boundary-firewall-ssh-allow"
  description = "Allow SSH ingress to Boundary instances from specified CIDR ranges."
  network     = data.google_compute_network.vpc.self_link
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = [22]
  }
  source_ranges = var.cidr_ingress_ssh_allow
  target_tags   = ["boundary-worker"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_9202" {
  count = var.cidr_ingress_9202_allow != null ? 1 : 0

  name        = "${var.friendly_name_prefix}-boundary-firewall-9202-allow"
  description = "Allow 9202 traffic ingress to Boundary instances in ${data.google_compute_network.vpc.name} from specified CIDR ranges."
  network     = data.google_compute_network.vpc.self_link
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = [9202]
  }

  source_ranges = var.cidr_ingress_9202_allow
  target_tags   = ["boundary-worker"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_iap" {
  count = var.enable_iap == true ? 1 : 0

  name        = "${var.friendly_name_prefix}-boundary-firewall-iap-allow"
  description = "Allow https://cloud.google.com/iap/docs/using-tcp-forwarding#console traffic"
  network     = data.google_compute_network.vpc.self_link
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = [3389, 22]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["boundary-worker"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "health_checks" {
  count = var.create_lb ? 1 : 0

  name        = "${var.friendly_name_prefix}-boundary-health-checks-allow"
  description = "Allow GCP Health Check CIDRs to talk to Boundary in ${data.google_compute_network.vpc.name}."
  network     = data.google_compute_network.vpc.self_link
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = [9203]
  }

  source_ranges = ["209.85.152.0/22", "209.85.204.0/22"]
  target_tags   = ["boundary-worker"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Firewall rule for Autohealing
resource "google_compute_firewall" "health_checks_autohealing" {

  name        = "${var.friendly_name_prefix}-boundary-health-checks-auto-healing-allow"
  description = "Allow GCP Autohealing Health Check CIDRs to talk to Boundary in ${data.google_compute_network.vpc.name}."
  network     = data.google_compute_network.vpc.self_link
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = [9203]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["boundary-worker"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}



# ------------------------------------------------------------------------------
# Debug rendered boundary custom_data script from template
# ------------------------------------------------------------------------------
# Uncomment this block to debug the rendered boundary custom_data script
# resource "local_file" "debug_custom_data" {
#   content  = templatefile("${path.module}/templates/boundary_custom_data.sh.tpl", local.custom_data_args)
#   filename = "${path.module}/debug/debug_boundary_custom_data.sh"
# }
