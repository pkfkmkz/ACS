FROM centos:centos6.10

ARG USER_NAME
ARG GROUP_NAME
ARG USER_ID
ARG GROUP_ID

#General packages
RUN yum -y install vim redhat-lsb-core sudo dbus-x11

#Install Git and Git LFS
RUN yum -y install epel-release
RUN yum -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-6.noarch.rpm
RUN yum -y install git
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash
RUN yum -y install git-lfs

#Install Java 8
RUN yum -y install java-1.8.0-openjdk-devel
#RUN echo 1| alternatives --config java_sdk_openjdk

#Install Java 11
#RUN yum -y install java-11-openjdk-devel
#RUN echo 2| alternatives --config java_sdk_openjdk

#Prepare for Java
RUN mkdir -p /usr/java
RUN ln -s /usr/lib/jvm/java-openjdk /usr/java/default

#Install ACS required packages
RUN yum -y install ksh gcc gcc-c++ gcc-gfortran libX11-devel libffi-devel perl readline-devel bzip2 bzip2-devel openssl-devel openldap-devel libxml2-devel freetype-devel libxslt-devel sqlite-devel expat-devel tcl-devel tk-devel bison flex autoconf unzip dos2unix doxygen graphviz

#ARCHIVE
RUN yum -y install libtool libdb-devel

#ICD
RUN yum -y install cmake blas-devel cfitsio-devel wcslib-devel lapack-devel

#CONTROL
RUN yum -y install binutils-devel libmemcached-devel

#CORRCommon
RUN yum -y install kernel kernel-devel procmail

#CORR
RUN yum -y install pgplot-devel

#TELCAL
RUN yum -y install motif-devel texlive

#RTI DDS
#RUN cd / && curl http://*****:*****@webdav.sco.alma.cl/restricted/propietary/RTI-RHEL6-x86_64.tar.bz2 | tar -xj

#Debugging Tools
RUN yum -y install gdb net-tools valgrind
RUN yum -y install tree meld

#User configuration
RUN groupadd -r -g ${GROUP_ID} ${GROUP_NAME}
RUN useradd -r -m -u ${USER_ID} -g ${GROUP_NAME} ${USER_NAME}
RUN groupadd sudo
RUN usermod -aG sudo ${USER_NAME}
RUN echo new2me |passwd ${USER_NAME} --stdin
RUN echo "%sudo	ALL=(ALL)	ALL" >> /etc/sudoers
RUN echo "%sudo	ALL=(ALL)	NOPASSWD: ALL" >> /etc/sudoers
USER ${USER_NAME}
