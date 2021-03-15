#!/bin/bash
HOSTNAME=$(hostname)
HOST=${HOSTNAME%.*.*}
INIT_PATH="/home/ubuntu/Judo_Project/Judo/docker"
SINGLEBOX_PATH="/singlebox-deployment"
DISTRIBUTED_PATH="/distributed-deployment"
CORE_PATH="/core-service"
STORAGE_PATH="/storage-service"
INIT_PROXY_PATH="/home/ubuntu/Judo_Project/Judo/proxy/config"
PROXY_DEVELOPMENT="/development"
PROXY_STAGING="/staging"
PROXY_DISTRIBUTED_CORE="/distributed-core"
PROXY_DISTRIBUTED_STORAGE="/distributed-storage"
JUDO_ENV=""
JUDO_NODE=""
JUDO_PATH=""
JUDO_PROXY_PATH=""

 

function setJudoVariables() {
case "$HOST" in
"dev1")
JUDO_ENV=".dev"
JUDO_NODE=""
JUDO_PATH=${INIT_PATH}${SINGLEBOX_PATH}
JUDO_PROXY_PATH=${INIT_PROXY_PATH}${PROXY_DEVELOPMENT}
;;
"staging")
JUDO_ENV=".staging"
JUDO_NODE="-core"
JUDO_PATH=${INIT_PATH}${DISTRIBUTED_PATH}${CORE_PATH}
JUDO_PROXY_PATH=${INIT_PROXY_PATH}${PROXY_STAGING}${PROXY_DISTRIBUTED_CORE}
;;
"shard1.staging" | "shard2.staging")
JUDO_ENV=".staging"
JUDO_NODE="-storage"
JUDO_PATH=${INIT_PATH}${DISTRIBUTED_PATH}${STORAGE_PATH}
JUDO_PROXY_PATH=${INIT_PROXY_PATH}${PROXY_STAGING}${PROXY_DISTRIBUTED_STORAGE}
;;
"beta" | "beta2")
JUDO_ENV=".prod"
JUDO_NODE="-core"
JUDO_PATH=${INIT_PATH}${DISTRIBUTED_PATH}${CORE_PATH}
JUDO_PROXY_PATH=${INIT_PROXY_PATH}${PROXY_STAGING}${PROXY_DISTRIBUTED_CORE}
;;
"shard1.beta" | "shard2.beta" | "shard3.beta" | "shard4.beta" | "shard5.beta" | "shard6.beta" | "shard7.beta" | "shard1.beta2" | "shard2.beta2" | "shard3.beta2" | "shard4.beta2" )
JUDO_ENV=".prod"
JUDO_NODE="-storage"
JUDO_PATH=${INIT_PATH}${DISTRIBUTED_PATH}${STORAGE_PATH}
JUDO_PROXY_PATH=${INIT_PROXY_PATH}${PROXY_STAGING}${PROXY_DISTRIBUTED_STORAGE}
;;
esac
}
function main() {
docker stop judo-proxy
setJudoVariables
cd /etc/letsencrypt/live/${HOSTNAME}
sudo certbot renew --force-renewal --tls-sni-01-port=8080
sudo cat fullchain.pem > ${JUDO_PROXY_PATH}/server.pem
sudo cat privkey.pem >> ${JUDO_PROXY_PATH}/server.pem
cd ${JUDO_PATH}
docker-compose -f docker-compose${JUDO_NODE}.yml  -f docker-compose${JUDO_NODE}${JUDO_ENV}.yml build
docker-compose -f docker-compose${JUDO_NODE}.yml  -f docker-compose${JUDO_NODE}${JUDO_ENV}.yml up -d
}
main