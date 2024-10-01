# Boundary Worker on Google

Terraform module used by HashiCorp Professional Services to deploy Boundary Worker on Google. For deploying workers, please see the [Boundary Workers on Google](https://github.com/hashicorp-services/terraform-google-boundary-worker) module. Prior to deploying in production, the code should be reviewed, potentially tweaked/customized, and tested in a non-production environment.

<!-- ## Boundary Architecture

This diagram shows a Boundary deployment with one worker and two sets of Boundary Workers, one for ingress and another for egress. This diagram is coming soon!

![Boundary on Google](./docs/images/boundary-diagram.png) -->

## Prerequisites

### General

- Terraform CLI `>= 1.9` installed on workstations.
- `Git` CLI and Visual Studio Code editor installed on workstations are strongly recommended.
- Google account that Boundary will be hosted in with permissions to provision these [resources](#resources) via Terraform CLI.
- (Optional) Google GCS for [GCS Remote State backend](https://developer.hashicorp.com/terraform/language/settings/backends/gcs) that will solely be used to stand up the Boundary infrastructure via Terraform CLI (Community Edition).

### Google

- GCP Project Created
- Following APIs enabled
  - secretmanager.googleapis.com
  - compute.googleapis.com  
  - cloudkms.googleapis.com

### Networking

- Google VPC
  - Subnet
  - Private Service Access Configured
  - Firewall rules will be created with this Module. If that is not possible (shared VPC) then the firewall rules in this module will need to be created in the shared VPC
  - [Boundary Network connectivity](https://developer.hashicorp.com/boundary/docs/install-boundary/architecture/system-requirements#network-connectivity)

### Compute

One of the following mechanisms for shell access to Boundary VM instances:

- Ability to enable Google IAP (this module supports this via a boolean input variable).
- SSH key and user

### Boundary

Unless deploying a Boundary HCP Worker, a Boundary Cluster deployed using this module, [terraform-google-boundary-enterprise-controller-hvd](https://registry.terraform.io/modules/hashicorp/boundary-enterprise-controller-hvd/google/latest)

## Usage - Boundary Enterprise

1. Create/configure/validate the applicable [prerequisites](#prerequisites).

2. Nested within the [examples](./examples/) directory are subdirectories that contain ready-made Terraform configurations of example scenarios for how to call and deploy this module. To get started, choose an example scenario. If you are not sure which example scenario to start with, then we recommend starting with the [ingress](examples/ingress) example.
    >📝 Note: The `friendly_name_prefix` variable should be unique for every agent deployment.

3. Copy all of the Terraform files from your example scenario of choice into a new destination directory to create your root Terraform configuration that will manage your Boundary deployment. If you are not sure where to create this new directory, it is common for us to see users create an `environments/` directory at the root of this repo, and then a subdirectory for each Boundary instance deployment, like so:

```sh
.
└── environments
    ├── production
    │   ├── backend.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── terraform.tfvars
    │   └── variables.tf
    └── sandbox
        ├── backend.tf
        ├── main.tf
        ├── outputs.tf
        ├── terraform.tfvars
        └── variables.tf
```

  >📝 Note: in this example, the user will have two separate Boundary deployments; one for their `sandbox` environment, and one for their `production` environment. This is recommended, but not required.

4. (Optional) Uncomment and update the [gcs remote state backend](https://developer.hashicorp.com/terraform/language/settings/backends/gcs) configuration provided in the `backend.tf` file with your own custom values. While this step is highly recommended, it is technically not required to use a remote backend config for your Boundary deployment.

5. Populate your own custom values into the `terraform.tfvars.example` file that was provided, and remove the `.example` file extension such that the file is now named `terraform.tfvars`.

6. Navigate to the directory of your newly created Terraform configuration for your Boundary Worker deployment, and run `terraform init`, `terraform plan`, and `terraform apply`.

7. After your `terraform apply` finishes successfully, you can monitor the installation progress by connecting to your Boundary VM instance shell via SSH or Google IAP and observing the cloud-init (user_data) logs:

  Higher-level logs:

  ```sh
  tail -f /var/log/boundary-cloud-init.log
  ```

  Lower-level logs:

  ```sh
  journalctl -xu cloud-final -f
  ```

  >📝 Note: the `-f` argument is to follow the logs as they append in real-time, and is optional. You may remove the `-f` for a static view.

  The log files should display the following message after the cloud-init (user_data) script finishes successfully:

  ```sh
  [INFO] boundary_custom_data script finished successfully!
  ```

8.  Once the cloud-init script finishes successfully, while still connected to the VM via SSH you can check the status of the boundary service:

   ```sh
   sudo systemctl status boundary
   ```

9. After the Boundary Worker is deployed the Boundary worker should show up in the Boundary Clusters workers

## Usage - HCP Boundary

1. In HCP Boundary go to `Workers` and start creating a new worker. Copy the `Boundary Cluster ID`.

2. Create/configure/validate the applicable [prerequisites](#prerequisites).

3. Nested within the [examples](./examples/) directory are subdirectories that contain ready-made Terraform configurations of example scenarios for how to call and deploy this module. To get started, choose an example scenario. If you are not sure which example scenario to start with, then we recommend starting with the [default](examples/default) example. 

4. Copy all of the Terraform files from your example scenario of choice into a new destination directory to create your root Terraform configuration that will manage your Boundary deployment. If you are not sure where to create this new directory, it is common for us to see users create an `environments/` directory at the root of this repo, and then a subdirectory for each Boundary instance deployment, like so:

```sh
.
└── environments
    ├── production
    │   ├── backend.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── terraform.tfvars
    │   └── variables.tf
    └── sandbox
        ├── backend.tf
        ├── main.tf
        ├── outputs.tf
        ├── terraform.tfvars
        └── variables.tf
```

  >📝 Note: in this example, the user will have two separate Boundary deployments; one for their `sandbox` environment, and one for their `production` environment. This is recommended, but not required.

5. (Optional) Uncomment and update the [gcs remote state backend](https://developer.hashicorp.com/terraform/language/settings/backends/gcs) configuration provided in the `backend.tf` file with your own custom values. While this step is highly recommended, it is technically not required to use a remote backend config for your Boundary deployment.

6. Populate your own custom values into the `terraform.tfvars.example` file that was provided, and remove the `.example` file extension such that the file is now named `terraform.tfvars`. Ensure to set the `hcp_boundary_cluster_id` variable with the Boundary Cluster ID from step 1.

7. Navigate to the directory of your newly created Terraform configuration for your Boundary Worker deployment, and run `terraform init`, `terraform plan`, and `terraform apply`.

8. After your `terraform apply` finishes successfully, you can monitor the installation progress by connecting to your Boundary VM instance shell via SSH or Google IAP and observing the cloud-init (user_data) logs:

  Higher-level logs:

  ```sh
  tail -f /var/log/boundary-cloud-init.log
  ```

  Lower-level logs:

  ```sh
  journalctl -xu cloud-final -f
  ```

  >📝 Note: the `-f` argument is to follow the logs as they append in real-time, and is optional. You may remove the `-f` for a static view.

  The log files should display the following message after the cloud-init (user_data) script finishes successfully:

  ```sh
  [INFO] boundary_custom_data script finished successfully!
  ```

9.  Once the cloud-init script finishes successfully, while still connected to the VM via SSH you can check the status of the boundary service:

   ```sh
   sudo systemctl status boundary
   ```

10. While still connected to the Boundary Worker, `sudo journalctl -xu boundary` to review the Boundary Logs.

11. Copy the `Worker Auth Registration Request` string and paste this into the `Worker Auth Registration Request` field of the new Boundary Worker in the HCP console and click `Register Worker`.

12. Worker should show up in HCP Boundary console

## Docs

Below are links to docs pages related to deployment customizations and day 2 operations of your Boundary Worker instance.

- [Deployment Customizations](./docs/deployment-customizations.md)
- [Upgrading Boundary version](./docs/boundary-version-upgrades.md)
- [Updating/modifying Boundary configuration settings](./docs/boundary-config-settings.md)

## Module support

This open source software is maintained by the HashiCorp Technical Field Organization, independently of our enterprise products. While our Support Engineering team provides dedicated support for our enterprise offerings, this open source software is not included.

- For help using this open source software, please engage your account team.
- To report bugs/issues with this open source software, please open them directly against this code repository using the GitHub issues feature.

Please note that there is no official Service Level Agreement (SLA) for support of this software as a HashiCorp customer. This software falls under the definition of Community Software/Versions in your Agreement. We appreciate your understanding and collaboration in improving our open source projects.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.39 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 5.39 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | n/a |
| <a name="provider_google"></a> [google](#provider\_google) | ~> 5.39 |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.boundary_worker_proxy_frontend_lb](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_firewall.allow_9202](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_iap](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.health_checks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_forwarding_rule.boundary_worker_proxy_frontend_lb](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule) | resource |
| [google_compute_health_check.boundary_auto_healing](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_instance_template.boundary](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_compute_region_backend_service.boundary_worker_proxy_backend_lb](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_backend_service) | resource |
| [google_compute_region_health_check.boundary_worker_proxy_backend_lb](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_health_check) | resource |
| [google_compute_region_instance_group_manager.boundary](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager) | resource |
| [google_kms_crypto_key_iam_member.worker_operator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_kms_crypto_key_iam_member.worker_viewer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_service_account.boundary](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.boundary](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [cloudinit_config.boundary_cloudinit](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_image.boundary](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
| [google_compute_network.vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_subnetwork.subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_compute_zones.up](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |
| [google_kms_crypto_key.key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_key) | data source |
| [google_kms_key_ring.key_ring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_key_ring) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_friendly_name_prefix"></a> [friendly\_name\_prefix](#input\_friendly\_name\_prefix) | Friendly name prefix used for uniquely naming resources. This should be unique across all deployments | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of GCP Project to create resources in. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region of GCP Project to create resources in. | `string` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Existing VPC subnetwork for Boundary instance(s) and optionally Boundary frontend load balancer. | `string` | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | Existing VPC network to deploy Boundary resources into. | `string` | n/a | yes |
| <a name="input_additional_package_names"></a> [additional\_package\_names](#input\_additional\_package\_names) | List of additional repository package names to install | `set(string)` | `[]` | no |
| <a name="input_boundary_upstream"></a> [boundary\_upstream](#input\_boundary\_upstream) | List of FQDNs or IP addresses for the worker to connect to. | `list(string)` | `null` | no |
| <a name="input_boundary_upstream_port"></a> [boundary\_upstream\_port](#input\_boundary\_upstream\_port) | Port for the worker to connect to. | `number` | `9201` | no |
| <a name="input_boundary_version"></a> [boundary\_version](#input\_boundary\_version) | Version of Boundary to install. | `string` | `"0.17.1+ent"` | no |
| <a name="input_cidr_ingress_9202_allow"></a> [cidr\_ingress\_9202\_allow](#input\_cidr\_ingress\_9202\_allow) | CIDR ranges to allow 9202 traffic inbound to Boundary instance(s). | `list(string)` | `null` | no |
| <a name="input_cidr_ingress_ssh_allow"></a> [cidr\_ingress\_ssh\_allow](#input\_cidr\_ingress\_ssh\_allow) | CIDR ranges to allow SSH traffic inbound to Boundary instance(s) via IAP tunnel. | `list(string)` | `null` | no |
| <a name="input_common_labels"></a> [common\_labels](#input\_common\_labels) | Common labels to apply to GCP resources. | `map(string)` | `{}` | no |
| <a name="input_create_lb"></a> [create\_lb](#input\_create\_lb) | Boolean to create a Network Load Balancer for Boundary. Should be true if downstream workers will connect to these workers. | `bool` | `false` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | Size in Gigabytes of root disk of Boundary instance(s). | `number` | `50` | no |
| <a name="input_enable_iap"></a> [enable\_iap](#input\_enable\_iap) | (Optional bool) Enable https://cloud.google.com/iap/docs/using-tcp-forwarding#console, defaults to `true`. | `bool` | `true` | no |
| <a name="input_enable_session_recording"></a> [enable\_session\_recording](#input\_enable\_session\_recording) | Boolean to enable session recording in Boundary. | `bool` | `false` | no |
| <a name="input_hcp_boundary_cluster_id"></a> [hcp\_boundary\_cluster\_id](#input\_hcp\_boundary\_cluster\_id) | ID of the Boundary cluster in HCP. Only used when using HCP Boundary. | `string` | `null` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | VM image for Boundary instance(s). | `string` | `"ubuntu-2404-noble-amd64-v20240607"` | no |
| <a name="input_image_project"></a> [image\_project](#input\_image\_project) | ID of project in which the resource belongs. | `string` | `"ubuntu-os-cloud"` | no |
| <a name="input_initial_delay_sec"></a> [initial\_delay\_sec](#input\_initial\_delay\_sec) | The number of seconds that the managed instance group waits before it applies autohealing policies to new instances or recently recreated instances | `number` | `1200` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Target size of Managed Instance Group for number of Boundary instances to run. Only specify a value greater than 1 if `enable_active_active` is set to `true`. | `number` | `1` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Name of Worker KMS key. | `string` | `null` | no |
| <a name="input_key_ring_location"></a> [key\_ring\_location](#input\_key\_ring\_location) | Location of KMS key ring. If not set, the region of the Boundary deployment will be used. | `string` | `null` | no |
| <a name="input_key_ring_name"></a> [key\_ring\_name](#input\_key\_ring\_name) | Name of KMS key ring. | `string` | `null` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | (Optional string) Size of machine to create. Default `n2-standard-4` from https://cloud.google.com/compute/docs/machine-resource. | `string` | `"n2-standard-4"` | no |
| <a name="input_vpc_project_id"></a> [vpc\_project\_id](#input\_vpc\_project\_id) | ID of GCP Project where the existing VPC resides if it is different than the default project. | `string` | `null` | no |
| <a name="input_worker_is_internal"></a> [worker\_is\_internal](#input\_worker\_is\_internal) | Boolean to create give the worker an internal IP address only or give it an external IP address. | `bool` | `true` | no |
| <a name="input_worker_tags"></a> [worker\_tags](#input\_worker\_tags) | Map of extra tags to apply to Boundary Worker Configuration. var.common\_labels will be merged with this map. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_proxy_lb_ip_address"></a> [proxy\_lb\_ip\_address](#output\_proxy\_lb\_ip\_address) | IP Address of the Proxy Load Balancer. |
<!-- END_TF_DOCS -->
