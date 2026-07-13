# En este fichero definimos las variables que usaremos en este despliegue de terraform

variable "subscription_id" {
  description = "ID de suscripción. Vacío si usas ARM_SUBSCRIPTION_ID."
  type        = string
  default     = ""
}

variable "location" {
  description = "Región (cuenta de estudiante: NO West Europe). Permitidas: swedencentral, francecentral, polandcentral, italynorth..."
  type        = string
  default     = "spaincentral"
}

variable "resource_group_name" {
  type    = string
  default = "casopractico2"
}

# --- ACR ---------------------------------------------------------------------
# El enlace del registro tomara el formato: acr_name.azurecr.io

variable "acr_name" {
  description = "Nombre del ACR (único global, minúsculas y números)."
  type        = string
  default     = "unirmgonzacr"
}

# --- VM ----------------------------------------------------------------------
variable "vm_name" {
  type    = string
  default = "casopractico2-vm"
}

variable "vm_size" {
  description = "Tamaño de la VM. B2ats_v2 = 2 vCPU burstable AMD64 (free tier, imágenes amd64). Alternativa ARM: B2pts_v2 (imágenes arm64)."
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Ruta a la clave pública SSH para acceder a la VM."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# FQDN <domain_name_label>.<location>.cloudapp.azure.com
# El nombre deber de ser unico dentro de la región
variable "domain_name_label" {
  description = "Etiqueta para poder recibir FQDN con el formato <label>.<location>.cloudapp.azure.com"
  type        = string
  default     = "podman-unir-mgonz2"
}

# --- Certbot -------------------------------------------------
variable "certbot_email" {
  description = "Correo de registro en Let's Encrypt"
  type        = string
  default     = "mauricio.gonzal5300@comunidadunir.net"
}

# Usamos un bool true/false para hacer pruebas sin que nos limite certbot. Se utiliza en podman-web-app/entrypoint.sh
variable "certbot_staging" {
  description = "true = entorno de pruebas"
  type        = bool
  default     = false
}


# --- AKS ---------------------------------------------------------------------
variable "aks_name" {
  description = "Nombre del cluster AKS"
  type        = string
  default     = "cp2-aks-cluster"
}

# El FQDN del API server sera: <dns_prefix>-<hash>.hcp.<location>.azmk8s.io
variable "aks_dns_prefix" {
  description = "Prefijo DNS de AKS"
  type        = string
  default     = "cp2aks"
}

variable "aks_node_count" {
  description = "Numero de nodos"
  type        = number
  default     = 1
}