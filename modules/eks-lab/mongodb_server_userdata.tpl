#!/bin/bash

# shellcheck disable=SC2016

set -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

hostnamectl set-hostname ${hostname}

sudo apt-get update
sudo apt-get install -y curl awscli
sudo apt-get install -y libc6 libgcc1

if [ ! -f "/usr/bin/amazon-ssm-agent" ]; then
  snap install amazon-ssm-agent --classic
fi

cd /tmp || exit

curl -O "https://repo.mongodb.org/apt/ubuntu/dists/bionic/mongodb-org/${mongodb_major}.${mongodb_minor}/multiverse/binary-amd64/mongodb-org-server_${mongodb_version}_amd64.deb"
curl -O "https://repo.mongodb.org/apt/ubuntu/dists/bionic/mongodb-org/${mongodb_major}.${mongodb_minor}/multiverse/binary-amd64/mongodb-org-shell_${mongodb_version}_amd64.deb"
curl -O "http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb"
curl -O "https://fastdl.mongodb.org/tools/db/mongodb-database-tools-ubuntu2004-x86_64-100.5.1.deb"

sudo dpkg -i "mongodb-org-server_${mongodb_version}_amd64.deb" \
          "mongodb-org-shell_${mongodb_version}_amd64.deb" \
          libssl1.1_1.1.1f-1ubuntu2_amd64.deb \
          mongodb-database-tools-ubuntu2004-x86_64-100.5.1.deb
sudo systemctl enable mongod
sudo systemctl start mongod

rm "mongodb-org-server_${mongodb_version}_amd64.deb" \
  "mongodb-org-shell_${mongodb_version}_amd64.deb" \
  libssl1.1_1.1.1f-1ubuntu2_amd64.deb \
  mongodb-database-tools-ubuntu2004-x86_64-100.5.1.deb

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

echo '
set -e
dump_date=$(date +%Y%m%d%H%M%S)
mongodump -u admin -p ${mongodb_password} -o "/tmp/dump-$dump_date"
tar -czvf "/tmp/dump-$dump_date.tar.gz" "/tmp/dump-$dump_date"
aws s3 cp "/tmp/dump-$dump_date.tar.gz" "s3://${s3_bucket}/dump-$dump_date.tar.gz"
rm -rf "/tmp/dump-$dump_date*"
' > /tmp/backup.sh

sudo crontab -l -u ubuntu | sudo tee /tmp/crontab >/dev/null
echo "*/10 * * * * /bin/bash /tmp/backup.sh" | sudo tee -a /tmp/crontab > /dev/null
sudo crontab -u ubuntu /tmp/crontab
sudo rm /tmp/crontab
