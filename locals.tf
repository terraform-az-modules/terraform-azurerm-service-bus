##-----------------------------------------------------------------------------
## Locals
##-----------------------------------------------------------------------------
locals {
  name = var.custom_name != null ? var.custom_name : module.labels.id

  authorization_rules = [
    for rule in var.authorization_rules : merge({
      name   = ""
      rights = []
    }, rule)
  ]

  topics = [
    for topic in var.topics : merge({
      name                                    = ""
      status                                  = "Active"
      auto_delete_on_idle                     = null
      default_message_ttl                     = null
      duplicate_detection_history_time_window = null
      batched_operations_enabled              = null
      express_enabled                         = false
      partitioning_enabled                    = false
      max_message_size_in_kilobytes           = null
      max_size_in_megabytes                   = null
      enable_duplicate_detection              = null
      enable_ordering                         = null
      authorization_rules                     = []
      subscriptions                           = []
    }, topic)
  ]

  topic_authorization_rules = flatten([
    for topic in local.topics : [
      for rule in topic.authorization_rules : merge({
        name   = ""
        rights = []
        }, rule, {
        topic_name = topic.name
      })
    ]
  ])

  topic_subscriptions = flatten([
    for topic in local.topics : [
      for subscription in topic.subscriptions :
      merge({
        name                                        = ""
        max_delivery_count                          = 10
        auto_delete_on_idle                         = null
        default_message_ttl                         = null
        lock_duration                               = null
        enable_dead_lettering_on_message_expiration = false
        dead_lettering_on_filter_evaluation_error   = null
        enable_batched_operations                   = null
        enable_session                              = false
        forward_to                                  = null
        status                                      = "Active"
        client_scoped_subscription_enabled          = null
        client_scoped_subscription                  = null
        rules                                       = []
        }, subscription, {
        topic_name = topic.name
      })
    ]
  ])

  topic_subscription_rules = flatten([
    for subscription in local.topic_subscriptions : [
      for rule in subscription.rules : merge({
        name               = ""
        sql_filter         = ""
        action             = ""
        correaltion_filter = null
        }, rule, {
        topic_name        = subscription.topic_name
        subscription_name = subscription.name
      })
    ]
  ])

  queues = [
    for queue in var.queues : merge({
      name                                        = ""
      lock_duration                               = null
      max_message_size_in_kilobytes               = null
      max_size_in_megabytes                       = null
      enable_duplicate_detection                  = false
      enable_session                              = false
      default_message_ttl                         = null
      enable_dead_lettering_on_message_expiration = false
      duplicate_detection_history_time_window     = null
      max_delivery_count                          = 10
      status                                      = "Active"
      batched_operations_enabled                  = null
      auto_delete_on_idle                         = null
      partitioning_enabled                        = false
      express_enabled                             = false
      forward_to                                  = null
      forward_dead_lettered_messages_to           = null
      authorization_rules                         = []
    }, queue)
  ]

  queue_authorization_rules = flatten([
    for queue in local.queues : [
      for rule in queue.authorization_rules : merge({
        name   = ""
        rights = []
        }, rule, {
        queue_name = queue.name
      })
    ]
  ])
}
