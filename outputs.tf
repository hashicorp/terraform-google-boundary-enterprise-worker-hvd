# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------------------------------------------
# Boundary URLs
#------------------------------------------------------------------------------------------------------------------
output "proxy_lb_ip_address" {
  value       = try(google_compute_address.boundary_worker_proxy_frontend_lb[0].address, null)
  description = "IP Address of the Proxy Load Balancer."
}
