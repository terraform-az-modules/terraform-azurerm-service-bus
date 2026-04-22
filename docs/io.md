## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| authorization\_rules | List of namespace authorization rules. | <pre>list(object({<br>    name   = string<br>    rights = list(string)<br>  }))</pre> | `[]` | no |
| capacity | Specifies the capacity. When sku is Premium, capacity can be 1, 2, 4, 8 or 16. When sku is Basic or Standard, capacity can be 0 only. | `number` | `0` | no |
| custom\_name | Optional custom name to override the base name in tags. | `string` | `null` | no |
| deployment\_mode | Specifies how the infrastructure/resource is deployed | `string` | `"terraform"` | no |
| enable\_diagnostic | Enable diagnostic settings for Linux Web App. | `bool` | `false` | no |
| enable\_disaster\_recovery\_config | Enable or Disable Creation of Disaster Recovery Config for Service Bus Namespace. | `bool` | `false` | no |
| enabled | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| encryption | Enable customer-managed encryption for the ServiceBus using Key Vault. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| eventhub\_authorization\_rule\_id | Eventhub authorization rule id to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| eventhub\_name | Eventhub Name to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| extra\_tags | Additional tags (e.g. map(`BusinessUnit`,`XYZ`). | `map(string)` | `null` | no |
| identity\_ids | List of user managed identity IDs for MSSQL DB. | `list(string)` | `null` | no |
| infrastructure\_encryption\_enabled | Enable double encryption (infrastructure encryption) for Service Bus Namespace | `bool` | `true` | no |
| key\_expiration\_date | Expiration date for the Key Vault key in ISO 8601 format (for example 2028-12-31T23:59:59Z). | `string` | `null` | no |
| key\_permissions | Key permissions to assign in Key Vault access policy or RBAC for this key. | `list(string)` | <pre>[<br>  "decrypt",<br>  "encrypt",<br>  "sign",<br>  "unwrapKey",<br>  "verify",<br>  "wrapKey"<br>]</pre> | no |
| key\_size | Size of the RSA key in bits (for example 2048, 3072, 4096). | `number` | `2048` | no |
| key\_type | Key type to create in Key Vault (for example RSA or RSA-HSM). | `string` | `"RSA-HSM"` | no |
| key\_vault\_id | ID of the Azure Key Vault used for customer-managed keys and secrets. | `string` | `null` | no |
| label\_order | Label order, e.g. `name`,`application`,`centralus`. | `list(any)` | <pre>[<br>  "name",<br>  "environment",<br>  "location"<br>]</pre> | no |
| local\_auth\_enabled | Whether or not SAS authentication is enabled for the Service Bus namespace. | `bool` | `false` | no |
| location | The name of an existing resource group. | `string` | n/a | yes |
| log\_analytics\_workspace\_id | Log Analytics Workspace ID for diagnostic logs. | `string` | `null` | no |
| log\_enabled | Enable log categories for diagnostic settings. | `bool` | `true` | no |
| managedby | ManagedBy, eg ''. | `string` | `""` | no |
| metric\_enabled | Enable metrics for diagnostic settings. | `bool` | `true` | no |
| minimum\_tls\_version | Minimum TLS version. | `string` | `"1.2"` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| network\_rule\_set | Network rules for Service Bus Namespace. | <pre>object({<br>    default_action                = optional(string, "Allow")<br>    public_network_access_enabled = optional(bool, true)<br>    trusted_services_allowed      = optional(bool, false)<br>    ip_rules                      = optional(list(string), [])<br>    network_rules = optional(list(object({<br>      subnet_id                            = string<br>      ignore_missing_vnet_service_endpoint = optional(bool, false)<br>    })), [])<br>  })</pre> | `null` | no |
| premium\_messaging\_partitions | Specifies the number messaging partitions. Only valid when sku is Premium and the minimum number is 1. Possible values include 0, 1, 2, and 4. Defaults to 0 for Standard, Basic namespace. | `number` | `0` | no |
| public\_network\_access\_enabled | public network access enabled for the Service Bus Namespace | `bool` | `false` | no |
| queues | List of queues with optional authorization rules. | <pre>list(object({<br>    name                                        = string<br>    lock_duration                               = optional(string)<br>    max_message_size_in_kilobytes               = optional(number)<br>    max_size_in_megabytes                       = optional(number)<br>    enable_duplicate_detection                  = optional(bool, false)<br>    enable_session                              = optional(bool, false)<br>    default_message_ttl                         = optional(string)<br>    enable_dead_lettering_on_message_expiration = optional(bool, false)<br>    duplicate_detection_history_time_window     = optional(string)<br>    max_delivery_count                          = optional(number, 10)<br>    status                                      = optional(string, "Active")<br>    batched_operations_enabled                  = optional(bool, null)<br>    auto_delete_on_idle                         = optional(string)<br>    partitioning_enabled                        = optional(bool, false)<br>    express_enabled                             = optional(bool, false)<br>    forward_to                                  = optional(string)<br>    forward_dead_lettered_messages_to           = optional(string)<br>    authorization_rules = optional(list(object({<br>      name   = string<br>      rights = list(string)<br>    })), [])<br>  }))</pre> | `[]` | no |
| repository | Terraform current module repo | `string` | `""` | no |
| resource\_group\_name | The name of an existing resource group. | `string` | n/a | yes |
| resource\_position\_prefix | If true, prefixes resource names instead of suffixing. | `bool` | `false` | no |
| rotation\_policy\_config | Rotation policy configuration for Key Vault keys. | <pre>object({<br>    enabled              = bool<br>    time_before_expiry   = optional(string, "P30D")<br>    expire_after         = optional(string, "P90D")<br>    notify_before_expiry = optional(string, "P29D")<br>  })</pre> | <pre>{<br>  "enabled": false,<br>  "expire_after": "P90D",<br>  "notify_before_expiry": "P29D",<br>  "time_before_expiry": "P30D"<br>}</pre> | no |
| secondary\_location | Location for Secondary Namespace. | `string` | `null` | no |
| sku | The SKU of the namespace. The options are: `Basic`, `Standard`, `Premium`. | `string` | `"Standard"` | no |
| storage\_account\_id | Storage Account ID for diagnostic logs (optional). | `string` | `null` | no |
| topics | List of topics with subscriptions and authorization rules. | <pre>list(object({<br>    name                                    = string<br>    status                                  = optional(string, "Active")<br>    auto_delete_on_idle                     = optional(string)<br>    default_message_ttl                     = optional(string)<br>    duplicate_detection_history_time_window = optional(string)<br>    batched_operations_enabled              = optional(bool, null)<br>    express_enabled                         = optional(bool, false)<br>    partitioning_enabled                    = optional(bool, false)<br>    max_message_size_in_kilobytes           = optional(number)<br>    max_size_in_megabytes                   = optional(number)<br>    enable_duplicate_detection              = optional(bool, null)<br>    enable_ordering                         = optional(bool, null)<br>    authorization_rules = optional(list(object({<br>      name   = string<br>      rights = list(string)<br>    })), [])<br>    subscriptions = optional(list(object({<br>      name                                        = string<br>      max_delivery_count                          = optional(number, 10)<br>      auto_delete_on_idle                         = optional(string)<br>      default_message_ttl                         = optional(string)<br>      lock_duration                               = optional(string)<br>      enable_dead_lettering_on_message_expiration = optional(bool, false)<br>      dead_lettering_on_filter_evaluation_error   = optional(bool, null)<br>      enable_batched_operations                   = optional(bool, null)<br>      enable_session                              = optional(bool, false)<br>      forward_to                                  = optional(string)<br>      status                                      = optional(string, "Active")<br>      client_scoped_subscription_enabled          = optional(bool, null)<br>      client_scoped_subscription                  = optional(string)<br>      rules = optional(list(object({<br>        name              = string<br>        sql_filter        = optional(string, "")<br>        action            = optional(string, "")<br>        correltion_filter = optional(any, null)<br>      })), [])<br>    })), [])<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| servicebus\_disaster\_recovery\_config | Service Bus Disaster Recovery exported attributes |
| servicebus\_namespace\_authorization | Map of Service Bus namespace authorization rules to their primary and secondary keys. |
| servicebus\_primary\_namespace\_cmk\_id | The Primary Namespace Customer Managed Key ID. |
| servicebus\_primary\_namespace\_endpoint | The URL to access the Service Bus Primary Namespace. |
| servicebus\_primary\_namespace\_id | The Service Bus Primary Namespace ID. |
| servicebus\_primary\_namespace\_name | The Service Bus Primary Namespace Name. |
| servicebus\_queue | The ServiceBus Queue ID. |
| servicebus\_queue\_authorization | Map of Service Bus namespace Queue authorization rules to their primary and secondary keys |
| servicebus\_secondary\_namespace\_endpoint | The URL to access the Service Bus Secondary Namespace. |
| servicebus\_secondary\_namespace\_id | The Service Bus Secondary Namespace ID. |
| servicebus\_secondary\_namespace\_name | The Service Bus Secondary Namespace Name. |
| servicebus\_subscription | The ServiceBus Subscription ID. |
| servicebus\_subscription\_rule | The ServiceBus Subscription Rule ID. |
| servicebus\_topic | The ServiceBus Topic ID. |
| servicebus\_topic\_authorization | Map of Service Bus namespace Topic authorization rules to their primary and secondary keys |

