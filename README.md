# opal
Elastic Application Performance Monitoring Client For Delphi

Based on version 6.5: https://www.elastic.co/guide/en/apm/server/6.5/index.html

1) Start using Cent OS 7.3
2) Intall Elastic Search using yum/systemd: https://www.elastic.co/guide/en/elasticsearch/reference/current/rpm.html
3) Intall Kibana Search using yum/systemd: https://www.elastic.co/guide/en/kibana/current/rpm.html
4) Intall APM Server: sudo yum install apm-server
5) Add to systemctl: sudo chkconfig --add apm-server
6) Start deamon same as the others.

Developed using Delphi Seattle. Should work with community edition.
