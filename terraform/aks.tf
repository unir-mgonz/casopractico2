# =============================================================================
# aks.tf - Cluster AKS + integración con el ACR
# =============================================================================

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.aks_dns_prefix
  sku_tier            = "Free"

  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = "Standard_D2s_v3" # 2 vCPU
  }

  identity {
    type = "SystemAssigned"
  }

  tags = { environment = "casopractico2" }
}

# --- POSIBILIDAD a) Integración recomendada: rol AcrPull al kubelet ----------
resource "azurerm_role_assignment" "acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
