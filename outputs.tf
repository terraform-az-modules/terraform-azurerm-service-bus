##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------

output "servicebus_primary_namespace_id" {
  description = "The Service Bus Primary Namespace ID."
  value       = azurerm_servicebus_namespace.primary[0].id
}

output "servicebus_primary_namespace_name" {
  description = "The Service Bus Primary Namespace Name."
  value       = azurerm_servicebus_namespace.primary[0].name
}

output "servicebus_primary_namespace_endpoint" {
  description = "The URL to access the Service Bus Primary Namespace."
  value       = azurerm_servicebus_namespace.primary[0].endpoint
}

output "servicebus_secondary_namespace_id" {
  description = "The Service Bus Secondary Namespace ID."
  value       = try(azurerm_servicebus_namespace.secondary[0].id, null)
}

output "servicebus_secondary_namespace_name" {
  description = "The Service Bus Secondary Namespace Name."
  value       = try(azurerm_servicebus_namespace.secondary[0].name, null)
}

output "servicebus_secondary_namespace_endpoint" {
  description = "The URL to access the Service Bus Secondary Namespace."
  value       = try(azurerm_servicebus_namespace.secondary[0].endpoint, null)
}

output "servicebus_namespace_authorization" {
  description = "Map of Service Bus namespace authorization rules to their primary and secondary keys."
  sensitive   = true

  value = {
    for r in azurerm_servicebus_namespace_authorization_rule.main :
    r.name => {
      id                          = r.id
      primary_key                 = r.primary_key
      secondary_key               = r.secondary_key
      primary_connection_string   = r.primary_connection_string
      secondary_connection_string = r.secondary_connection_string
    }
  }
}

output "servicebus_primary_namespace_cmk_id" {
  description = "The Primary Namespace Customer Managed Key ID."
  value       = try(azurerm_servicebus_namespace_customer_managed_key.main[0].id, null)
}

output "servicebus_disaster_recovery_config" {
  description = "Service Bus Disaster Recovery exported attributes"
  sensitive   = true
  value = {
    for k, v in azurerm_servicebus_namespace_disaster_recovery_config.main :
    v.name => {
      id                                = v.id
      primary_connection_string_alias   = v.primary_connection_string_alias
      secondary_connection_string_alias = v.secondary_connection_string_alias
      default_primary_key               = v.default_primary_key
      default_secondary_key             = v.default_secondary_key
    }
  }
}

output "servicebus_queue" {
  description = "The ServiceBus Queue ID."
  value       = { for k, v in azurerm_servicebus_queue.main : v.name => v.id }
}

output "servicebus_queue_authorization" {
  description = "Map of Service Bus namespace Queue authorization rules to their primary and secondary keys"
  sensitive   = true
  value = {
    for k, v in azurerm_servicebus_queue_authorization_rule.main :
    v.name => {
      id                                = v.id
      primary_connection_string         = v.primary_connection_string
      secondary_connection_string       = v.secondary_connection_string
      primary_connection_string_alias   = v.primary_connection_string_alias
      secondary_connection_string_alias = v.secondary_connection_string_alias
      primary_key                       = v.primary_key
      secondary_key                     = v.secondary_key
    }
  }
}

output "servicebus_subscription" {
  description = "The ServiceBus Subscription ID."
  value       = { for k, v in azurerm_servicebus_subscription.main : v.name => v.id }
}

output "servicebus_subscription_rule" {
  description = "The ServiceBus Subscription Rule ID."
  value       = { for k, v in azurerm_servicebus_subscription_rule.main : v.name => v.id }
}

output "servicebus_topic" {
  description = "The ServiceBus Topic ID."
  value       = { for k, v in azurerm_servicebus_topic.main : v.name => v.id }
}

output "servicebus_topic_authorization" {
  description = "Map of Service Bus namespace Topic authorization rules to their primary and secondary keys"
  sensitive   = true
  value = {
    for k, v in azurerm_servicebus_topic_authorization_rule.main :
    v.name => {
      id                                = v.id
      primary_connection_string         = v.primary_connection_string
      secondary_connection_string       = v.secondary_connection_string
      primary_connection_string_alias   = v.primary_connection_string_alias
      secondary_connection_string_alias = v.secondary_connection_string_alias
      primary_key                       = v.primary_key
      secondary_key                     = v.secondary_key
    }
  }
}





