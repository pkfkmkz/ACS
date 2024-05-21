#*******************************************************************************
# E.S.O. - ACS project
#
# Makefile of cppunit
#
# who       when      what
# --------  --------  ----------------------------------------------
# almamgr  12/12/03  created

define newline


endef

define cppunit-src
#include <iostream>
#include <cppunit/config-auto.h>
int main() {
    std::cout << CPPUNIT_VERSION << std::endl;
    return 0;
}
endef

define cppunit-version
$(shell echo -e '$(subst $(newline),\n,$(cppunit-src))' |g++ -o /tmp/$$$$.bin -x c++ -; /tmp/$$$$.bin; rm -f /tmp/$$$$.bin)
endef

SHELL=/bin/bash
PLATFORM:=$(shell uname)

$(if $(ALMASW_INSTDIR),,$(error The ACS environment should be loaded. Please source .bash_profile.acs))
INSTALL_DIR:=$(if $(INSTALL_DIR),$(INSTALL_DIR),$(ACSDEPS))

include $(INSTALL_DIR)/include/config.mk

RANLIB:=$(shell which ranlib)
CONFIGPARMS:=$(if $(filter SunOS,$(PLATFORM)),CC=gcc CXX=g++ LD=g++ RANLIB=$(RANLIB))

CPPUNIT_VER:= 1.14.0

HAVE_CPPUNIT:=$(if $(MAKE_CPPUNIT),,$(shell echo "\#include <cppunit/config-auto.h>" |g++ -I$(ACSDEPS)/include -E - 2> /dev/null |grep cppunit |grep -v $(ACSDEPS)))
HAVE_CPPUNIT:=$(if $(HAVE_CPPUNIT),$(if $(filter $(CPPUNIT_VER),$(shell echo $(CPPUNIT_VER) $(call cppunit-version)|xargs -n1 |sort -V |head -n1)),$(HAVE_CPPUNIT),),)

MODPATH:=$(if $(MODPATH),$(MODPATH),..)
MODRULE:=$(if $(MODRULE),$(MODRULE))

.PHONY: $(MODRULE)all
$(MODRULE)all: $(if $(HAVE_CPPUNIT),,$(MODRULE)all_cppunit)
	@echo " . . . 'all' done" 

.PHONY: $(MODRULE)clean
$(MODRULE)clean:
	@$(if $(wildcard $(MODPATH)/src/cppunit-$(CPPUNIT_VER)),cd $(MODPATH)/src/cppunit-$(CPPUNIT_VER); make clean > /dev/null)
	@echo " . . . clean done"

.PHONY: $(MODRULE)clean_dist
$(MODRULE)clean_dist: $(MODRULE)clean
	@echo "\n . . . removing the cppunit directory and log file . . .$(MODPATH)/src/cppunit-$(CPPUNIT_VER)"
	@rm -rf $(MODPATH)/src/cppunit-$(CPPUNIT_VER) $(MODPATH)/src/last_patched
	@echo " . . . clean_dist done"

.PHONY: $(MODRULE)install
$(MODRULE)install : $(MODRULE)all
	@echo ". . . installing cppunit . . . "
	@$(if $(HAVE_CPPUNIT),,cd $(MODPATH)/src/cppunit-$(CPPUNIT_VER); $(MAKE) install)
	@echo " . . . installation done"

.INTERMEDIATE: $(MODRULE)unpack
$(MODRULE)unpack: | $(MODPATH)/src/cppunit-$(CPPUNIT_VER)
$(MODPATH)/src/cppunit-$(CPPUNIT_VER): $(MODPATH)/src/cppunit-$(CPPUNIT_VER).tar.gz
	@echo ". . . unpacking the tar files . . . "
	@rm -rf $(MODPATH)/src/last_patched
	@$(TAR) -C $(MODPATH)/src -xzf $(MODPATH)/src/cppunit-$(CPPUNIT_VER).tar.gz

.INTERMEDIATE: $(MODRULE)doxyfile
$(MODRULE)doxyfile: $(MODPATH)/src/cppunit-$(CPPUNIT_VER)/doc/Doxyfile.in
$(MODPATH)/src/cppunit-$(CPPUNIT_VER)/doc/Doxyfile.in: $(MODRULE)unpack
	@echo ". . . updating Doxyfile (ingnore error messages here) . . . "
	@cd $(MODPATH)/src/cppunit-$(CPPUNIT_VER)/doc; doxygen -u Doxyfile.in

$(MODRULE)patch: $(MODRULE)unpack $(MODRULE)last_patched

$(MODRULE)last_patched: cppunit-gcc-3_4_3.patch | cppunit-$(CPPUNIT_VER)
	@cd $(MODPATH)/src/cppunit-$(CPPUNIT_VER); patch -p1 < ../cppunit-gcc-3_4_3.patch
	@touch $(MODPATH)/src/last_patched
	@echo " . . . patch applied";\

.PHONY: $(MODRULE)prepare_patch
$(MODRULE)prepare_patch: $(MODPATH)/src/cppunit-gcc-3_4_3.patch
$(MODPATH)/src/cppunit-gcc-3_4_3.patch:
	@mv $(MODPATH)/src/cppunit-gcc-3_4_3.patch $(MODPATH)/src/cppunit-gcc-3_4_3.patch.old
	@rm -rf $(MODPATH)/src/tmp_unpack; mkdir -p $(MODPATH)/src/tmp_unpack
	@$(TAR) -C $(MODPATH)/src/tmp_unpack -xzf ../cppunit-$(CPPUNIT_VER).tar.gz
	@mv $(MODPATH)/src/tmp_unpack/cppunit-$(CPPUNIT_VER) $(MODPATH)/src/tmp_unpack/cppunit-$(CPPUNIT_VER).orig
	@cd $(MODPATH)/src; LC_ALL=C TZ=UTC0 diff -Naur tmp_unpack/cppunit-$(CPPUNIT_VER).orig cppunit-$(CPPUNIT_VER) > $(MODPATH)/src/cppunit-gcc-3_4_3.patch || bash -c "exit $(echo $? |tr '1' '0')"
	@rm -rf $(MODPATH)/src/tmp_unpack
	@echo " . . . patch file prepared"

.INTERMEDIATE: $(MODRULE)configure
$(MODRULE)configure: $(MODPATH)/src/cppunit-$(CPPUNIT_VER)/Makefile
$(MODPATH)/src/cppunit-$(CPPUNIT_VER)/Makefile: $(MODRULE)unpack $(MODRULE)doxyfile
	@echo ". . . running configure . . . "
	@cd $(MODPATH)/src/cppunit-$(CPPUNIT_VER); ./configure $(CONFIGPARMS) --prefix=$(INSTALL_DIR)

.INTERMEDIATE: $(MODRULE)all_cppunit
$(MODRULE)all_cppunit: $(MODPATH)/src/cppunit-$(CPPUNIT_VER)/src/cppunit/.libs/libcppunit.so
$(MODPATH)/src/cppunit-$(CPPUNIT_VER)/src/cppunit/.libs/libcppunit.so: $(MODRULE)configure
	@echo ". . . building . . . "
	@cd $(MODPATH)/src/cppunit-$(CPPUNIT_VER); $(MAKE) $(JOB_FLAG) all
