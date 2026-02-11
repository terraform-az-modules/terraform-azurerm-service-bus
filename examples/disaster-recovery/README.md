<!-- BEGIN_TF_DOCS -->

# Terraform Azure Service Bus

This directory contains an example usage of the **terraform-azure-servicebus**. It demonstrates how to use the module with default settings or with custom configurations.

---

## 📋 Requirements

| Name      | Version   |
|-----------|-----------|
| Terraform | >= 1.6.6  |
| Azurerm   | >= 3.116.0|

---

## 🔌 Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.53.0 |


## 📦 Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_service_bus"></a> [service_bus](#module\service_bus) | ../../ | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-az-modules/resource-group/azurerm | 1.0.3 |


---

## 🏗️ Resources

No resources are directly created in this example.

---

## 🔧 Inputs

No input variables are defined in this example.

---

## 📤 Outputs

| Name | Description |
|------|-------------|
| <a name="output_servicebus_namespace_name"></a> [servicebus\_namespace\_name](#output\_servicebus\_namespace\_name) | The Name of the Service Bus Namespace. |
| <a name="output_servicebus_secondary_namespace_name"></a> [servicebus\_secondary_namespace\_name](#output\_secondary_servicebus\_namespace\_name) | The Name of the Secondary Service Bus Namespace. |
| <a name="output_servicebus_queue_id"></a> [servicebus\_queue\_id](#output\_servicebus\_queue\_id) | The ID of the Service Bus Queue. |
| <a name="output_servicebus_queue_auth_rule"></a> [servicebus\_queue\_auth_rule](#output\_servicebus\_queue\_auth_rule) | The Authorization Rule for the Service Bus Queue. |
| <a name="output_servicebus_topics_id"></a> [servicebus\_topics\_id](#output\_servicebus\_topics\_id) | The ID of the Service Bus Topics. |
| <a name="output_servicebus_topics_auth_rule"></a> [servicebus\_topics\_auth_rule](#output\_servicebus\_topics\_auth_rule) | The Authorization Rule for the Service Bus Topics. |
| <a name="output_servicebus_subscriptions_id"></a> [servicebus\_subscriptions\_id](#output\_servicebus\_subscriptions\_id) | The ID of the Service Bus Topic's Subscription. |
| <a name="output_servicebus_disaster_recovery_id"></a> [servicebus\_disaster_recovery\_id](#output\_servicebus\_disaster_recovery\_id) | The ID of the Service Bus Namespace Disaster Recovery Config. |
<!-- END_TF_DOCS -->