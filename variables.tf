##-----------------------------------------------------------------------------
## Variables
##-----------------------------------------------------------------------------

##-----------------------------------------------------------------------------
# Naming Convention
##-----------------------------------------------------------------------------

variable "resource_position_prefix" {
  type        = bool
  default     = false
  description = "If true, prefixes resource names instead of suffixing."
}

variable "custom_name" {
  type        = string
  default     = null
  description = "Optional custom name to override the base name in tags."
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment", "location"]
  description = "Label order, e.g. `name`,`application`,`centralus`."
}

variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "repository" {
  type        = string
  default     = ""
  description = "Terraform current module repo"
}

variable "managedby" {
  type        = string
  default     = ""
  description = "ManagedBy, eg ''."
}

variable "extra_tags" {
  type        = map(string)
  default     = null
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "deployment_mode" {
  type        = string
  default     = "terraform"
  description = "Specifies how the infrastructure/resource is deployed"
}

##-----------------------------------------------------------------------------
# Key Vault / CMK
##-----------------------------------------------------------------------------

variable "key_vault_id" {
  type        = string
  default     = null
  description = "ID of the Azure Key Vault used for customer-managed keys and secrets."
}

variable "key_expiration_date" {
  description = "Expiration date for the Key Vault key in ISO 8601 format (for example 2028-12-31T23:59:59Z)."
  type        = string
  default     = null
}

variable "key_type" {
  description = "Key type to create in Key Vault (for example RSA or RSA-HSM)."
  type        = string
  default     = "RSA-HSM"
}

variable "key_size" {
  description = "Size of the RSA key in bits (for example 2048, 3072, 4096)."
  type        = number
  default     = 2048
}

variable "key_permissions" {
  type        = list(string)
  default     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  description = "Key permissions to assign in Key Vault access policy or RBAC for this key."
}

variable "rotation_policy_config" {
  type = object({
    enabled              = bool
    time_before_expiry   = optional(string, "P30D")
    expire_after         = optional(string, "P90D")
    notify_before_expiry = optional(string, "P29D")
  })
  default = {
    enabled              = false
    time_before_expiry   = "P30D"
    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
  description = "Rotation policy configuration for Key Vault keys."
}

##-----------------------------------------------------------
## Service Bus Namespace
##-----------------------------------------------------------

variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "resource_group_name" {
  type        = string
  description = "The name of an existing resource group."
}

variable "location" {
  type        = string
  description = "The name of an existing resource group."
}

variable "sku" {
  type        = string
  default     = "Standard"
  description = "The SKU of the namespace. The options are: `Basic`, `Standard`, `Premium`."
}

variable "capacity" {
  type        = number
  default     = 0
  description = "Specifies the capacity. When sku is Premium, capacity can be 1, 2, 4, 8 or 16. When sku is Basic or Standard, capacity can be 0 only."
}

variable "premium_messaging_partitions" {
  type        = number
  default     = 0
  description = "Specifies the number messaging partitions. Only valid when sku is Premium and the minimum number is 1. Possible values include 0, 1, 2, and 4. Defaults to 0 for Standard, Basic namespace."
}

variable "local_auth_enabled" {
  type        = bool
  default     = false
  description = "Whether or not SAS authentication is enabled for the Service Bus namespace."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "public network access enabled for the Service Bus Namespace"
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "Minimum TLS version."

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be 1.0, 1.1, or 1.2."
  }
}

variable "infrastructure_encryption_enabled" {
  type        = bool
  default     = true
  description = "Enable double encryption (infrastructure encryption) for Service Bus Namespace"
}

variable "secondary_location" {
  type        = string
  default     = null
  description = "Location for Secondary Namespace."
}

variable "encryption" {
  type        = bool
  default     = true
  description = "Enable customer-managed encryption for the ServiceBus using Key Vault."
}

variable "identity" {
  description = "Managed identity configuration."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
}

variable "network_rule_set" {
  type = object({
    default_action                = optional(string, "Allow")
    public_network_access_enabled = optional(bool, true)
    trusted_services_allowed      = optional(bool, false)
    ip_rules                      = optional(list(string), [])
    network_rules = optional(list(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    })), [])
  })
  default     = null
  description = "Network rules for Service Bus Namespace."
}


variable "enable_disaster_recovery_config" {
  type        = bool
  default     = false
  description = "Enable or Disable Creation of Disaster Recovery Config for Service Bus Namespace."
}



variable "topics" {
  type        = any
  default     = []
  description = "List of topics."
}

variable "authorization_rules" {
  type        = any
  default     = []
  description = "List of namespace authorization rules."
}

variable "queues" {
  type        = any
  default     = []
  description = "List of queues."
}

##-----------------------------------------------------------------------------
## Diagnostic Setting Variables
##-----------------------------------------------------------------------------

variable "enable_diagnostic" {
  type        = bool
  default     = false
  description = "Enable diagnostic settings for Linux Web App."
}

variable "storage_account_id" {
  type        = string
  default     = null
  description = "Storage Account ID for diagnostic logs (optional)."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "Log Analytics Workspace ID for diagnostic logs."
}

variable "eventhub_name" {
  type        = string
  default     = null
  description = "Eventhub Name to pass it to destination details of diagnosys setting of NSG."
}

variable "eventhub_authorization_rule_id" {
  type        = string
  default     = null
  description = "Eventhub authorization rule id to pass it to destination details of diagnosys setting of NSG."
}

variable "log_enabled" {
  type        = bool
  default     = true
  description = "Enable log categories for diagnostic settings."
}

variable "metric_enabled" {
  type        = bool
  default     = true
  description = "Enable metrics for diagnostic settings."
}
