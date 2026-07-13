#!/bin/bash
# Pide el certificado a Let's Encrypt y arranca Apache.
# certbot se ejecuta en modo --standalone y por eso se ejecuta antes de apache.

set -euo pipefail

# Sin FQDN y sin correo, certbot no puede pedir el certificado. Salimos con errores.
if [ -z "${SERVER_NAME:-}" ] || [ -z "${CERTBOT_EMAIL:-}" ]; then
  echo "ERROR: faltan variables obligatorias." >&2
  echo "  SERVER_NAME   = FQDN del dominio (ej. midominio.spaincentral.cloudapp.azure.com)" >&2
  echo "  CERTBOT_EMAIL = correo de registro para el certificado" >&2
  exit 1
fi

# Añade el flag --staging a certbot si la variable "certbot_staging" esta marcada como true en terraform/variables.tf
staging_flag=""
if [ "${CERTBOT_STAGING:-false}" = "true" ]; then
  staging_flag="--staging"
fi

# Apache lee ${SERVER_NAME} de su configuración, así que hay que exportarla.
export SERVER_NAME

# Si el certificado ya existe, certbot solo lo renueva cuando le quedan menos de 30 días. Si no existe, lo pide por primera vez.
# Puesto que no se crea ninguna tarea periodica en el contenedor, el certificado no se renueva solo. Habra que reiniciar el contenedor periodicamente para que se vuelva a ejecutar el entrypoint o llamar a certbot con podman exec 
if [ -f "/etc/letsencrypt/live/${SERVER_NAME}/fullchain.pem" ]; then
  echo "[entrypoint] Certificado existente para ${SERVER_NAME}. Comprobando renovación..."
  certbot renew --standalone --non-interactive --quiet
else
  echo "[entrypoint] Solicitando certificado a Let's Encrypt para ${SERVER_NAME}..."
  certbot certonly --standalone --non-interactive --agree-tos --email "${CERTBOT_EMAIL}" ${staging_flag} -d "${SERVER_NAME}"
fi

echo "[entrypoint] Arrancando Apache..."
exec httpd-foreground
