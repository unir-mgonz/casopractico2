# En este fichero le indicamos a terraform las variables que queremos conocer una vez sea desplegada nuestra infra.
# Tambien se genera automaticamente el inventario de Ansible a partir de los outputs de terraform.


output "vm_public_ip" {
  description = "IP pública de la VM (para SSH y para la web)."
  value       = azurerm_public_ip.vm_pip.ip_address
}

output "vm_fqdn" {
  description = "Nombre DNS de la VM. Vacío si no se definió domain_name_label."
  value       = azurerm_public_ip.vm_pip.fqdn
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  value = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}

# --- Generación automática del inventario de Ansible -------------------------
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../hosts.ini"
  content  = <<-EOT
    # Generado por Terraform — NO editar a mano.
    [podman_vm]
    cp2demo-vm ansible_host=${azurerm_public_ip.vm_pip.ip_address}

    [podman_vm:vars]
    ansible_user=${var.vm_admin_username}
    ansible_ssh_common_args='-o StrictHostKeyChecking=no'
  EOT
}

# --- Generación automática de las variables del ACR (group_vars) -------------

resource "local_file" "ansible_acr_vars" {
  filename = "${path.module}/../group_vars/all.yml"
  content  = <<-EOT
    # Generado por Terraform — NO editar a mano. (En real: cifrar con Ansible Vault.)
    acr_login_server: "${azurerm_container_registry.acr.login_server}"
    acr_username: "${azurerm_container_registry.acr.admin_username}"
    acr_password: "${azurerm_container_registry.acr.admin_password}"
    image_tag: "casopractico2"
  EOT
}
