
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
