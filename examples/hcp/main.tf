# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.39"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.39"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

module "boundary" {
  source = "../.."

  # Common
  friendly_name_prefix = var.friendly_name_prefix
  common_labels        = var.common_labels
  project_id           = var.project_id
  region               = var.region

  # Boundary configuration settings
  boundary_version         = var.boundary_version
  hcp_boundary_cluster_id  = var.hcp_boundary_cluster_id
  worker_is_internal       = var.worker_is_internal
  worker_tags              = var.worker_tags
  enable_session_recording = var.enable_session_recording

  # Networking
  vpc                     = var.vpc
  vpc_project_id          = var.vpc_project_id
  subnet_name             = var.subnet_name
  cidr_ingress_ssh_allow  = var.cidr_ingress_ssh_allow
  cidr_ingress_9202_allow = var.cidr_ingress_9202_allow
  create_lb               = var.create_lb

  # Compute
  instance_count = var.instance_count
  enable_iap     = var.enable_iap

  # KMS
  key_ring_location = var.key_ring_location
  key_ring_name     = var.key_ring_name
  key_name          = var.key_name
}
