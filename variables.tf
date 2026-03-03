variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "region" {
  type        = string
  description = "The GCP region where resources will be deployed."
}

variable "deployment_name" {
  type        = string
  description = "A unique prefix for all deployed resources. If not provided, a random prefix will be generated."
  default = ""
  validation {
    condition     = var.deployment_name == "" || can(regex(module.commons.validation.gcp.standard_name.regex, var.deployment_name))
    error_message = module.commons.validation.gcp.standard_name.error_message
  }
}

variable "timezone" {
  type        = string
  default     = "UTC"
  description = "The desired timezone for your Management Server instance."
  validation {
    condition = contains(
      module.commons.validation.global.timezone.allowed_values,
      var.timezone
    )
    error_message = module.commons.validation.global.timezone.error_message
  }
}

variable "vpc_network" {
  type        = string
  description = "The name of your target VPC network."
  validation {
    condition = can(
      regex(
        module.commons.validation.gcp.standard_name.regex,
        var.vpc_network
      )
    )
    error_message = module.commons.validation.gcp.standard_name.error_message
  }
}

variable "block_project_ssh_keys" {
  type = bool
  description = "When true, project-wide SSH keys cannot be used to access the deployed instances."
  default = false
}

variable "ui_access_source_ranges" {
  type        = list(string)
  default     = []
  description = "A list of IPv4 ranges in CIDR format that should have access to your Management Server via port 8083 (e.g. 10.0.1.0/24)."
  validation {
    condition = alltrue(
      [
        for range in var.ui_access_source_ranges : can(
          regex(
            module.commons.validation.global.ipv4_cidr.regex,
            range
          )
        )
      ]
    )
    error_message = module.commons.validation.global.ipv4_cidr.error_message
  }
}

variable "ssh_access_source_ranges" {
  type        = list(string)
  default     = []
  description = "A list of IPv4 ranges in CIDR format that should have access to your Management Server via port 22 (e.g. 10.0.1.0/24)."
  validation {
    condition = alltrue(
      [
        for range in var.ssh_access_source_ranges : can(
          regex(
            module.commons.validation.global.ipv4_cidr.regex,
            range
          )
        )
      ]
    )
    error_message = module.commons.validation.global.ipv4_cidr.error_message
  }
}

variable "mx_password" {
  type        = string
  description = "A password for your Management Server's admin user."
  sensitive   = true
  validation {
    condition     = length(var.mx_password) >= 7
    error_message = "Password must be at least 7 characters long."
  }
}

variable "zone" {
  type        = string
  description = "The zone in which your Management Server instance will be deployed. Must be under the same region as the specified VPC network."
  validation {
    condition = startswith(
      var.zone,
      data.google_client_config.this.region
    )
    error_message = "Zone must be under the same region as the specified VPC network (${data.google_client_config.this.region})."
  }
}

variable "instance_type" {
  type        = string
  description = "The desired machine type for your Management Server instance."
  validation {
    condition = contains(
      module.commons.validation.gcp.mx_instance_type.allowed_values,
      var.instance_type
    )
    error_message = module.commons.validation.gcp.mx_instance_type.error_message
  }
}

variable "subnet_name" {
  type        = string
  description = "The subnet name for your Management Server instance. Must be under the specified VPC network."
  validation {
    condition = can(
      regex(
        module.commons.validation.gcp.standard_name.regex,
        var.subnet_name
      )
    )
    error_message = module.commons.validation.gcp.standard_name.error_message
  }
}

variable "external_ip_network_tier" {
  type        = string
  description = "The desired network service tier for your Management Server's external IP address. Leave empty if no external IP address is needed."
  default     = ""
  validation {
    condition = contains(
      module.commons.validation.gcp.ip_network_tier.allowed_values,
      var.external_ip_network_tier
    )
    error_message = module.commons.validation.gcp.ip_network_tier.error_message
  }
}

variable "external_ip_address" {
  type        = string
  default     = ""
  description = "An unused external IPv4 address for your Management Server instance. Leave empty if no external IP address is needed."
  validation {
    condition = var.external_ip_address == "" || can(
      regex(
        module.commons.validation.global.ipv4_address.regex,
        var.external_ip_address
      )
    )
    error_message = module.commons.validation.global.ipv4_address.error_message
  }
}

variable "private_ip_address" {
  type        = string
  default     = ""
  description = "A custom private IPv4 address for your Management Server instance. The address must be within the subnetwork's range. Leave empty for automatic assignment."
  validation {
    condition = var.private_ip_address == "" || can(
      regex(
        module.commons.validation.global.ipv4_address.regex,
        var.private_ip_address
      )
    )
    error_message = module.commons.validation.global.ipv4_address.error_message
  }
}

variable "enable_termination_protection" {
  type        = bool
  description = "When true, the Management Server instance will be protected from accidental deletion."
  default    = false
}

variable "waf_version" {
  type = string
  description = "The Imperva WAF Gateway version to deploy (format: 'x.y.0.z')."
  validation {
    condition = contains(
      module.commons.validation.gcp.waf_version.allowed_values,
      var.waf_version
    )
    error_message = module.commons.validation.gcp.waf_version.error_message
  }
}

variable "post_script" {
  type        = string
  description = "An optional bash script or command that will be executed at the end of the Gateway instance startup."
  default     = ""
}