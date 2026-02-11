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
      status               = "Active"
      express_enabled      = false
      partitioning_enabled = false
      authorization_rules  = []
      subscriptions        = []
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
      merge(subscription, {
        topic_name = topic.name
      })
    ]
  ])

  topic_subscription_rules = flatten([
    for subscription in local.topic_subscriptions : [
      for rule in subscription.rules : merge(rule, {
        topic_name        = subscription.topic_name
        subscription_name = subscription.name
      })
    ]
  ])

  queues = [
    for queue in var.queues : merge({
      enable_duplicate_detection = false
      enable_session             = false
      max_delivery_count         = 10
      status                     = "Active"
      partitioning_enabled       = false
      express_enabled            = false
      authorization_rules        = []
    }, queue)
  ]

  queue_authorization_rules = flatten([
    for queue in local.queues : [
      for rule in queue.authorization_rules : merge(rule, {
        queue_name = queue.name
      })
    ]
  ])
}
