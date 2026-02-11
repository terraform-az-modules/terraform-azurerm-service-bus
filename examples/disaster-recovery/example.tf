provider "azurerm" {
  features {}
}

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
}