FROM ubuntu:16.04
MAINTAINER riku

ENV DEBIAN_FRONTEND noninteractive
ENV JAVA_HOME       /usr/lib/jvm/java-8-oracle

## UTF-8
ENV locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

RUN apt-get update && \
  apt-get dist-upgrade -y

##########################################
# JDK8
##########################################
## Remove any existing JDKs
RUN apt-get --purge remove openjdk*

## Install Oracle's JDK
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" > /etc/apt/sources.list.d/webupd8team-java-trusty.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
RUN apt-get update && \
  apt-get install -y --no-install-recommends oracle-java8-installer && \
  apt-get clean all

##########################################
# mongodb3.0 #
##########################################
# Install MongoDB 3.0
#RUN DEBIAN_FRONTEND=noninteractive && \
#    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 && \
#    echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.0.list && \
#    apt-get update && \
#    apt-get install -y --force-yes mongodb-org=3.0.7 mongodb-org-server=3.0.7 mongodb-org-shell=3.0.7 mongodb-org-mongos=3.0.7 mongodb-org-tools=3.0.7 #&& \
#    service mongod stop && \
#    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#
## Add scripts
#ADD scripts /scripts
#RUN chmod +x /scripts/*.sh
#RUN touch /.firstrun
#
## Command to run
#ENTRYPOINT ["/scripts/run.sh"]
#CMD [""]
#
## Expose listen port
#EXPOSE 27017
##EXPOSE 28017
#
## Expose our data volumes
#VOLUME ["/data"]

##########################################
# mongodb3.0 #
##########################################
# install mongodb and start it
#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
#RUN echo 'deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse' | tee /etc/apt/sources.list.d/mongodb-org-3.0.list
#RUN apt-get update  \ 
#	&& apt-get install -y mongodb-org=3.0.0 \ 
#			 mongodb-org-server=3.0.0 \ 
#			 mongodb-org-shell=3.0.0 \ 
#			 mongodb-org-mongos=3.0.0 \
#			 mongodb-org-tools=3.0.0

#RUN mkdir -p /data/db

#EXPOSE 27017


##########################################
# tomcat 8.0 
##########################################
# update, and get dependency (wget)
RUN apt-get update && apt-get install -y curl wget zip

# install git and coding core utils
RUN mkdir /workspace

# download and unzip the tomcat package, and rename it as tomcat
RUN cd /workspace &&  \
	wget http://www.eu.apache.org/dist/tomcat/tomcat-8/v8.0.44/bin/apache-tomcat-8.0.44.tar.gz && \
	tar xvzf apache-tomcat-8.0.44.tar.gz && \
	mv apache-tomcat-8.0.44 ./tomcat

# Setup workdir
WORKDIR /workspace/tomcat

# Expose port 8080
EXPOSE 8080 

##########################################
# Does the setup of manager account
##########################################
ENV MANAGER_USER the-manager
ENV MANAGER_PASS needs-a-new-password-here

# Runs with manager user / pass, and start command
CMD echo "<?xml version='1.0' encoding='utf-8'?>" > ./conf/tomcat-users.xml && \
	echo "<tomcat-users xmlns=\"http://tomcat.apache.org/xml\"" >> ./conf/tomcat-users.xml && \
	echo "              xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"" >> ./conf/tomcat-users.xml && \
	echo "              xsi:schemaLocation=\"http://tomcat.apache.org/xml tomcat-users.xsd\"" >> ./conf/tomcat-users.xml && \
	echo "              version=\"1.0\">" >> ./conf/tomcat-users.xml && \
	echo "	<role rolename=\"admin\"/>" >> ./conf/tomcat-users.xml && \
	echo "	<role rolename=\"manager\"/>" >> ./conf/tomcat-users.xml && \
	echo "	<user username=\"$MANAGER_USER\" password=\"$MANAGER_PASS\" roles=\"standard,manager,admin,manager-gui,manager-script\"/>" >> ./conf/tomcat-users.xml && \
	echo "</tomcat-users>" >> ./conf/tomcat-users.xml && \
	./bin/startup.sh run 2> /dev/null && \
	tail -f /dev/null; 


##########################################
# SpringMvc
##########################################
# Download Liferay 6.2
#WORKDIR /data
#RUN wget -O liferay.zip https://sourceforge.net/projects/lportal/files/Liferay%20Portal/6.2.1%20GA2/liferay-portal-maven-6.2-ce-ga2-20140326112342532.zip
#RUN unzip liferay.zip

#RUN curl -O -s -k -L -C - https://sourceforge.net/projects/lportal/files/Liferay%20Portal/6.2.5%20GA6/liferay-portal-maven-6.2-ce-ga6-20160112152609836.zip
#RUN unzip liferay-portal-maven-6.2-ce-ga6-20160112152609836.zip

# Install maven dependencies
#WORKDIR /data/liferay-portal-maven-6.2-ce-ga2
#RUN ant install

# Install Maven
ENV MAVEN_VERSION 3.2.5
ENV M2_HOME /opt/maven
RUN wget http://mirrors.hostingromania.ro/apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz -O - | tar -xz && mv apache-maven-$MAVEN_VERSION $M2_HOME
RUN ln -s $M2_HOME/bin/mvn /usr/bin/mvn

# Define default command.
#CMD ["bash"]

# Build a sample portlet
#WORKDIR /data
#RUN mvn archetype:generate -DgroupId=fr.ippon.liferay.test -DartifactId=portlet-with-tests -DarchetypeGroupId=com.liferay.maven.archetypes -DarchetypeArtifactId=liferay-portlet-archetype -DarchetypeVersion=6.2.1 -DinteractiveMode=false

# Configure maven
#ADD data/pom.xml /data/portlet-with-tests/pom.xml
#ADD data/src /data/portlet-with-tests/src
#ADD data/dependencies /data/dependencies

#WORKDIR /data/portlet-with-tests
#RUN mvn install:install-file -Dfile=/data/dependencies/xdoclet-1.2.1.jar -DgroupId=xdoclet -DartifactId=xdoclet -Dversion=1.2.1 -Dpackaging=jar
#RUN mvn install:install-file -Dfile=/data/dependencies/xdoclet-web-module-1.2.1.jar -DgroupId=xdoclet -DartifactId=xdoclet-web-module -Dversion=1.2.1 -Dpackaging=jar
#RUN mvn install:install-file -Dfile=/data/dependencies/xpp3_min-1.1.3.4.I.jar -DgroupId=xpp3 -DartifactId=xpp3_min -Dversion=1.1.3.4.I -Dpackaging=jar
#RUN mvn install:install-file -Dfile=/data/dependencies/jabsorb-1.3.1.jar -DgroupId=org.jabsorb -DartifactId=jabsorb -Dversion=1.3.1 -Dpackaging=jar
#RUN mvn install:install-file -Dfile=/data/dependencies/groovy-all-1.7.5.jar -DgroupId=groovy -DartifactId=groovy-all -Dversion=1.7.5 -Dpackaging=jar
#RUN mvn install:install-file -Dfile=/data/dependencies/daisydiff-1.2.jar -DgroupId=org.outerj -DartifactId=daisyfdiff -Dversion=1.2 -Dpackaging=jar
#RUN mvn install:install-file -Dfile=/data/dependencies/jai_codec-1.1.3.jar -DgroupId=com.sun.media -DartifactId=jai_codec -Dversion=1.1.3 -Dpackaging=jar
#RUN mvn install:install-file -Dfile=/data/dependencies/jai_core-1.1.3.jar -DgroupId=javax.media -DartifactId=jai_core -Dversion=1.1.3 -Dpackaging=jar
#RUN mvn install:install-file -Dfile=/data/dependencies/springmvc-portlet-test-1.0.jar -DgroupId=fr.ippon.springmvc.test -DartifactId=springmvc-portlet-test -Dversion=1.0 -Dpackaging=jar

# Test if all is good
#RUN mvn test 


#ENTRYPOINT usr/bin/mongod

# these can be overridden in .docker-common.env but they are not set there by default
ENV MONGODB_USERNAME=minmaster
ENV MONGODB_DATABASE=spidadb
# MONGODB_PASSWORD is set in .docker-common.env

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
  	echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list && \
  	apt-get update && \
  	apt-get install -y mongodb-org=3.2.6 mongodb-org-server=3.2.6 mongodb-org-shell=3.2.6 mongodb-org-mongos=3.2.6 mongodb-org-tools=3.2.6 && \
  	apt-get install cron vim -y && \
  	rm -rf /var/lib/apt/lists/*

COPY backup.sh /backup.sh
COPY restore.sh /restore.sh
#COPY crontab /etc/cron.d/mongodb-backup-cron
COPY mongodb-entrypoint.sh /mongodb-entrypoint.sh

WORKDIR /data

VOLUME ["/backups"]
VOLUME ["/data/db"]

# process:27017, http:28017
EXPOSE 27017
EXPOSE 28017

ENTRYPOINT ["/mongodb-entrypoint.sh"]
CMD ["mongod", "--auth"]
CMD ["/bin/bash"]
