# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

#-----------------------------------------------------------------------------------
# Networking
#-----------------------------------------------------------------------------------
data "google_compute_subnetwork" "subnet" {
  name = var.subnet_name
}

#-----------------------------------------------------------------------------------
# Proxy Frontend
#-----------------------------------------------------------------------------------
resource "google_compute_address" "boundary_worker_proxy_frontend_lb" {
  count = var.create_lb ? 1 : 0

  name         = "${var.friendly_name_prefix}-boundary-worker-proxy-frontend-lb-ip"
  description  = "Static IP to associate with Boundary Forwarding Rule (frontend of TCP load balancer)."
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.subnet.self_link
}

resource "google_compute_forwarding_rule" "boundary_worker_proxy_frontend_lb" {
  count = var.create_lb ? 1 : 0

  name                  = "${var.friendly_name_prefix}-boundary-worker-proxy-tcp-lb"
  region                = var.region
  backend_service       = google_compute_region_backend_service.boundary_worker_proxy_backend_lb[0].id
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  ports                 = [9202]
  subnetwork            = data.google_compute_subnetwork.subnet.self_link #"projects/hc-42cdbf2dd3ea43c286b21f97933/us-east1/networks/vchcl-prereq-subnet"
  ip_address            = google_compute_address.boundary_worker_proxy_frontend_lb[0].address
}

#-----------------------------------------------------------------------------------
# Proxy Backend
#-----------------------------------------------------------------------------------
resource "google_compute_region_backend_service" "boundary_worker_proxy_backend_lb" {
  count = var.create_lb ? 1 : 0

  name                  = "${var.friendly_name_prefix}-boundary-worker-proxy-backend-lb"
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  timeout_sec           = 60

  backend {
    description = "Boundary Backend Regional Internal TCP/UDP Load Balancer"
    group       = google_compute_region_instance_group_manager.boundary.instance_group
  }

  health_checks = [google_compute_region_health_check.boundary_worker_proxy_backend_lb[0].self_link]
}

resource "google_compute_region_health_check" "boundary_worker_proxy_backend_lb" {
  count = var.create_lb ? 1 : 0

  name               = "${var.friendly_name_prefix}-boundary-worker-proxy-backend-svc-health-check"
  check_interval_sec = 5
  timeout_sec        = 5
  log_config {
    enable = true
  }

  http_health_check {
    port         = 9203
    request_path = "/health"
  }
}
