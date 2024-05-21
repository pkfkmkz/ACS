FROM acs/centos7

#Cleaning user config
USER 0
WORKDIR /

#ARCHIVE
RUN yum -y install libtool libdb-devel

#ICD
RUN yum -y install blas-devel cfitsio-devel wcslib-devel lapack-devel

#CONTROL
RUN yum -y install binutils-devel libmemcached-devel

#CORRCommon
RUN yum -y install kernel kernel-devel

#TELCAL
RUN yum -y install motif-devel texlive

#Setting user and working directory
USER jenkins
WORKDIR /home/jenkins/workspace
