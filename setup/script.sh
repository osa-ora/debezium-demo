#!/bin/sh
if [ "$#" -ne 1 ];  then
  echo "Usage: $0  project_name" >&1
  exit 1
fi

echo "Please Login to OCP using oc login ..... "  
echo "Make sure Openshift AMQ Streams Operator is installed"
echo "Make sure oc command is available"
read

# Create project
oc new-project $1
# Provision MySQL DB
oc new-app mysql-persistent -p DATABASE_SERVICE_NAME=mysql -p MYSQL_USER=test -p MYSQL_PASSWORD=test123 -p MYSQL_DATABASE=accountdb -p MYSQL_ROOT_PASSWORD=root123

COMMAND="create table accountdb.account ( id INT AUTO_INCREMENT NOT NULL PRIMARY KEY, firstname VARCHAR( 255 ) NOT NULL, lastname VARCHAR( 255 ) NOT NULL,status INT NOT NULL);insert into accountdb.account (id, firstname, lastname, status) values (1,'Osama','Oransa',1);insert into accountdb.account (id, firstname, lastname, status) values (2,'Osa','Ora',1);"

echo "Press [Enter] key to setup the DB once MySQL pod started successfully ..." 
read

# Get POD name
POD_NAME=$(oc get pods -l=name=mysql -o custom-columns=POD:.metadata.name --no-headers)
echo "MySQL Pod name $POD_NAME"

# Install the DB schema and add some data
# Display Schema and data installing sql statements
echo "Will install: $COMMAND"
oc exec $POD_NAME -- mysql -u root accountdb -e "create table accountdb.account ( id INT AUTO_INCREMENT NOT NULL PRIMARY KEY, firstname VARCHAR( 255 ) NOT NULL, lastname VARCHAR( 255 ) NOT NULL,status INT NOT NULL);insert into accountdb.account (id, firstname, lastname, status) values (1,'Osama','Oransa',1);insert into accountdb.account (id, firstname, lastname, status) values (2,'Osa','Ora',1);"  
# Check DB content
oc exec $POD_NAME -- mysql -u root accountdb -e "select * from accountdb.account" 

echo "Press [Enter] key to setup the Kafka cluster ..." 
read
# Provision Kafka using object details
oc apply -f https://raw.githubusercontent.com/osa-ora/debezium-demo/refs/heads/main/configs/kafka-cluster.yaml

# Download kafka properties
# curl https://raw.githubusercontent.com/osa-ora/camel-Integration-demo/refs/heads/main/scripts/kafka.properties >kafka-config.properties
 
# Create secret
# oc create secret generic my-kafka-props --from-file=kafka-config.properties

echo "Press [Enter] key to setup the MySQL Debezium Connect ..." 
read

# Provision the debezium connector image for MySQL 
oc create imagestream debezium-streams-connect -n dev
# Create the connector ..
oc apply -f https://raw.githubusercontent.com/osa-ora/debezium-demo/refs/heads/main/configs/kafka-mysql-connect.yaml -n dev


echo "Press [Enter] key to setup the MySQL Debezium Connector once the Connector status is ready ..." 
read

# Provision AMQ address object details
oc apply -f https://raw.githubusercontent.com/osa-ora/debezium-demo/refs/heads/main/configs/mysql-connector.yaml -n dev


echo "Press [Enter] key to do some testing once the mysql connector deployed successfully and ready ..." 
read

# Group all resourcs
echo "Check the topics are created ... "
oc describe KafkaConnector my-mysql-source-connector
echo "Press [Enter] key to continue"
read

echo "Check the topic content for our AccountDB ... "
oc exec -n dev  -it my-cluster-kafka-0  -- /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092  --from-beginning --property print.key=true --topic=accountdb-connector-mysql.accountdb.account
echo "Insert a new rows"
oc exec $POD_NAME -- mysql -u root accountdb -e "insert into accountdb.account (id, firstname, lastname, status) values (3,'Osa3','Ora3',1);"
oc exec $POD_NAME -- mysql -u root accountdb -e "insert into accountdb.account (id, firstname, lastname, status) values (4,'Osa4','Ora4',1);"

echo "Update an old row"
oc exec $POD_NAME -- mysql -u root accountdb -e "UPDATE accountdb.account SET lastname = 'Oransa2' WHERE id = 2;"

# Check DB content
oc exec $POD_NAME -- mysql -u root accountdb -e "select * from accountdb.account" 

echo "Press [Enter] key to continue"
read

echo "Check the topic content for our AccountDB ... "
oc exec -n dev  -it my-cluster-kafka-0  -- /opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092  --from-beginning --property print.key=true --topic=accountdb-connector-mysql.accountdb.account

echo "Congratulations, we are done!"
