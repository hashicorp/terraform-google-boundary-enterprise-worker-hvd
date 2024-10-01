# Example Scenario - HCP Worker

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.39 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 5.39 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_boundary"></a> [boundary](#module\_boundary) | ../.. | n/a |

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
| <a name="output_proxy_lb_ip_address"></a> [proxy\_lb\_ip\_address](#output\_proxy\_lb\_ip\_address) | n/a |
<!-- END_TF_DOCS -->