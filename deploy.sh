#!/bin/bash

# Este script ejecutara los comandos necesarios para desplegar y configurar la infra. Se debe ejecutar desde la misma carpeta donde se encuentra el fichero.

# Iniciamos y desplegamos infra con terraform

terraform init
terraform apply

# Guardamos el enlace a nuestro ACR en una variable
ACR=$(terraform output -raw acr_login_server)

# Iniciamos sesion en dicha ACR con podman
podman login $ACR \
-u "$(terraform output -raw acr_admin_username)" \
-p "$(terraform output -raw acr_admin_password)"

# Construimos la imagen
podman build --platform=linux/amd64 -t $ACR/casopractico2:apache ./podman-web-app

# Pusheamos la imagen al ACR
podman push $ACR/casopractico2:apache