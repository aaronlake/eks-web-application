import os
from bson import json_util
from flask import Flask, request, jsonify, send_from_directory
from pymongo import MongoClient
from pymongo.errors import ServerSelectionTimeoutError

app = Flask(__name__)

try:
    with open("/etc/secrets/mongo-endpoint", "r", encoding="utf8") as f:
        CONNECTION_STRING = f.read().strip()
    client = MongoClient(CONNECTION_STRING, serverSelectionTimeoutMS=5000)
    client.server_info()
except (FileNotFoundError, ServerSelectionTimeoutError):
    CONNECTION_STRING = os.environ.get("CONNECTION_STRING", "localhost:27017")

# Connect to MongoDB
client = MongoClient(CONNECTION_STRING)
db = client["shopping_list_db"]
collection = db["list_items"]


@app.route("/")
def index():
    """Serve index.html"""
    return send_from_directory("static", "index.html")


@app.route("/items", methods=["GET"])
def get_items():
    """Return all items in the shopping list"""
    items = list(collection.find({}))
    return json_util.dumps(items)


@app.route("/items", methods=["POST"])
def add_item():
    """Add a new item to the shopping list"""
    new_item = request.json["item"]
    collection.insert_one({"item": new_item})
    return jsonify({"status": "success"})


@app.route("/items/<item_name>", methods=["DELETE"])
def remove_item(item_name):
    """Remove an item from the shopping list"""
    collection.delete_one({"item": item_name})
    return jsonify({"status": "success"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
