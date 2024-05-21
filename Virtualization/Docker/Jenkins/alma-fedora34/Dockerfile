FROM acs/fedora34

#Cleaning user config
USER 0
WORKDIR /

#ARCHIVE
RUN dnf -y install libtool libdb-devel

#ICD
RUN dnf -y install blas-devel cfitsio-devel wcslib-devel lapack-devel

#CONTROL
RUN dnf -y install binutils-devel libmemcached-devel

#CORRCommon
RUN dnf -y install kernel kernel-devel

#TELCAL
RUN dnf -y install motif-devel texlive

#Setting user and working directory
USER jenkins
WORKDIR /home/jenkins/workspace
