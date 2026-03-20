provider "azurerm" {
  features {}
}

module "service-bus" {
  source = "../../"
}
