#!/bin/bash
if [ -z "$1" ]
then
  echo "No IP supplied"
  echo "usage: apmsetup.sh <IP> "
  exit 1
fi



echo Setup ES on  $1
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat > /etc/yum.repos.d/elasticsearch.repo <<EOF
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

yum -y install elasticsearch
chkconfig --add elasticsearch

sed -i -e 's/#network.host: 192.168.0.1/network.host: ["127.0.0.1", "'$1'"]/g' /etc/elasticsearch/elasticsearch.yml
#sed -i -e 's/#cluster.name: my-application/cluster.name: '$2'/g' /etc/elasticsearch/elasticsearch.yml
#sed -i -e 's/#node.name: node-1/node.name: '$3'/g' /etc/elasticsearch/elasticsearch.yml
sed -i -e 's/discovery.type: single-node//g' /etc/elasticsearch/elasticsearch.yml
echo discovery.type: single-node >> /etc/elasticsearch/elasticsearch.yml
firewall-cmd --permanent --add-port=9200/tcp
firewall-cmd --permanent --add-port=9300/tcp
firewall-cmd --reload

/bin/systemctl daemon-reload
/bin/systemctl enable elasticsearch.service
systemctl start elasticsearch.service