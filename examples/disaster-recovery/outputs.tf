##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------

output "servicebus_namespace_name" {
  description = "The Name of ServiceBus Namespace."
  value       = module.service_bus.servicebus_primary_namespace_name
}

output "servicebus_seondary_namespace_name" {
  description = "The Name of ServiceBus Namespace."
  value       = module.service_bus.servicebus_secondary_namespace_name
}

output "servicebus_queue" {
  description = "The Queue of ServiceBus."
  value       = module.service_bus.servicebus_queue
}

output "servicebus_queue_auth_rule" {
  description = "The Authorization Rule for Queue of ServiceBus."
  value       = module.service_bus.servicebus_queue_authorization
  sensitive   = true
}

output "servicebus_topics" {
  description = "The Topic of ServiceBus."
  value       = module.service_bus.servicebus_topic
}

output "servicebus_topics_auth_rule" {
  description = "The Authorization Rule for Topic of ServiceBus."
  value       = module.service_bus.servicebus_topic_authorization
  sensitive   = true
}

output "servicebus_subscription" {
  description = "The Subscription for topic of ServiceBus."
  value       = module.service_bus.servicebus_subscription
}

output "servicebus_disaster_recovery_id" {
  description = "The ID of the Disaster Recovery of Namespace."
  value       = module.service_bus.servicebus_disaster_recovery_config
  sensitive   = true
}