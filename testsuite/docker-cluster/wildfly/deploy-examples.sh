#!/bin/bash

## Deploy and configure all examples

# Deploy examples
cd /keycloak-docker-cluster/examples
for I in $(find . | grep .war$); do cp $I /opt/wildfly/standalone/deployments/; done;

# Explode wars
cd /opt/wildfly/standalone/deployments/
for I in $(ls -d *.war | grep -v auth-server.war); do
  echo "Configuring $I";
  mkdir $I.tmp;
  cd $I.tmp;
  unzip -q ../$I;
  cd ..
  rm $I;
  mv $I.tmp $I;
  touch $I.dodeploy;
done;


# Configure admin-access.war
sed -i -e 's/false/true/' admin-access.war/WEB-INF/web.xml

# Configure other examples
for I in *.war/WEB-INF/keycloak.json; do
  sed -i -e 's/\"\/auth\",/&\n    \"auth-server-url-for-backend-requests\": \"http:\/\/\$\{jboss.host.name\}:8080\/auth\",/' $I;
done;

# Enable distributable for customer-portal
sed -i -e 's/<\/module-name>/&\n    <distributable \/>/' customer-portal.war/WEB-INF/web.xml

# Configure testrealm.json - Enable adminUrl to access adapters on local machine
sed -i -e 's/\"adminUrl\": \"/&http:\/\/\$\{jboss.host.name\}:8080/' /keycloak-docker-cluster/examples/testrealm.json


