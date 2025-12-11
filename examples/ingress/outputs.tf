# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

output "proxy_lb_ip_address" {
  value = module.boundary.proxy_lb_ip_address
}
