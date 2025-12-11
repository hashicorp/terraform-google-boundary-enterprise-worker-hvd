# Copyright IBM Corp. 2024, 2025
# SPDX-License-Identifier: MPL-2.0

#------------------------------------------------------------------------------
# Common
#------------------------------------------------------------------------------
variable "project_id" {
  type        = string
  description = "ID of GCP Project to create resources in."
}

variable "region" {
  type        = string
  description = "Region of GCP Project to create resources in."
}

variable "friendly_name_prefix" {
  type        = string
  description = "Friendly name prefix used for uniquely naming resources. This should be unique across all deployments"
  validation {
    condition     = !strcontains(var.friendly_name_prefix, "boundary")
    error_message = "Value must not contain 'boundary' to avoid redundancy in naming conventions."
  }
  validation {
    condition     = length(var.friendly_name_prefix) < 13
    error_message = "Value can only contain alphanumeric characters and must be less than 13 characters."
  }
}

variable "common_labels" {
  type        = map(string)
  description = "Common labels to apply to GCP resources."
  default     = {}
}

#------------------------------------------------------------------------------
# boundary configuration settings
#------------------------------------------------------------------------------
variable "boundary_version" {
  type        = string
  description = "Version of Boundary to install."
  default     = "0.17.1+ent"
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\+ent$", var.boundary_version))
    error_message = "Value must be in the format 'X.Y.Z+ent'."
  }
}

variable "boundary_upstream" {
  type        = list(string)
  description = "List of FQDNs or IP addresses for the worker to connect to."
  default     = null
}

variable "boundary_upstream_port" {
  type        = number
  description = "Port for the worker to connect to."
  default     = 9201
}

variable "worker_is_internal" {
  type        = bool
  description = "Boolean to create give the worker an internal IP address only or give it an external IP address."
  default     = true
}

variable "hcp_boundary_cluster_id" {
  type        = string
  description = "ID of the Boundary cluster in HCP. Only used when using HCP Boundary."
  default     = null
  validation {
    condition     = var.hcp_boundary_cluster_id != null ? var.boundary_upstream == null : true
    error_message = "HCP Boundary cluster ID must be provided when `boundary_upstream` is not provided."
  }
}

variable "enable_session_recording" {
  type        = bool
  description = "Boolean to enable session recording in Boundary."
  default     = false
}

variable "worker_tags" {
  type        = map(string)
  description = "Map of extra tags to apply to Boundary Worker Configuration. var.common_labels will be merged with this map."
  default     = {}
}

variable "additional_package_names" {
  type        = set(string)
  description = "List of additional repository package names to install"
  default     = []
}

#-----------------------------------------------------------------------------------
# Networking
#-----------------------------------------------------------------------------------
variable "vpc" {
  type        = string
  description = "Existing VPC network to deploy Boundary resources into."
}

variable "vpc_project_id" {
  type        = string
  description = "ID of GCP Project where the existing VPC resides if it is different than the default project."
  default     = null
}

variable "subnet_name" {
  type        = string
  description = "Existing VPC subnetwork for Boundary instance(s) and optionally Boundary frontend load balancer."
}

variable "create_lb" {
  type        = bool
  description = "Boolean to create a Network Load Balancer for Boundary. Should be true if downstream workers will connect to these workers."
  default     = false
}

#-----------------------------------------------------------------------------------
# Firewall
#-----------------------------------------------------------------------------------
variable "cidr_ingress_ssh_allow" {
  type        = list(string)
  description = "CIDR ranges to allow SSH traffic inbound to Boundary instance(s) via IAP tunnel."
  default     = null
}

variable "cidr_ingress_9202_allow" {
  type        = list(string)
  description = "CIDR ranges to allow 9202 traffic inbound to Boundary instance(s)."
  default     = null
}

#-----------------------------------------------------------------------------------
# Encryption Keys (KMS)
#-----------------------------------------------------------------------------------
variable "key_ring_location" {
  type        = string
  description = "Location of KMS key ring. If not set, the region of the Boundary deployment will be used."
  default     = null
}

variable "key_ring_name" {
  type        = string
  description = "Name of KMS key ring."
  default     = null
}

variable "key_name" {
  type        = string
  description = "Name of Worker KMS key."
  default     = null
}

#-----------------------------------------------------------------------------------
# Compute
#-----------------------------------------------------------------------------------
variable "image_project" {
  type        = string
  description = "ID of project in which the resource belongs."
  default     = "ubuntu-os-cloud"
}

variable "image_name" {
  type        = string
  description = "VM image for Boundary instance(s)."
  default     = "ubuntu-2404-noble-amd64-v20240607"
}

variable "machine_type" {
  type        = string
  description = "(Optional string) Size of machine to create. Default `n2-standard-4` from https://cloud.google.com/compute/docs/machine-resource."
  default     = "n2-standard-4"
}

variable "disk_size_gb" {
  type        = number
  description = "Size in Gigabytes of root disk of Boundary instance(s)."
  default     = 50
}

variable "instance_count" {
  type        = number
  description = "Target size of Managed Instance Group for number of Boundary instances to run. Only specify a value greater than 1 if `enable_active_active` is set to `true`."
  default     = 1
}

variable "initial_delay_sec" {
  type        = number
  description = "The number of seconds that the managed instance group waits before it applies autohealing policies to new instances or recently recreated instances"
  default     = 1200
}

variable "enable_iap" {
  type        = bool
  default     = true
  description = "(Optional bool) Enable https://cloud.google.com/iap/docs/using-tcp-forwarding#console, defaults to `true`. "
}

variable "custom_user_data_template" {
  type        = string
  description = "(optional) Alternative template file to provide for instance template metadata script. place the file in your local `./templates folder` no path required"
  default     = "boundary_custom_data.sh.tpl"
  validation {
    condition     = can(fileexists("${path.cwd}/templates/${var.custom_user_data_template}") || fileexists("${path.module}/templates/${var.custom_user_data_template}"))
    error_message = "File `${path.cwd}/templates/${var.custom_user_data_template}` or `${path.module}/templates/${var.custom_user_data_template} not found or not readable"
  }
}
