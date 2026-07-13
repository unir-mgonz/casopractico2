# En este fichero se define:
# - La configuración de red y subred
# - La configuración del firewall (Azure Network Security Group, NSG)

# Red virtual donde se ubicará la VM.
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subred dentro de la red virtual.
resource "azurerm_subnet" "subnet" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# IP pública para acceder a la VM (SSH y HTTPS) desde Internet.
# Utilizamos domain_name_label, para que azure nos proporcione un FQDN estable.
# (<label>.<region>.cloudapp.azure.com)
# La idea es solicitar un certificado de certbot para este dominio.

resource "azurerm_public_ip" "vm_pip" {
  name                = "${var.vm_name}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.domain_name_label != "" ? var.domain_name_label : null
}

# Creamos un grupo de seguridad que permita las conexiones a traves de los puertos 22(ssh), 80(http) y 443(https)
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Interfaz de red de la VM, asociada a la subred y a la IP pública.
resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }
}

# Asociación del NSG a la interfaz de red.
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Máquina virtual Linux (Ubuntu 26.04).

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = var.vm_size
  admin_username                  = var.vm_admin_username
  network_interface_ids           = [azurerm_network_interface.vm_nic.id]
  disable_password_authentication = true # solo clave SSH (más seguro que contraseña)

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Elegimos el sistema operativo: Ubuntu 26.04 LTS.
  
  # Utilizamos el siguiente comando para ver las ofertas de sistema operativo en spaincentral:
  # > az vm image list-offers  --publisher Canonical --location westeurope --query '[].name' -o tsv
  # Y el siguiente comando para comprobar los skus:
  # > az vm image list-skus    --publisher Canonical --offer ubuntu-26_04-lts --location spaincentral --query '[].name' -o tsv

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-26_04-lts"
    sku       = "server"
    version   = "latest"
  }


  tags = {
    environment = "casopractico2"
  }
}
