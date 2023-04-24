#!/bin/bash

sudo su <<HERE
cp /home/ubuntu/actions-runner/tomcat/tomcat/tomcat/war/hello-world.war war/
cd /
cp backup/*.war work/
unzip /work/*.war "META-INF/*" -d "/work/" 
unzip /war/*.war "META-INF/*" -d "/war/"
cp /work/META-INF/context.xml /war/META-INF
cd war
zip -r -u hello-world.war META-INF
HERE





