#!/bin/bash

sudo su <<HERE
cd /
rm -r work war
mkdir work && chmod 777 work
mkdir war && chmod 777 war
HERE