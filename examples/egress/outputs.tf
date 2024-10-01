# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "proxy_lb_ip_address" {
  value = module.boundary.proxy_lb_ip_address
}
