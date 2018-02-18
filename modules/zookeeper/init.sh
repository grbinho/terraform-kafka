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
export ZOOKEEPER_ID=$1
IP_PREFIX=$2
COUNT_OF_NODES=$3

echo "Downloading zookeeper"
curl -O "http://apache.40b.nl/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz"
tar -zxf zookeeper-$ZOOKEEPER_VERSION.tar.gz
sudo mv zookeeper-$ZOOKEEPER_VERSION /usr/local/zookeeper
rm zookeeper-$ZOOKEEPER_VERSION.tar.gz

sudo mkdir -p /var/lib/zookeeper
sudo chown -R ubuntu /var/lib/zookeeper/ #TODO: Create zookeeper user

echo "Zookeper node id: $ZOOKEEPER_ID"
echo $ZOOKEEPER_ID > /var/lib/zookeeper/myid

echo "Configuring zookeeper"

touch /usr/local/zookeeper/conf/zoo.cfg
echo "tickTime=2000" >> /usr/local/zookeeper/conf/zoo.cfg
echo "dataDir=/var/lib/zookeeper" >> /usr/local/zookeeper/conf/zoo.cfg
echo "clientPort=2181" >> /usr/local/zookeeper/conf/zoo.cfg
echo "initLimit=20" >> /usr/local/zookeeper/conf/zoo.cfg
echo "syncLimit=5" >> /usr/local/zookeeper/conf/zoo.cfg
for (( i=1; i<=$COUNT_OF_NODES; i++ ))
do
    echo "server.$i=$IP_PREFIX$i:2888:3888" >> /usr/local/zookeeper/conf/zoo.cfg
done 

#echo "Setting up static IP for this node"
#sudo sh -c "ip addr change 192.168.0.8$ZOOKEEPER_ID/24 dev eth0"

#Start zookeeper
echo "Starting zookeeper"
/usr/local/zookeeper/bin/zkServer.sh start