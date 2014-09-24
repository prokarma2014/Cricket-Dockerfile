FROM  ubuntu:14.04
MAINTAINER PROKARMA 

# installation of java 
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-installer
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java7-set-default
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle


#Tomcat

RUN apt-get update && \
apt-get install -yq --no-install-recommends wget pwgen ca-certificates && \
apt-get clean && \rm -rf /var/lib/apt/lists/*


ENV TOMCAT_MAJOR_VERSION 7
ENV TOMCAT_MINOR_VERSION 7.0.55
ENV CATALINA_HOME /tomcat
# INSTALL TOMCAT
RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
tar zxf apache-tomcat-*.tar.gz && \
rm apache-tomcat-*.tar.gz && \
mv apache-tomcat* tomcat



#VNC & Firefox
RUN apt-get update
RUN apt-get install -y x11vnc xvfb firefox
RUN wget ftp://ftp.mozilla.org/pub/mozilla.org/firefox/releases/29.0/linux-x86_64/en-US/firefox-29.0.tar.bz2
RUN tar -xjvf firefox-29.0.tar.bz2
RUN mv firefox /opt/firefox29
RUN ln -sf /opt/firefox29/firefox /usr/bin/firefox

# installation of maven 
RUN apt-get update
RUN apt-get install -y maven 



# Script File to set admin user

ADD create_tomcat_admin_user.sh /create_tomcat_admin_user.sh
ADD run.sh /run.sh
RUN chmod +x /*.sh
EXPOSE 8080
RUN apt-get install unzip
RUN mkdir /usr/mavenapp
RUN wget https://github.com/prokarma2014/CricketWeb-mn/archive/master.zip
RUN unzip master.zip  -d /usr/mavenapp
WORKDIR /usr/mavenapp/CricketWeb-mn-master/
RUN mvn clean
RUN mvn install

# Deploying Web Application
RUN cp /usr/mavenapp/CricketWeb-mn-master/target/CricWebApp-0.0.1-SNAPSHOT.war /tomcat/webapps

# Getting Test Scripts to run over Web Application 
RUN wget https://github.com/prokarma2014/CricketTest/archive/master.zip
RUN unzip master.zip -d /usr/mavenapp/CricketWeb-mn-master/
WORKDIR /usr/mavenapp/CricketWeb-mn-master/CricketTest-master/
RUN cp /run.sh  /usr/mavenapp/CricketWeb-mn-master/CricketTest-master/

#Installing Mysql 
RUN apt-get install -y mysql-server-5.6

ADD sqlrun.sh /sqlrun.sh
RUN chmod +x /*.sh
RUN cp /sqlrun.sh /usr/mavenapp/CricketWeb-mn-master/CricketTest-master
RUN apt-get install libmysql-java
RUN export CLASSPATH=$CLASSPATH:/usr/share/java/mysql-connector-java.jar

