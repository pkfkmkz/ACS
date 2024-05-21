#ACS image for building on CentOS 7
FROM centos:centos7.9.2009

ARG RTIDDS_URL

#Configure needed repositories
RUN yum -y install epel-release
RUN yum -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash

#General packages
RUN yum -y install vim redhat-lsb-core sudo dbus-x11 openssh-server wget

#Install Git and Git LFS
RUN yum -y install git git-lfs

#Install Java 11
RUN yum -y install java-11-openjdk-devel
#RUN echo 1| alternatives --config java_sdk_openjdk

#Prepare for Java
RUN mkdir -p /usr/java
RUN ln -s /usr/lib/jvm/java-openjdk /usr/java/default

#Prepare for ALMA
RUN mkdir /alma

#Install ACS required packages
RUN yum -y install ksh gcc gcc-c++ gcc-gfortran libX11-devel libffi-devel perl readline-devel bzip2 bzip2-devel openssl-devel openldap-devel libxml2-devel freetype-devel libxslt-devel sqlite-devel expat-devel tcl-devel tk-devel bison flex autoconf unzip dos2unix procmail cppunit-devel doxygen graphviz cmake libarchive

#RTI DDS
RUN cd /alma && curl ${RTIDDS_URL} | tar -xj || true

#Debugging Tools
RUN yum -y install gdb net-tools

# Prepare it to be a jenkins node
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    adduser jenkins && echo new2me | passwd jenkins --stdin && \
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
