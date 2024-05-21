#*******************************************************************************
# E.S.O. - ACS project
#
# "@(#) $Id: Makefile,v 1.5 2010/03/03 13:18:09 mzampare Exp $"
#
# Makefile of ........
#
# who       when      what
# --------  --------  ----------------------------------------------
# almamgr  12/12/03  created
#

#*******************************************************************************
# This Makefile follows VLT Standards (see Makefile(5) for more).
#*******************************************************************************
# REMARKS
#    None
#------------------------------------------------------------------------

define newline


endef

define xerces-src
#include <iostream>
#include <xercesc/util/XercesVersion.hpp>
int main() {
    std::cout << XERCES_VERSION_MAJOR << "." << XERCES_VERSION_MINOR << "." << XERCES_VERSION_REVISION << std::endl;
    return 0;
}
endef

define xerces-version
$(shell echo -e '$(subst $(newline),\n,$(xerces-src))' |g++ -o /tmp/$$$$.bin -x c++ -; /tmp/$$$$.bin; rm -f /tmp/$$$$.bin)
endef

SHELL=/bin/bash
PLATFORM := $(shell uname)
XERCES_VER := 3.2.2
XERCES_MAJOR_VER := 32
export XERCESCROOT=$(CURDIR)/xerces-c-$(XERCES_VER)

$(if $(ALMASW_INSTDIR),,$(error The ACS environment should be loaded. Please source .bash_profile.acs))
INSTALL_DIR:=$(if $(INSTALL_DIR),$(INSTALL_DIR),$(ACSDEPS))

include $(INSTALL_DIR)/include/config.mk

HAVE_XERCES:=$(if $(MAKE_XERCES),,$(shell echo "\#include <xercesc/util/XercesVersion.hpp>" |g++ -I$(ACSDEPS)/include -E - 2> /dev/null |grep xercesc |grep -v $(ACSDEPS)))
HAVE_XERCES:=$(if $(HAVE_XERCES),$(if $(filter $(XERCES_VER),$(shell echo $(XERCES_VER) $(call xerces-version)|xargs -n1 |sort -V |head -n1)),$(HAVE_XERCES),),)

MODPATH:=$(if $(MODPATH),$(MODPATH),..)
MODRULE:=$(if $(MODRULE),$(MODRULE))

#
# TARGETS
# -------
$(MODRULE)all:	$(if $(HAVE_XERCES),,$(MODRULE)build_xerces)
	@echo " . . . 'all' done" 

$(MODRULE)clean :  
	@rm -rf xerces-c-$(XERCES_VER)
	@echo " . . . clean done";\

$(MODRULE)clean_dist :  
	@echo "\n . . . removing the xerces-c directory and log file . . ."
	@rm -rf $(MODPATH)/xerces-c-$(XERCES_VER) configure.log
	@echo " . . . clean_dist done"

$(MODRULE)clean_install:
	@rm -rf $(INSTALL_DIR)/lib/libxerces-c.so
	@rm -rf $(INSTALL_DIR)/lib/libxerces-c.so.$(XERCES_MAJOR_VER)
	@rm -rf $(INSTALL_DIR)/lib/libxerces-c.so.$(XERCES_MAJOR_VER).0
	@rm -rf $(INSTALL_DIR)/lib/libxerces-depdom.so
	@rm -rf $(INSTALL_DIR)/lib/libxerces-depdom.so.$(XERCES_MAJOR_VER)
	@rm -rf $(INSTALL_DIR)/lib/libxerces-depdom.so.$(XERCES_MAJOR_VER).0
	@rm -rf $(INSTALL_DIR)/include/xercesc
	@echo " . . . clean_install done"

$(MODRULE)man   :  
	@echo " . . . man page(s) done"

$(MODRULE)install : $(if $(HAVE_XERCES),,$(MODRULE)install_xerces)
	@echo " . . . installation done"

$(MODRULE)install_xerces : $(MODRULE)build_xerces
	@echo ". . . installing xerces-c . . . "
	@cd $(MODPATH)/src/xerces-c-$(XERCES_VER); make install

$(MODRULE)unpack :
	@echo ". . . unpacking the tar file . . . "
	@$(TAR) -xzf $(MODPATH)/src/xerces-c-$(XERCES_VER).tar.gz -C $(MODPATH)/src

$(MODRULE)configure : $(MODRULE)unpack
	@echo ". . . running configure . . . "
	@echo "cwd is: $(CURDIR)"
	@cd $(MODPATH)/src/xerces-c-$(XERCES_VER); autoconf
	@cd $(MODPATH)/src/xerces-c-$(XERCES_VER); ./configure --prefix $(INSTALL_DIR) > configure.log 2>&1

.NOTPARALLE: $(MODRULE)build_xerces
$(MODRULE)build_xerces : $(MODRULE)configure
	@echo ". . . building xerces. . . "
	@cd $(MODPATH)/src/xerces-c-$(XERCES_VER); make -j
