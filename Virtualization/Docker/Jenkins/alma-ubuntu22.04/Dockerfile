FROM acs/ubuntu22.04

#Cleaning user config
USER 0
WORKDIR /

#ARCHIVE
RUN apt-get install -y libtool libdb-dev

#ICD
RUN apt-get install -y cmake libblas-dev libcfitsio-dev wcslib-dev liblapack-dev

#CONTROL
RUN apt-get install -y binutils-dev libmemcached-dev

#CORRCommon
RUN apt-get install -y linux-headers-5.14

#TELCAL
RUN apt-get install -y libmotif-dev texlive

#Setting user and working directory
USER jenkins
WORKDIR /home/jenkins/workspace
