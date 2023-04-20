#!/bin/bash

sudo su <<HERE
unzip /home/carlos/work/primeup/arbi/repos/tomcat-sample-app/tomcat/backup/hello-world.war "META-INF/*" -d "/home/carlos/work/primeup/arbi/repos/tomcat-sample-app/tomcat/backup"
unzip /home/carlos/work/primeup/arbi/repos/tomcat-sample-app/tomcat/war/hello-world.war "META-INF/*" -d "/home/carlos/work/primeup/arbi/repos/tomcat-sample-app/tomcat/war/"
cp /home/carlos/work/primeup/arbi/repos/tomcat-sample-app/tomcat/backup/META-INF/context.xml /home/carlos/work/primeup/arbi/repos/tomcat-sample-app/tomcat/war/META-INF
cd /home/carlos/work/primeup/arbi/repos/tomcat-sample-app/tomcat/war/
zip -r -u hello-world.war META-INF
HERE



