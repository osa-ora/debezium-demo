# Basic Demo for Red Hat Build of Debezium "Change Data Capture"

![image](https://github.com/user-attachments/assets/81ec5827-eb25-452b-889d-df33ed4923f7)

Change data capture, or CDC, is a well-established software design pattern for a system that monitors and captures the changes in data so that other software can respond to those changes. CDC captures row-level changes to database tables and passes corresponding change events to a data streaming bus. Applications can read these change event streams and access these change events in the order in which they occurred.
It supports the following Databases: Db2, MongoDB, MySQL, Oracle, PostgreSQL and MS SQL Server.

This basic demo demonstrate how to use Red Hat Build of Debezium to connect to MySQL DB and Stream the changes from this DB into Kafka topic.

Note: You'll need the following to execute the scenarios:
- Access to an OpenShift cluster.
- OpenShift command line installed (i.e. oc)
- Red Hat AMQ Streams (Kafka) Operator installed.

To install the demo:
 ```
  curl https://raw.githubusercontent.com/osa-ora/debezium-demo/refs/heads/main/setup/script.sh > setup.sh
  chmod +x setup-script.sh
  ./setup-script.sh dev
 ```
Follow through the script till you finish the final testing section ...

You can see the topics created:
```
Topics:
    accountdb-connector-mysql
    accountdb-connector-mysql.accountdb.account
```
    
And you can see CDC records like:

```
//initial data before the connector
"payload":{"before":null,"after":{"id":1,"firstname":"Osama","lastname":"Oransa","status":1}
"payload":{"before":null,"after":{"id":2,"firstname":"Osa","lastname":"Ora","status":1}
//inserted rows 
"payload":{"before":null,"after":{"id":3,"firstname":"Osa3","lastname":"Ora3","status":1}
"payload":{"before":null,"after":{"id":4,"firstname":"Osa4","lastname":"Ora4","status":1}
//updated row
"payload":{"before":{"id":2,"firstname":"Osa","lastname":"Ora","status":1},"after":{"id":2,"firstname":"Osa","lastname":"Oransa2","status":1}
```


