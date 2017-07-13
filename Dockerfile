FROM ubuntu:16.04
MAINTAINER anders.lu@gmail.com

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
# tomcat 8.5.16
##########################################
ENV TOMCATE_VERSION 8.5.16
# update, and get dependency (wget)
RUN apt-get update && apt-get install -y curl wget zip

# install git and coding core utils
RUN mkdir /workspace

# download and unzip the tomcat package, and rename it as tomcat
RUN cd /workspace &&  \
	wget http://www.eu.apache.org/dist/tomcat/tomcat-8/v$TOMCATE_VERSION/bin/apache-tomcat-$TOMCATE_VERSION.tar.gz && \
	tar xvzf apache-tomcat-$TOMCATE_VERSION.tar.gz && \
	mv apache-tomcat-$TOMCATE_VERSION ./tomcat

# Setup workdir
WORKDIR /workspace/tomcat

# Expose port 8080
EXPOSE 8080 
EXPOSE 80 

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
# Maven 3.2.5
##########################################
# Install Maven
ENV MAVEN_VERSION 3.2.5
ENV M2_HOME /opt/maven
RUN wget http://mirrors.hostingromania.ro/apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz -O - | tar -xz && mv apache-maven-$MAVEN_VERSION $M2_HOME
RUN ln -s $M2_HOME/bin/mvn /usr/bin/mvn

# Define default command.
#CMD ["bash"]

# Test if all is good
#RUN mvn test 


















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
#ENTRYPOINT ["/mongodb-entrypoint.sh"]


#VOLUME ["/backups"]
# VOLUME ["/data/db"]