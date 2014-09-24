#!/bin/bash
# 
# MySQL Root Password Reset Script
# 

/etc/init.d/mysql start

mysqladmin -u root flush-privileges password admin
mysql -u root -padmin -e "source circ_dbscript.sql;"
sh run.sh &
mvn test
cp /usr/mavenapp/CricketWeb-mn-master/CricketTest-master/target/site/surefire-report.html  /usr/mavenapp/CricketWeb-mn-master/CricketTest-master/

firefox surefire-report.html



