# Basic Demo for Red Hat Debezium - Change Data Capture

This basic demo demonstrate how to use Red Hat Build of Debezium to connect to MySQL DB and Stream the changes to this DB.

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

