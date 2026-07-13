# =============================================================================
# Dockerfile - app-contador (demo Sesión 3/4): contador de visitas persistente
# =============================================================================
# Web que incrementa un contador en cada visita y lo guarda en /data/contador.txt.
#  - SIN volumen (Sesión 3): al recrear el pod, el contador VUELVE A 0 -> datos
#    efímeros. Motiva la persistencia.
#  - CON PVC (Sesión 4): el contador SOBREVIVE a recrear el pod.
# App mínima en Python (sin dependencias externas), escucha en el puerto 8080.
FROM python:3.12-alpine
WORKDIR /app
COPY app.py /app/app.py
EXPOSE 8080
CMD ["python", "app.py"]
