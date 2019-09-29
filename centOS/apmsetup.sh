#!bin/bash
if [ -z "$1" ]
then
  echo "No IP supplied"
  exit 1
fi

echo Setup ES on  $1
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat > $file_location <<EOF
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

yum install elasticsearch
chkconfig --add elasticsearch