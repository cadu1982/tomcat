#!/bin/bash

sudo su <<HERE
cd /
cp /opt/tomcat/latest/webapps/hello-world.war /backup/
ls backup/
HERE

