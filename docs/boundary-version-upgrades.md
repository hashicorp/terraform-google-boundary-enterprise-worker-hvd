# Boundary Version Upgrades

See the [Boundary Releases](https://developer.hashicorp.com/boundary/docs/release-notes) page for full details on the releases. Since we have bootstrapped and automated the Boundary Worker deployment and the Boundary Worker application data is decoupled from the compute layer, the VM(s) are stateless, ephemeral, and are treated as immutable. Therefore, the process of upgrading your Boundary Worker instance to a new version involves updating your Terraform code managing your Boundary deployment to reflect the new version, applying the change via Terraform to update the Boundary Managed Instance Group Template, and then replacing running VM(s).

This module includes an input variable named `boundary_version` that dictates which version of Boundary is deployed. Here are the steps to follow:

## Procedure

 Here are the steps to follow:

1. Determine your desired version of Boundary from the [Boundary Release Notes](https://developer.hashicorp.com/boundary/docs/release-notes) page. The value that you need will be in the **Version** column of the table that is displayed.

2. Update the value of the `boundary_version` input variable within your `terraform.tfvars` file.

```hcl
    boundary_version = "0.17.1+ent"
```

3. During a maintenance window, run `terraform apply` against your root Boundary worker configuration that manages your Boundary worker deployment.

4. This will trigger the Managed Instance Group to deploy new Boundary Workers. This process will effectively re-install Boundary on the new instance(s).

5. Ensure that the Boundary worker VM has have been created with the changes. Monitor the cloud-init processes to ensure a successful re-install.
