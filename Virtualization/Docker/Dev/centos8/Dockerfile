FROM centos:centos8.2.2004

ARG USER_NAME
ARG GROUP_NAME
ARG USER_ID
ARG GROUP_ID

#General packages
RUN dnf -y install vim redhat-lsb-core sudo dbus-x11 rsync dnf-plugins-core glibc-locale-source glibc-langpack-en
RUN dnf config-manager --set-enabled PowerTools

#Install Git and Git LFS
RUN dnf -y install epel-release
RUN dnf -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm
RUN dnf -y install git
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | bash
RUN dnf -y install git-lfs

#Install Java 11
RUN dnf -y install java-11-openjdk-devel
#RUN echo 1| alternatives --config java_sdk_openjdk

#Prepare for Java
RUN mkdir -p /usr/java
RUN ln -s /usr/lib/jvm/java-openjdk /usr/java/default

#Install ACS required packages
RUN dnf -y install ksh gcc gcc-c++ gcc-gfortran libX11-devel libffi-devel perl readline-devel bzip2 bzip2-devel openssl-devel openldap-devel libxml2-devel freetype-devel libxslt-devel sqlite-devel expat-devel tcl-devel tk-devel bison flex autoconf unzip dos2unix procmail cppunit-devel doxygen graphviz

#ARCHIVE
RUN dnf -y install libtool libdb-devel

#ICD
RUN dnf -y install cmake blas-devel cfitsio-devel wcslib-devel lapack-devel

#CONTROL
RUN dnf -y install binutils-devel libmemcached-devel

#CORR
#RUN dnf -y install pgplot-devel

#CORRCommon
RUN dnf -y install kernel kernel-devel

#TELCAL
RUN dnf -y install motif-devel texlive

#RTI DDS
#RUN cd / && curl http://*****:*****@webdav.sco.alma.cl/restricted/propietary/RTI-RHEL6-x86_64.tar.bz2 | tar -xj

#Debugging Tools
RUN dnf -y install gdb net-tools valgrind
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
