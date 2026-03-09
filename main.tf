# 1. Setup Providers
terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.0" }
    helm    = { source = "hashicorp/helm", version = "~> 2.0" }
  }
}

provider "azurerm" { features {} }

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

# 2. Infrastructure (Resource Group & ACR)
resource "azurerm_resource_group" "rg" {
  name     = "three-tier-lab-rg"
  location = "eastus2" # Using East US 2 as requested
}

resource "azurerm_container_registry" "acr" {
  name                = "threetierreg${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
}

# 3. AKS Cluster (Tuned for 4 vCPU Free Limit)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "threetier-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "threetier"
  sku_tier            = "Free"

  default_node_pool {
    name                = "systempool"
    node_count          = 1               # Strictly 1 node to save vCPU
    vm_size             = "Standard_B2s"  # 2 vCPUs, 4GB RAM
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = false
  }

  identity { type = "SystemAssigned" }
}

# 4. Give AKS permission to pull from ACR
resource "azurerm_role_assignment" "aks_acr" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# 5. Install ArgoCD
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}