#!/bin/bash

sudo su <<HERE
cd /
ls backup/
cp /opt/tomcat/latest/webapps/hello-world.war /backup/
ls backup/
HERE

