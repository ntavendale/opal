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

echo Update yml file for single node cluster
sed -i -e 's/#network.host: 192.168.0.1/network.host: ["127.0.0.1", "'$1'"]/g' /etc/elasticsearch/elasticsearch.yml
sed -i -e 's/discovery.type: single-node//g' /etc/elasticsearch/elasticsearch.yml
echo discovery.type: single-node >> /etc/elasticsearch/elasticsearch.yml

echo Open 9200, 9300 on firewall
firewall-cmd --permanent --add-port=9200/tcp
firewall-cmd --permanent --add-port=9300/tcp
firewall-cmd --reload

echo Start elasticseach daemon
/bin/systemctl daemon-reload
/bin/systemctl enable elasticsearch.service
systemctl start elasticsearch.service

echo Install kibana
cat > /etc/yum.repos.d/kibana.repo <<EOF
[kibana-7.x]
name=Kibana repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

yum -y install kibana

echo Open port 5601
firewall-cmd --permanent --add-port=5601/tcp
firewall-cmd --reload

sed -i -e 's/#server.host: "localhost"/server.host: "'$1'"/g' /etc/kibana/kibana.yml

echo start daemon
/bin/systemctl daemon-reload
/bin/systemctl enable kibana.service
/bin/systemctl start kibana.service
