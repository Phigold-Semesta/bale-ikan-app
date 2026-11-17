import http.server
import socketserver
import json
import os
from urllib.parse import urlparse

PORT = 8080
WEB_DIR = os.path.join(os.path.dirname(__file__), 'build', 'web')

STATE = {
    "orders": [
        {
            "id": "TRX-88901",
            "customerNama": "Budi Santoso (Customer)",
            "alamat": "Perum Galuh Mas Blok A2, Telukjambe, Karawang",
            "items": "2 kg Ikan Gabus Segar, 1 kg Ikan Patin Tambak",
            "totalHarga": "Rp 125.000",
            "metodeBayar": "QRIS Bale Ikan (Lunas)",
            "jenisPengiriman": "Kurir Internal Pendingin Es",
            "status": "Sedang Diantar Kurir",
            "tokoLat": -6.3050,
            "tokoLng": 107.2960,
            "custLat": -6.3260,
            "custLng": 107.2910,
            "kurirLat": -6.3155,
            "kurirLng": 107.2935,
            "waktu": "Hari ini, 10:30"
        }
    ],
    "product_images": {},
    "profile_images": {}
}

class BaleIkanHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def _set_cors_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')

    def do_OPTIONS(self):
        self.send_response(200)
        self._set_cors_headers()
        self.end_headers()

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == '/api/orders':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self._set_cors_headers()
            self.end_headers()
            self.wfile.write(json.dumps(STATE["orders"]).encode('utf-8'))
        elif parsed.path == '/api/images':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self._set_cors_headers()
            self.end_headers()
            self.wfile.write(json.dumps({
                "product_images": STATE["product_images"],
                "profile_images": STATE["profile_images"]
            }).encode('utf-8'))
        else:
            super().do_GET()

    def do_POST(self):
        parsed = urlparse(self.path)
        length = int(self.headers.get('Content-Length', 0))
        body = json.loads(self.rfile.read(length).decode('utf-8')) if length > 0 else {}

        if parsed.path == '/api/orders/add':
            STATE["orders"].insert(0, body)
        elif parsed.path == '/api/orders/update':
            for o in STATE["orders"]:
                if o["id"] == body.get("id"):
                    o.update(body)
                    break
        elif parsed.path == '/api/images/product':
            nama = body.get("nama")
            img = body.get("base64")
            if nama and img:
                STATE["product_images"][nama] = img
        elif parsed.path == '/api/images/profile':
            role = body.get("role")
            img = body.get("base64")
            if role and img:
                STATE["profile_images"][role] = img

        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self._set_cors_headers()
        self.end_headers()
        self.wfile.write(json.dumps({"ok": True}).encode('utf-8'))

if __name__ == "__main__":
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), BaleIkanHandler) as httpd:
        print(f"Server Real-Time Bale Ikan aktif di http://localhost:{PORT}")
        httpd.serve_forever()