#!/bin/bash

# Este script ejecutara los comandos necesarios para desplegar y configurar la infra. Se debe ejecutar desde la misma carpeta donde se encuentra el fichero.

# Iniciamos y desplegamos infra con terraform.
# Los ficheros .tf estan en la carpeta terraform/, se lo indicamos con -chdir.

TERRAFORM_DIR=terraform

terraform -chdir=$TERRAFORM_DIR init
terraform -chdir=$TERRAFORM_DIR apply

# Guardamos el enlace a nuestro ACR en una variable
ACR=$(terraform -chdir=$TERRAFORM_DIR output -raw acr_login_server)

# Iniciamos sesion en dicha ACR con podman
podman login $ACR \
-u "$(terraform -chdir=$TERRAFORM_DIR output -raw acr_admin_username)" \
-p "$(terraform -chdir=$TERRAFORM_DIR output -raw acr_admin_password)"

# Construimos la imagen
podman build --platform=linux/amd64 -t $ACR/casopractico2:apache ./podman-web-app

# Pusheamos la imagen al ACR
podman push $ACR/casopractico2:apache

# Configuramos la VM con Ansible.
# Ansible se ejecuta en modo local en la propia VM, por lo que primero copiamos los ficheros necesarios usando scp.

VM_FQDN=$(terraform -chdir=$TERRAFORM_DIR output -raw vm_fqdn)

scp -r playbook.yml group_vars azureuser@$VM_FQDN:~/

# Instalamos Ansible en la VM y ejecutamos el playbook
ssh azureuser@$VM_FQDN '
  sudo apt-get update &&
  sudo apt-get install -y ansible &&
  ansible-playbook -i localhost, -c local playbook.yml
'

echo "======================================================="
echo "App desplegada en: https://$VM_FQDN"