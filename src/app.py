import os
from flask import Flask, jsonify
from google.cloud import storage

app = Flask(__name__)

@app.route("/healthz", methods=["GET"])
def healthz():
    return jsonify({"status": "healthy"}), 200

@app.route("/", methods=["GET"])
def index():
    return jsonify({
        "message": "Production microservice running on Google Kubernetes Engine",
        "workload_identity": "Active"
    }), 200

@app.route("/buckets", methods=["GET"])
def list_buckets():
    try:
        client = storage.Client()
        buckets = [bucket.name for bucket in client.list_buckets()]
        return jsonify({"accessible_buckets": buckets}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
