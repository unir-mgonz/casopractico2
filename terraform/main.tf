# En este fichero se define lo siguiente:
# - La version de terraform y sus requisitos
# - El provider cloud, en este caso Azure
# - La creación de un grupo de recursos con el tag "casopractico2"

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Lee ARM_SUBSCRIPTION_ID del entorno si var.subscription_id está vacío.
  subscription_id = var.subscription_id != "" ? var.subscription_id : null
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = "casopractico2"
  }
}
