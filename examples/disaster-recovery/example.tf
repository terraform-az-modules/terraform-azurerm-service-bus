provider "azurerm" {
  features {}
}
data "azurerm_client_config" "current_client_config" {}
##-----------------------------------------------------------------------------
## Resources
##-----------------------------------------------------------------------------

locals {
  name        = "app"
  environment = "test"
  location    = "centralindia"
  label_order = ["name", "environment", "location"]
}

##----------------------------------------------------------------------------- 
## Resource Group
##-----------------------------------------------------------------------------

module "resource_group" {
  source                   = "terraform-az-modules/resource-group/azurerm"
  version                  = "1.0.3"
  name                     = local.name
  environment              = local.environment
  label_order              = local.label_order
  location                 = local.location
  resource_position_prefix = false
}

##----------------------------------------------------------------------------- 
## Vnet
##-----------------------------------------------------------------------------

module "vnet" {
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.3"
  name                = local.name
  environment         = local.environment
  label_order         = local.label_order
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##----------------------------------------------------------------------------- 
## Subnet 
##-----------------------------------------------------------------------------

module "subnet" {
  source               = "terraform-az-modules/subnet/azurerm"
  version              = "1.0.1"
  environment          = local.environment
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name

  subnets = [
    {
      name            = "subnet1"
      subnet_prefixes = ["10.0.1.0/24"]
    }
  ]

  # route_table
  enable_route_table = false
}

##----------------------------------------------------------------------------- 
## Log Analytics
##-----------------------------------------------------------------------------

module "log-analytics" {
  source                      = "terraform-az-modules/log-analytics/azurerm"
  version                     = "1.0.2"
  name                        = local.name
  environment                 = local.environment
  label_order                 = local.label_order
  log_analytics_workspace_sku = "PerGB2018"
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
}

# ------------------------------------------------------------------------------
# Private DNS Zone
# ------------------------------------------------------------------------------
module "private_dns_zone" {
  source              = "terraform-az-modules/private-dns/azurerm"
  version             = "1.0.4"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  label_order         = local.label_order
  private_dns_config = [
    {
      resource_type = "key_vault"
      vnet_ids      = [module.vnet.vnet_id]
    }
  ]
}

# ------------------------------------------------------------------------------
# Key Vault
# ------------------------------------------------------------------------------
module "vault" {
  source                        = "terraform-az-modules/key-vault/azurerm"
  version                       = "1.1.0"
  name                          = local.name
  environment                   = local.environment
  label_order                   = local.label_order
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  subnet_id                     = module.subnet.subnet_ids.subnet1
  public_network_access_enabled = true
  sku_name                      = "premium"
  private_dns_zone_ids          = module.private_dns_zone.private_dns_zone_ids.key_vault
  soft_delete_retention_days    = 7
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["0.0.0.0/0"]
  }
  reader_objects_ids = {
    "Key Vault Administrator" = {
      role_definition_name = "Key Vault Administrator"
      principal_id         = data.azurerm_client_config.current_client_config.object_id
    }
  }
  diagnostic_setting_enable  = true
  log_analytics_workspace_id = module.log-analytics.workspace_id
}

##----------------------------------------------------------------------------
## ServiceBus
##------------------------------------------------------------------------

module "service_bus" {
  source                       = "../.."
  name                         = local.name
  environment                  = local.environment
  resource_group_name          = module.resource_group.resource_group_name
  location                     = module.resource_group.resource_group_location
  sku                          = "Premium"
  capacity                     = 1
  premium_messaging_partitions = 1
  secondary_location           = "North Europe"
  key_vault_id                 = module.vault.id
  queues = [
    {
      name = "queue1"
      authorization_rules = [
        {
          name   = "queue1_ar"
          rights = ["listen", "send"]
        }
      ]
    }
  ]
  topics = [
    {
      name                = "topic1"
      enable_partitioning = true
      subscriptions = [
        {
          name               = "subs1"
          forward_to         = "queue1"
          max_delivery_count = 1
        }
      ]

      authorization_rules = [
        {
          name   = "topic1_ar"
          rights = ["listen", "send"]
        }
      ]
    }
  ]
  enable_disaster_recovery_config = true
  enable_diagnostic               = true
  log_analytics_workspace_id      = module.log-analytics.workspace_id
  depends_on                      = [module.vault]
}