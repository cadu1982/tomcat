#!/bin/bash

sudo su <<HERE
cd /
cp backup/*.war work/
unzip /work/*.war "META-INF/*" -d "/work/" 
HERE


# unzip /home/ubuntu/actions-runner/tomcat/tomcat/tomcat/war/hello-world.war "META-INF/*" -d "/home/ubuntu/actions-runner/tomcat/tomcat/tomcat/war/"
# cp /work/META-INF/context.xml home/ubuntu/actions-runner/tomcat/tomcat/tomcat/war/META-INF
# cd home/ubuntu/actions-runner/tomcat/tomcat/tomcat/war/
# zip -r -u hello-world.war META-INF



