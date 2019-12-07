#!/usr/bin/env bash

#Environments
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ZBX_SERVER_URL="https://localhost:8443"
ZBX_PUBLIC_IP=$(ip route get 1 | awk '{print $NF;exit}')
GRF_SERVER_URL="https://admin:zabbix@localhost:3000"
yesPattern="^[Yy][Ee][Ss]"
HOST_GROUPS=(
"BSD servers" \
"Windows servers" \
"Firewalls" \
"Routers" \
"Switches" \
"Netscalers"
"Nginx servers" \
"Apache servers" \
"Litespeed servers" \
"Haproxy servers" \
"Tomcat servers" \
"NodeJS servers" \
"JVM servers" \
"IIS servers" \
"MySQL servers" \
"PostgreSQL servers" \
"MongoDB servers" \
"Oracle servers" \
"MSSQL servers" \
"RabbitMQ servers" \
"Couchbase servers" \
"Redis servers" \
"Kafka servers" \
"Docker servers" \
"Kubernetes servers" \
"Openshift servers" \
"Mesos servers"
)
