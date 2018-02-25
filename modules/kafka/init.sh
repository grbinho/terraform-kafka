#!/bin/bash
echo "Attach ebs volume"
sudo mkfs -t ext4 /dev/xvdb
sudo mkdir -p /data/kafka
sudo mount /dev/xvdb /data/kafka
sudo mkdir -p /data/kafka/logs
sudo echo '/dev/xvdb  /data/kafka ext4 defaults,nofail 0 2' | sudo tee --append /etc/fstab
sudo chown -R ubuntu /data/kafka/logs
#Install Java 8
echo "Installing Java"
sudo apt-get update && sudo apt-get install -y openjdk-8-jdk

if ! type "java" > /dev/null; then
    echo "Java not installed!"
    exit 1
fi

echo "Java installed."

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export KAFKA_JVM_PERFORMANCE_OPTS="-server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+DisableExplicitGC -Djava.awt.headless=true"
export KAFKA_BROKER_ID=$1
COUNT_OF_NODES=$2
ZOOKEEPER_CONNECT=$3

if [ ! -e "kafka_2.11-$KAFKA_VERSION.tgz" ]; then
    echo "Downloading kafka"
    curl -O "http://apache.redkiwi.nl/kafka/$KAFKA_VERSION/kafka_2.11-$KAFKA_VERSION.tgz"
fi

echo "Moving kafkat to /user/local/kafka"
tar -zxf kafka_2.11-$KAFKA_VERSION.tgz
sudo mv kafka_2.11-$KAFKA_VERSION /usr/local/kafka
rm kafka_2.11-$KAFKA_VERSION.tgz

#TODO: Create kafka user

if [ ! -e "/tmp/server.properties.new" ]; then
    echo "Writing kafka configuration"
    cp /tmp/server.properties /tmp/server.properties.new
    echo "broker.id=$KAFKA_BROKER_ID" >> /tmp/server.properties.new
    echo "zookeeper.connect=""$ZOOKEEPER_CONNECT""" >> /tmp/server.properties.new
    echo "log.dirs=""/data/kafka/logs""" >> /tmp/server.properties.new
    echo "Finished writing configuration"
fi
echo "Copying kafka configuration to /usr/local/kafka/config/server.properties"
cp /tmp/server.properties.new /usr/local/kafka/config/server.properties
rm /tmp/server.properties.new

#Start kafka
echo "Starting kafka"
eval $(/usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties)
echo "Kafka started"
sleep 5
