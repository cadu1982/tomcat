#!/bin/bash

sudo su <<HERE
pwd
cp war/*.war /opt/tomcat/latest/webapps/
HERE


