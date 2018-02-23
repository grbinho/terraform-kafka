#!/bin/bash
#Install Java 8
echo "Installing Java"
sudo apt-get update && sudo apt-get install -y openjdk-8-jdk

if ! type "java" > /dev/null; then
    echo "Java not installed!"
    exit 1
fi

echo "Java installed."

#download and install zookeper
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export KAFKA_BROKER_ID=$1
COUNT_OF_NODES=$2
ZOOKEEPER_CONNECT=$3

echo "Downloading kafka"
curl -O "http://apache.redkiwi.nl/kafka/$KAFKA_VERSION/kafka_2.11-$KAFKA_VERSION.tgz"
tar -zxf kafka_2.11-$KAFKA_VERSION.tgz
sudo mv kafka_2.11-$KAFKA_VERSION /usr/local/kafka
rm kafka_2.11-$KAFKA_VERSION.tgz

#TODO: Create kafka user

# Find additional volumes and mount them
mount /dev/sdh /data/kafka/

echo "Configuring kafka"

echo "broker.id=$KAFKA_BROKER_ID" >> /tmp/server.properties
echo "zookeeper.connect=""$ZOOKEEPER_CONNECT""" >> /tmp/server.properties
echo "log.dirs=""/data/kafka"""

cp /tmp/server.properties /usr/local/kafka/config/server.properties

# Will need to attach and mount EBS drives
# Set log.dirs

# Maybe best to copy config file to the machine and change the unique parameters

# Set G1 garbage collection

#Start kafka
echo "Starting kafka"
/usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties