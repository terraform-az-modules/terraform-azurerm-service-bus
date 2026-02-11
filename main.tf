##-----------------------------------------------------------------------------
## Resources
##-----------------------------------------------------------------------------
##-----------------------------------------------------------------------------
## Tagging Module – Applies standard tags to all resources
##-----------------------------------------------------------------------------
module "labels" {
  source          = "terraform-az-modules/tags/azurerm"
  version         = "1.0.2"
  name            = var.custom_name == null ? var.name : var.custom_name
  location        = var.location
  environment     = var.environment
  managedby       = var.managedby
  label_order     = var.label_order
  repository      = var.repository
  deployment_mode = var.deployment_mode
  extra_tags      = var.extra_tags
}

##-----------------------------------------------------------------------------
## Key Vault Key - Deploy encryption key for ServiceBus content
##-----------------------------------------------------------------------------
resource "azurerm_key_vault_key" "main" {
  depends_on      = [azurerm_role_assignment.identity_assigned, azurerm_user_assigned_identity.identity]
  count           = var.enabled && var.encryption ? 1 : 0
  name            = var.resource_position_prefix ? format("cmk-key-servicebus-%s", local.name) : format("%s-cmk-key-servicebus", local.name)
  key_vault_id    = var.key_vault_id
  key_type        = var.key_type
  key_size        = var.key_size
  expiration_date = var.key_expiration_date
  key_opts        = var.key_permissions
  dynamic "rotation_policy" {
    for_each = var.rotation_policy_config.enabled ? [1] : []
    content {
      automatic {
        time_before_expiry = var.rotation_policy_config.time_before_expiry
      }
      expire_after         = var.rotation_policy_config.expire_after
      notify_before_expiry = var.rotation_policy_config.notify_before_expiry
    }
  }
}

resource "azurerm_role_assignment" "identity_assigned" {
  count                = var.enabled && var.encryption && var.identity == null ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.identity[0].principal_id
  role_definition_name = "Key Vault Crypto User"
  scope                = var.key_vault_id
  depends_on           = [azurerm_user_assigned_identity.identity]
}

##-----------------------------------------------------------------------------
## Managed Identity - Deploy user-assigned identity for ServiceBus encryption
##-----------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "identity" {
  count               = var.enabled && var.encryption && var.identity == null ? 1 : 0
  location            = var.location
  name                = var.resource_position_prefix ? format("mid-servicebus-%s", local.name) : format("%s-mid-servicebus", local.name)
  resource_group_name = var.resource_group_name
}

##------------------------------------------------------------------------------
## ServiceBus
##------------------------------------------------------------------------------

resource "azurerm_servicebus_namespace" "primary" {
  count                         = var.enabled ? 1 : 0
  name                          = format(var.resource_position_prefix ? "servicebus-ns-primary-%s" : "%s-primary-ns-servicebus", local.name)
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.sku
  capacity                      = var.capacity
  premium_messaging_partitions  = var.premium_messaging_partitions
  local_auth_enabled            = var.local_auth_enabled
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = var.minimum_tls_version

  dynamic "customer_managed_key" {
    for_each = var.identity.type == "UserAssigned" || var.identity == null ? [1] : []
    content {
      key_vault_key_id                  = azurerm_key_vault_key.main[0].id
      identity_id                       = var.identity == null ? azurerm_user_assigned_identity.identity[0].id : var.identity.identity_ids
      infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
    }
  }

  dynamic "network_rule_set" {
    for_each = var.network_rule_set != null ? [var.network_rule_set] : []
    content {
      default_action                = network_rule_set.value.default_action
      public_network_access_enabled = network_rule_set.value.public_network_access_enabled
      trusted_services_allowed      = network_rule_set.value.trusted_services_allowed
      ip_rules                      = network_rule_set.value.ip_rules

      dynamic "network_rules" {
        for_each = lookup(network_rule_set.value, "network_rules", [])
        iterator = network_rules
        content {
          subnet_id                            = network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = network_rules.value.ignore_missing_vnet_service_endpoint
        }
      }
    }
  }

  dynamic "identity" {
    for_each = var.identity != null || (var.encryption && var.identity == null) ? [1] : []
    content {
      type         = var.identity != null ? var.identity.type : "UserAssigned"
      identity_ids = var.identity != null ? var.identity.identity_ids : [azurerm_user_assigned_identity.identity[0].id]
    }
  }
  tags       = module.labels.tags
  depends_on = [azurerm_key_vault_key.main]
}

resource "azurerm_servicebus_namespace" "secondary" {
  count                         = var.enabled && var.enable_disaster_recovery_config ? 1 : 0
  name                          = format(var.resource_position_prefix ? "servicebus-ns-secondary-%s" : "%s-secondary-ns-servicebus", local.name)
  location                      = var.secondary_location == null ? var.location : var.secondary_location
  resource_group_name           = var.resource_group_name
  sku                           = var.sku
  capacity                      = var.capacity
  premium_messaging_partitions  = var.premium_messaging_partitions
  local_auth_enabled            = var.local_auth_enabled
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = var.minimum_tls_version

  dynamic "customer_managed_key" {
    for_each = var.encryption ? [1] : []
    content {
      key_vault_key_id                  = azurerm_key_vault_key.main[0].id
      identity_id                       = azurerm_user_assigned_identity.identity[0].id
      infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
    }
  }

  dynamic "network_rule_set" {
    for_each = var.network_rule_set != null ? [var.network_rule_set] : []
    content {
      default_action                = network_rule_set.value.default_action
      public_network_access_enabled = network_rule_set.value.public_network_access_enabled
      trusted_services_allowed      = network_rule_set.value.trusted_services_allowed
      ip_rules                      = network_rule_set.value.ip_rules

      dynamic "network_rules" {
        for_each = lookup(network_rule_set.value, "network_rules", [])
        iterator = network_rules
        content {
          subnet_id                            = network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = network_rules.value.ignore_missing_vnet_service_endpoint
        }
      }
    }
  }

  dynamic "identity" {
    for_each = var.identity != null || (var.encryption && var.identity == null) ? [1] : []
    content {
      type         = var.identity != null ? var.identity.type : "UserAssigned"
      identity_ids = var.identity != null ? var.identity.identity_ids : [azurerm_user_assigned_identity.identity[0].id]
    }
  }
  tags       = module.labels.tags
  depends_on = [azurerm_servicebus_namespace.primary]
}

resource "azurerm_servicebus_namespace_authorization_rule" "main" {
  count        = var.enabled ? length(local.authorization_rules) : 0
  name         = local.authorization_rules[count.index].name
  namespace_id = azurerm_servicebus_namespace.primary[0].id
  listen       = contains(local.authorization_rules[count.index].rights, "listen") ? true : false
  send         = contains(local.authorization_rules[count.index].rights, "send") ? true : false
  manage       = contains(local.authorization_rules[count.index].rights, "manage") ? true : false
  depends_on   = [azurerm_servicebus_namespace.primary]
}

resource "azurerm_servicebus_namespace_customer_managed_key" "main" {
  count                             = var.enabled && try(azurerm_servicebus_namespace.primary[0].identity[0].type, "") == "SystemAssigned" ? 1 : 0
  namespace_id                      = azurerm_servicebus_namespace.primary[0].id
  key_vault_key_id                  = azurerm_key_vault_key.main[0].id
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
}

resource "azurerm_servicebus_namespace_disaster_recovery_config" "main" {
  count                = var.enabled && var.enable_disaster_recovery_config ? 1 : 0
  name                 = format(var.resource_position_prefix ? "servicebus-disaster-recovery-%s" : "%s-disaster-recovery-servicebus", local.name)
  primary_namespace_id = azurerm_servicebus_namespace.primary[0].id
  partner_namespace_id = azurerm_servicebus_namespace.secondary[0].id
  depends_on           = [azurerm_servicebus_namespace.primary, azurerm_servicebus_namespace.secondary]
}

resource "azurerm_servicebus_topic" "main" {
  count                                   = var.enabled ? length(local.topics) : 0
  name                                    = local.topics[count.index].name
  namespace_id                            = azurerm_servicebus_namespace.primary[0].id
  status                                  = local.topics[count.index].status
  auto_delete_on_idle                     = local.topics[count.index].auto_delete_on_idle
  default_message_ttl                     = local.topics[count.index].default_message_ttl
  duplicate_detection_history_time_window = local.topics[count.index].duplicate_detection_history_time_window
  batched_operations_enabled              = local.topics[count.index].batched_operations_enabled
  express_enabled                         = local.topics[count.index].express_enabled
  partitioning_enabled                    = local.topics[count.index].partitioning_enabled
  max_message_size_in_kilobytes           = local.topics[count.index].max_message_size_in_kilobytes
  max_size_in_megabytes                   = local.topics[count.index].max_size_in_megabytes
  requires_duplicate_detection            = local.topics[count.index].enable_duplicate_detection
  support_ordering                        = local.topics[count.index].enable_ordering
  depends_on                              = [azurerm_servicebus_namespace.primary]
}

resource "azurerm_servicebus_topic_authorization_rule" "main" {
  count      = var.enabled ? length(local.topic_authorization_rules) : 0
  name       = local.topic_authorization_rules[count.index].name
  topic_id   = azurerm_servicebus_topic.main[count.index].id
  listen     = contains(local.topic_authorization_rules[count.index].rights, "listen") ? true : false
  send       = contains(local.topic_authorization_rules[count.index].rights, "send") ? true : false
  manage     = contains(local.topic_authorization_rules[count.index].rights, "manage") ? true : false
  depends_on = [azurerm_servicebus_topic.main]
}

resource "azurerm_servicebus_subscription" "main" {
  count                                     = var.enabled ? length(local.topic_subscriptions) : 0
  name                                      = local.topic_subscriptions[count.index].name
  topic_id                                  = azurerm_servicebus_topic.main[count.index].id
  max_delivery_count                        = local.topic_subscriptions[count.index].max_delivery_count
  auto_delete_on_idle                       = local.topic_subscriptions[count.index].auto_delete_on_idle
  default_message_ttl                       = local.topic_subscriptions[count.index].default_message_ttl
  lock_duration                             = local.topic_subscriptions[count.index].lock_duration
  dead_lettering_on_message_expiration      = local.topic_subscriptions[count.index].enable_dead_lettering_on_message_expiration
  dead_lettering_on_filter_evaluation_error = local.topic_subscriptions[count.index].dead_lettering_on_filter_evaluation_error
  batched_operations_enabled                = local.topic_subscriptions[count.index].enable_batched_operations
  requires_session                          = local.topic_subscriptions[count.index].enable_session
  forward_to                                = local.topic_subscriptions[count.index].forward_to
  status                                    = local.topic_subscriptions[count.index].status
  client_scoped_subscription_enabled        = local.topic_subscriptions[count.index].client_scoped_subscription_enabled

  dynamic "client_scoped_subscription" {
    for_each = local.topic_subscriptions[count.index].client_scoped_subscription != null ? [local.topic_subscriptions[count.index].client_scoped_subscription] : []
    content {
      client_id                               = client_scoped_subscription.value.client_id
      is_client_scoped_subscription_shareable = client_scoped_subscription.value.is_client_scoped_subscription_shareable
      is_client_scoped_subscription_durable   = client_scoped_subscription.value.is_client_scoped_subscription_durable
    }
  }
  depends_on = [azurerm_servicebus_topic.main, azurerm_servicebus_queue.main]
}

resource "azurerm_servicebus_subscription_rule" "main" {
  count           = var.enabled ? length(local.topic_subscription_rules) : 0
  name            = local.topic_subscription_rules[count.index].name
  subscription_id = azurerm_servicebus_subscription.main[count.index].id
  filter_type     = local.topic_subscription_rules[count.index].sql_filter != "" ? "SqlFilter" : null
  sql_filter      = local.topic_subscription_rules[count.index].sql_filter
  action          = local.topic_subscription_rules[count.index].action

  dynamic "correlation_filter" {
    for_each = local.topic_subscription_rules[count.index].correlation_filter == "CorrelationFilter" && local.topic_subscription_rules[count.index].correlation_filter != null ? [local.topic_subscription_rules[count.index].correlation_filter] : []
    content {
      content_type        = correlation_filter.value.content_type
      correlation_id      = correlation_filter.value.correlation_id
      label               = correlation_filter.value.label
      message_id          = correlation_filter.value.message_id
      reply_to            = correlation_filter.value.reply_to
      reply_to_session_id = correlation_filter.value.reply_to_session_id
      session_id          = correlation_filter.value.session_id
      to                  = correlation_filter.value.to
      properties          = correlation_filter.value.properties
    }
  }
  depends_on = [azurerm_servicebus_subscription.main]
}

resource "azurerm_servicebus_queue" "main" {
  count                                   = var.enabled ? length(local.queues) : 0
  name                                    = local.queues[count.index].name
  namespace_id                            = azurerm_servicebus_namespace.primary[0].id
  lock_duration                           = local.queues[count.index].lock_duration
  max_message_size_in_kilobytes           = local.queues[count.index].max_message_size_in_kilobytes
  max_size_in_megabytes                   = local.queues[count.index].max_size_in_megabytes
  requires_duplicate_detection            = local.queues[count.index].enable_duplicate_detection
  requires_session                        = local.queues[count.index].enable_session
  default_message_ttl                     = local.queues[count.index].default_message_ttl
  dead_lettering_on_message_expiration    = local.queues[count.index].enable_dead_lettering_on_message_expiration
  duplicate_detection_history_time_window = local.queues[count.index].duplicate_detection_history_time_window
  max_delivery_count                      = local.queues[count.index].max_delivery_count
  status                                  = local.queues[count.index].status
  batched_operations_enabled              = local.queues[count.index].batched_operations_enabled
  auto_delete_on_idle                     = local.queues[count.index].auto_delete_on_idle
  partitioning_enabled                    = local.queues[count.index].partitioning_enabled
  express_enabled                         = local.queues[count.index].express_enabled
  forward_to                              = local.queues[count.index].forward_to
  forward_dead_lettered_messages_to       = local.queues[count.index].forward_dead_lettered_messages_to
  depends_on                              = [azurerm_servicebus_namespace.primary]
}

resource "azurerm_servicebus_queue_authorization_rule" "main" {
  count      = var.enabled ? length(local.queue_authorization_rules) : 0
  name       = local.queue_authorization_rules[count.index].name
  queue_id   = azurerm_servicebus_queue.main[count.index].id
  listen     = contains(local.queue_authorization_rules[count.index].rights, "listen") ? true : false
  send       = contains(local.queue_authorization_rules[count.index].rights, "send") ? true : false
  manage     = contains(local.queue_authorization_rules[count.index].rights, "manage") ? true : false
  depends_on = [azurerm_servicebus_queue.main]
}

#------------------------------------------------------------------
# azurerm monitoring diagnostics  - Default is "false"
#------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "web_app_diag" {
  count = var.enabled && var.enable_diagnostic ? 1 : 0
  name  = var.resource_position_prefix ? format("servicebus-diag-%s", local.name) : format("%s-diag-servicebus", local.name)

  target_resource_id             = azurerm_servicebus_namespace.primary[0].id
  storage_account_id             = var.storage_account_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id

  dynamic "enabled_metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = enabled_metric.value
    }
  }

  dynamic "enabled_log" {
    for_each = var.log_enabled ? ["allLogs"] : []
    content {
      category_group = enabled_log.value
    }
  }

  lifecycle {
    ignore_changes = [enabled_log, enabled_metric]
  }
}