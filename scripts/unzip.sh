#!/bin/bash

cp /home/ubuntu/actions-runner/tomcat/tomcat/tomcat/war/hello-world.war /war/
cd /
cp backup/*.war work/
unzip /work/*.war "META-INF/*" -d "/work/" 
unzip /war/*.war -d "/war/"
mv /work/META-INF/context.xml /war/META-INF/
cd war
jar uvf hello-world.war META-INF/






