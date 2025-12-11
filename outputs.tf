# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------------------------------------------
# Boundary URLs
#------------------------------------------------------------------------------------------------------------------
output "proxy_lb_ip_address" {
  value       = try(google_compute_address.boundary_worker_proxy_frontend_lb[0].address, null)
  description = "IP Address of the Proxy Load Balancer."
}

output "proxy_forwarding_rule_id" {
  value       = try(google_compute_forwarding_rule.boundary_worker_proxy_frontend_lb[0].id, null)
  description = "ID of the Proxy Load Balancer Forwarding Rule."
}