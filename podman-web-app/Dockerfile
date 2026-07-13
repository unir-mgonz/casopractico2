FROM httpd:2.4

# certbot para solicitar el certificado a Let's Encrypt en el arranque.
# apache2-utils (htpasswd) ya viene incluido en httpd.
RUN apt-get update && apt-get install -y --no-install-recommends certbot && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# 1. Credenciales de autenticación básica (usuario: alumno / pass: unir2026).
# -----------------------------------------------------------------------------
RUN htpasswd -cb /usr/local/apache2/.htpasswd alumno unir2026

# -----------------------------------------------------------------------------
# 2. Habilitar módulos SSL, auth y rewrite (redirección 80 -> 443)
#    + cargar nuestra configuración.
# -----------------------------------------------------------------------------
RUN sed -i \
      -e 's/^#\(LoadModule ssl_module .*\)/\1/' \
      -e 's/^#\(LoadModule socache_shmcb_module .*\)/\1/' \
      -e 's/^#\(LoadModule auth_basic_module .*\)/\1/' \
      -e 's/^#\(LoadModule authn_file_module .*\)/\1/' \
      -e 's/^#\(LoadModule authz_user_module .*\)/\1/' \
      -e 's/^#\(LoadModule rewrite_module .*\)/\1/' \
      /usr/local/apache2/conf/httpd.conf && \
    echo "Include conf/extra/httpd-cp2.conf" >> /usr/local/apache2/conf/httpd.conf

COPY httpd-cp2.conf /usr/local/apache2/conf/extra/httpd-cp2.conf
COPY index.html /usr/local/apache2/htdocs/index.html
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
