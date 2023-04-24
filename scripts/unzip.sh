#!/bin/bash

sudo su <<HERE
cd /
mkdir work
mkdir war
cp backup/*.war work/
unzip work/*.war "META-INF/*" -d "war"
unzip hello-world.war "META-INF/*" -d "/home/carlos/work/primeup/arbi/repos/tomcat-sample-app/tomcat/war/"
cp /home/carlos/work/primeup/arbi/repos/tomcat-sample-app/tomcat/backup/META-INF/context.xml /home/carlos/work/primeup/arbi/repos/tomcat-sample-app/tomcat/war/META-INF
cd war/
zip -r -u hello-world.war META-INF
HERE



