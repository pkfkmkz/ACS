#ACS image for building on Debian 11
FROM debian:11

ARG RTIDDS_URL

#General packages
RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y vim lsb-release sudo dbus-x11 wget openssh-server rsync passwd hostname time bc procps curl rename
RUN mv /usr/bin/rename /usr/bin/prename && /bin/echo -e '#!/bin/bash\n\nprename "s/$1/$2/" ${@:3}' > /usr/bin/rename && chmod +x /usr/bin/rename

#Install Git and Git LFS
RUN apt-get install -y git git-lfs

#Install Java 11
RUN apt-get install -y openjdk-11-jdk
#RUN echo 1| alternatives --config java_sdk_openjdk

#Prepare for Java
RUN mkdir -p /usr/java
RUN ln -s /usr/lib/jvm/java-11-openjdk-amd64 /usr/java/default

#Prepare for ALMA
RUN mkdir /alma

#Install ACS required packages
RUN apt-get install -y ksh gcc g++ gfortran libx11-dev libffi-dev perl libreadline-dev bzip2 libbz2-dev libssl-dev libldap-dev libxml2-dev libfreetype6-dev libxslt-dev libsqlite3-dev libexpat-dev tcl-dev tk-dev bison flex autoconf unzip dos2unix procmail libcppunit-dev doxygen graphviz astyle libboost-dev libboost-system-dev swig libxerces-c-dev cmake libarchive13 libsasl2-dev

#RTI DDS
RUN cd /alma && curl ${RTIDDS_URL} | tar -xj || true

#Debugging Tools
RUN apt-get install -y gdb net-tools

# Prepare it to be a jenkins node
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    adduser --disabled-password --gecos "" jenkins && echo "new2me\nnew2me" | passwd jenkins && \
    chown jenkins.jenkins -R /alma && \
    cd /home/jenkins && wget http://webdav.sco.alma.cl/public/tat_parser.py &&\
    chmod a+x tat_parser.py && mkdir /home/jenkins/workspace

#Copy SSH Key
COPY id_rsa /home/jenkins/.ssh/id_rsa
COPY id_rsa.pub /home/jenkins/.ssh/id_rsa.pub
RUN ssh-keyscan -p 7999 bitbucket.sco.alma.cl,200.2.1.51 >> /home/jenkins/.ssh/known_hosts
COPY settings.xml /home/jenkins/.m2/settings.xml
RUN chown jenkins:jenkins -R /home/jenkins /alma

USER jenkins
WORKDIR /home/jenkins/workspace
