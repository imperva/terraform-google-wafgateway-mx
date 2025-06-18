
# Imperva WAF Gateway Management Server on Google Cloud
This Terraform module provisions an Imperva WAF Gateway Management Server (also known as 'MX') on GCP.
The MX is a critical component in the Imperva WAF Gateway architecture, serving as the centralized management interface for configuring Imperva WAF Gateways.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0.0 |

For the GCP prerequisites, please see the [documentation](https://docs.imperva.com/bundle/v15.3-waf-on-google-cloud-platform-installation-guide/page/84150.htm).

## Usage
```
provider "google" {
  project = "my-project"
  region = "europe-west3"
}

variable "mx_password" {
  type = string
  description = "The password for the WAF Management Server"
  sensitive = true
}

module "imperva_mx" {
  source = "imperva/waf-mx/google"
  waf_version = "latest"
  mx_password = var.mx_password
  vpc_network = "my-vpc-network"
  subnet_name = "my-subnet"
  timezone = "UTC"
  instance_type = "n2-standard-4"
  zone = "europe-west3-a"
  ssh_access_source_ranges = ["10.0.1.0/24", "10.0.2.0/24"]
  ui_access_source_ranges = ["10.0.0.0/8"]
}  
```
## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_commons"></a> [commons](#module\_commons) | ../waf-gcp-commons | n/a |
## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.mx_firewall](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_instance.mx_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_secret_manager_secret.mx_admin_secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_member.mx_admin_secret_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_version.mx_admin_secret_version](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account.deployment_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [random_string.resource_prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.await_mx_ftl](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [google_client_config.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_subnetwork.data_mx_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [template_cloudinit_config.mx_gcp_deploy](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The desired machine type for your Management Server instance. | `string` | n/a | yes |
| <a name="input_mx_password"></a> [mx\_password](#input\_mx\_password) | A password for your Management Server's admin user. | `string` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The subnet name for your Management Server instance. Must be under the specified VPC network. | `string` | n/a | yes |
| <a name="input_vpc_network"></a> [vpc\_network](#input\_vpc\_network) | The name of your target VPC network. | `string` | n/a | yes |
| <a name="input_waf_version"></a> [waf\_version](#input\_waf\_version) | The Imperva WAF Gateway version to deploy (format: 'x.y.0.z', 'latest' or 'latest\_lts'). | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The zone in which your Management Server instance will be deployed. Must be under the same region as the specified VPC network. | `string` | n/a | yes |
| <a name="input_block_project_ssh_keys"></a> [block\_project\_ssh\_keys](#input\_block\_project\_ssh\_keys) | When true, project-wide SSH keys cannot be used to access the deployed instances. | `bool` | `false` | no |
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | A unique prefix for all deployed resources. If not provided, a random prefix will be generated. | `string` | `""` | no |
| <a name="input_enable_termination_protection"></a> [enable\_termination\_protection](#input\_enable\_termination\_protection) | When true, the Management Server instance will be protected from accidental deletion. | `bool` | `false` | no |
| <a name="input_external_ip_address"></a> [external\_ip\_address](#input\_external\_ip\_address) | An unused external IPv4 address for your Management Server instance. Leave empty if no external IP address is needed. | `string` | `""` | no |
| <a name="input_external_ip_network_tier"></a> [external\_ip\_network\_tier](#input\_external\_ip\_network\_tier) | The desired network service tier for your Management Server's external IP address. Leave empty if no external IP address is needed. | `string` | `""` | no |
| <a name="input_private_ip_address"></a> [private\_ip\_address](#input\_private\_ip\_address) | A custom private IPv4 address for your Management Server instance. The address must be within the subnetwork's range. Leave empty for automatic assignment. | `string` | `""` | no |
| <a name="input_ssh_access_source_ranges"></a> [ssh\_access\_source\_ranges](#input\_ssh\_access\_source\_ranges) | A list of IPv4 ranges in CIDR format that should have access to your Management Server via port 22 (e.g. 10.0.1.0/24). | `list(string)` | `[]` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | The desired timezone for your Management Server instance. | `string` | `"UTC"` | no |
| <a name="input_ui_access_source_ranges"></a> [ui\_access\_source\_ranges](#input\_ui\_access\_source\_ranges) | A list of IPv4 ranges in CIDR format that should have access to your Management Server via port 8083 (e.g. 10.0.1.0/24). | `list(string)` | `[]` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_management_server_ip"></a> [management\_server\_ip](#output\_management\_server\_ip) | The internal IP address of the WAF Management Server instance. Use this IP to register Gateways to your Management Server. |
| <a name="output_management_server_url"></a> [management\_server\_url](#output\_management\_server\_url) | The URL to access the WAF Management Server user interface. Use this URL to log in with the admin user and the password you provided. |
| <a name="output_network_tag"></a> [network\_tag](#output\_network\_tag) | The network tag assigned to the Management Server instance. Use this tag to allow traffic from Gateways to the Management Server. |
