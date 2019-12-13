#!/usr/bin/env bash

#Environments
ZBX_SERVER_URL="http://localhost:8081"
ZBX_PUBLIC_IP=$(ip route get 1 | awk '{print $NF;exit}')
GRF_SERVER_URL="http://admin:zabbix@localhost:3000"
yesPattern="^[Yy][Ee][Ss]"
HOST_GROUPS=(
"Tomcat servers" \
"NodeJS servers" \
"JVM servers" \
"MySQL servers" \
"Oracle servers" \
"RabbitMQ servers" \
"Kafka servers" \
"Docker servers" \
"Kubernetes servers" \
)
