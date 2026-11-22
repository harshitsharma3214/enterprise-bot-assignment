import os
import socket
from pathlib import Path
from flask import Flask, jsonify

app = Flask(__name__)

def get_config(key, default):
    config_file = Path("/etc/app-config") / key
    if config_file.exists():
        return config_file.read_text().strip()
    return os.getenv(key, default)

@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "app": get_config("APP_NAME", "demo-app"),
        "version": get_config("VERSION", "1.0.0"),
        "pod": socket.gethostname()
    })

@app.route("/healthz", methods=["GET"])
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
import os
import socket
from flask import Flask, jsonify

app = Flask(__name__)

APP_NAME = os.getenv("APP_NAME", "demo-app")
VERSION = os.getenv("VERSION", "1.0.0")


@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "app": APP_NAME,
        "version": VERSION,
        "pod": socket.gethostname()
    })


@app.route("/healthz", methods=["GET"])
def health():
    return jsonify({"status": "healthy"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
