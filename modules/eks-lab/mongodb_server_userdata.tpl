#!/bin/bash

set -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

hostnamectl set-hostname ${hostname}

sudo apt-get update
sudo apt-get install -y curl
sudo apt-get install -y libc6 libgcc1

if [ ! -f "/usr/bin/amazon-ssm-agent" ]; then
  snap install amazon-ssm-agent --classic
fi

cd /tmp || exit

curl -O "https://repo.mongodb.org/apt/ubuntu/dists/bionic/mongodb-org/${mongodb_major}.${mongodb_minor}/multiverse/binary-amd64/mongodb-org-server_${mongodb_version}_amd64.deb"
curl -O "https://repo.mongodb.org/apt/ubuntu/dists/bionic/mongodb-org/${mongodb_major}.${mongodb_minor}/multiverse/binary-amd64/mongodb-org-shell_${mongodb_version}_amd64.deb"
curl -O "http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb"

sudo dpkg -i "mongodb-org-server_${mongodb_version}_amd64.deb" "mongodb-org-shell_${mongodb_version}_amd64.deb" libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo systemctl enable mongod
sudo systemctl start mongod

rm "mongodb-org-server_${mongodb_version}_amd64.deb" "mongodb-org-shell_${mongodb_version}_amd64.deb" libssl1.1_1.1.1f-1ubuntu2_amd64.deb

echo "
use admin
db.createUser(
  {
    user: 'admin',
    pwd: '${mongodb_password}',
    roles: [{ role: 'root', db: 'admin' }]
  }
);" > /tmp/createUser.js

echo "Waiting for mongod to start..."
sleep 5

mongo < /tmp/createUser.js

rm /tmp/createUser.js

sudo sed -i 's/#security:/security:\n  authorization: "enabled"/' /etc/mongod.conf
sudo sed -i 's/  bindIp:.*$/  bindIp: 0.0.0.0/' /etc/mongod.conf
sudo systemctl restart mongod

echo "Mongo Connection string: mongodb://admin:${mongodb_password}@localhost:27017/admin"
