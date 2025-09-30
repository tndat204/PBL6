# Notification Service

## Prerequisites

### Mongodb
Install Mongodb from Docker Hub
`docker pull bitnamilegacy/mongodb:latest`

Start Mongodb server at port 27017 with username and password: admin/123456
`docker run -d --name mongodb-container -e MONGO_INITDB_ROOT_USERNAME=admin -e MONGO_INITDB_ROOT_PASSWORD=123456 -p 27017:27017 bitnamilegacy/mongodb:latest`

### Kafka 
Install Kafka from Docker Hub
`docker pull bitnamilegacy/kafka:3.7.0`

Start Kafka
`docker run -d --name kafka -h kafka -p 9094:9094 -e KAFKA_CFG_NODE_ID=0 -e KAFKA_CFG_PROCESS_ROLES=controller,broker -e KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@kafka:9093 -e KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093,EXTERNAL://:9094 -e KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092,EXTERNAL://localhost:9094 -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT,PLAINTEXT:PLAINTEXT -e KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER bitnamilegacy/kafka:3.7.0`