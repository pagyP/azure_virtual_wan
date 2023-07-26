variable "projectname" {
  type    = string
  default = "Project2"
}

variable "core_location" {
  type    = string
  default = "eastus"
}

variable "firewall_sku" {
  type    = string
  default = "Premium"
}
variable "vhub_ip_groups" {
  type = map(object({
    name     = string
    cidrs    = list(string)
    location = string
  }))
  description = "A map to create ipgroups"
}

variable "spoke_vnets_ip_groups" {
  type = map(object({
    name     = string
    cidrs    = list(string)
    location = string
  }))
  description = "A map to create ipgroups for spoke vnets"
}

variable "spoke_subnets" {
  type = map(object({
    name  = string
    cidrs = list(string)
  }))
  description = "A map to create subnets for spoke vnets"
}

variable "myips" {
  type        = list(string)
  description = "A list of IP addresses to allow access to the firewall"
  default     = ["86.178.105.48"]
}


variable "enable_rbac_authorization" {
  description = "Enable RBAC authorization"
  default     = "true"
  type        = bool

}

variable "enabled_for_disk_encryption" {
  description = "Enable disk encryption"
  default     = "true"
  type        = bool

}

variable "enabled_for_template_deployment" {
  description = "Enable template deployment"
  default     = "true"
  type        = bool

}

variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "terraform-keyvault-%s"
  type        = string
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention days"
  default     = "90"
  type        = number
}

variable "purge_protection_enabled" {
  description = "Purge protection enabled"
  default     = "false"
  type        = bool
}



