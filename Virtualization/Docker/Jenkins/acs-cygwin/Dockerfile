#ACS image for building on Cygwin
FROM quay.io/centos/centos:stream9

ARG RTIDDS_URL

#Configure needed repositories
RUN dnf -y install dnf-plugins-core
RUN dnf config-manager --set-enabled crb
#RUN dnf -y install epel-release
RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
#RUN dnf -y install https://download1.rpmfusion.org/free/el/rpmfusion-free-release-9.noarch.rpm

#General packages
RUN dnf -y install vim sudo dbus-x11 wget openssh-server rsync passwd hostname patch time bc procps #lsb_release

#Install Git and Git LFS
RUN dnf -y install git git-lfs

#Debugging Tools
RUN dnf -y install gdb net-tools

#Wine dependencies
RUN dnf -y install xz gcc flex bison libX11-devel freetype-devel gettext-devel libXrender-devel gnutls-devel alsa-lib-devel openldap-devel \
           libXcursor-devel libXi-devel libXrandr-devel libXfixes-devel libXinerama-devel libXcomposite-devel dbus-devel sane-backends-devel \
           libpcap-devel libusb-devel cups-devel samba-devel pulseaudio-libs-devel systemd-devel libgphoto2-devel fontconfig-devel ocl-icd-devel \
           SDL2-devel libXxf86vm-devel gstreamer1-devel mingw64-gcc-c++ libv4l-devel mesa-libOSMesa-devel

#Wine for running Windows and Cygwin
RUN wget https://dl.winehq.org/wine/source/7.0/wine-7.0.tar.xz -O /tmp/wine-7.0.tar.xz
RUN ls -lh /tmp/wine-7.0.tar.xz
RUN tar xf /tmp/wine-7.0.tar.xz -C /tmp
RUN rm -f /tmp/wine-7.0.tar.xz
RUN cd /tmp/wine-7.0; ./configure --enable-win64 && make && make install

#RTI DDS
#RUN cd /alma && curl ${RTIDDS_URL} | tar -xj || true

# Prepare it to be a jenkins node
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config && \
    sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config && \
    adduser jenkins && echo new2me | passwd jenkins --stdin && \
    mkdir /home/jenkins/workspace

#Copy SSH Key
COPY id_rsa /home/jenkins/.ssh/id_rsa
COPY id_rsa.pub /home/jenkins/.ssh/id_rsa.pub
RUN ssh-keyscan -p 7999 bitbucket.sco.alma.cl,200.2.1.51 >> /home/jenkins/.ssh/known_hosts
COPY settings.xml /home/jenkins/.m2/settings.xml
RUN chown jenkins:jenkins -R /home/jenkins

USER jenkins
WORKDIR /home/jenkins/workspace
