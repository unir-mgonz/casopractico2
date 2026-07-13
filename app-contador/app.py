#!/usr/bin/env python3
"""App mínima: contador de visitas persistido en /data/contador.txt.

Demo de persistencia para el Caso Práctico 2.
- Sin volumen montado en /data -> el contador se reinicia al recrear el pod.
- Con un PVC montado en /data -> el contador sobrevive (Sesión 4).
No usa dependencias externas (solo la stdlib de Python).
"""
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

DATA_DIR = "/data"
COUNTER_FILE = os.path.join(DATA_DIR, "contador.txt")


def leer_contador() -> int:
    try:
        with open(COUNTER_FILE) as f:
            return int(f.read().strip() or "0")
    except (FileNotFoundError, ValueError):
        return 0


def guardar_contador(valor: int) -> None:
    os.makedirs(DATA_DIR, exist_ok=True)
    with open(COUNTER_FILE, "w") as f:
        f.write(str(valor))


PAGINA = """<!DOCTYPE html>
<html lang="es"><head><meta charset="utf-8">
<title>Caso Práctico 2 · Contador</title>
<style>
 body {{ font-family: system-ui, sans-serif; background:#0d1b2a; color:#e0e1dd;
        display:flex; min-height:100vh; align-items:center; justify-content:center; margin:0; }}
 .card {{ background:#1b263b; border-radius:16px; padding:48px 64px; text-align:center;
         box-shadow:0 10px 40px rgba(0,0,0,.4); }}
 h1 {{ color:#4cc9f0; margin:0 0 8px; }}
 .n {{ font-size:4em; color:#95d5b2; font-weight:bold; }}
 .pod {{ color:#778; font-size:.85em; }}
</style></head>
<body><div class="card">
 <h1>Contador de visitas</h1>
 <p class="n">{valor}</p>
 <p class="pod">pod: {pod}</p>
</div></body></html>"""


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/":
            self.send_response(404)
            self.end_headers()
            return
        valor = leer_contador() + 1
        guardar_contador(valor)
        cuerpo = PAGINA.format(valor=valor, pod=os.uname().nodename).encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(cuerpo)))
        self.end_headers()
        self.wfile.write(cuerpo)

    def log_message(self, *args):
        pass  # silenciar logs de acceso


if __name__ == "__main__":
    print("Contador escuchando en :8080")
    HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
