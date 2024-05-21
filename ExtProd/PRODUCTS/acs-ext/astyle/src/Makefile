#*******************************************************************************
# E.S.O. - ACS project
#
# Makefile of astyle
#
# who       when      what
# --------  --------  ----------------------------------------------
# almamgr  12/12/03  created

SHELL=/bin/bash
PLATFORM:=$(shell uname)

$(if $(ALMASW_INSTDIR),,$(error The ACS environment should be loaded. Please source .bash_profile.acs))
INSTALL_DIR:=$(if $(INSTALL_DIR),$(INSTALL_DIR),$(ACSDEPS))

include $(INSTALL_DIR)/include/config.mk

ASTYLE_VER:= 3.1

HAVE_ASTYLE:=$(if $(MAKE_ASTYLE),,$(shell which astyle 2> /dev/null |grep -v $(ALMASW_INSTDIR)))
HAVE_ASTYLE:=$(if $(HAVE_ASTYLE),$(if $(filter $(ASTYLE_VER),$(shell echo $(ASTYLE_VER) $$(astyle --version |cut -d " " -f 4)|xargs -n1 |sort -V |head -n1)),$(HAVE_ASTYLE),),)

MODPATH:=$(if $(MODPATH),$(MODPATH),..)
MODRULE:=$(if $(MODRULE),$(MODRULE))

.PHONY: $(MODRULE)all
$(MODRULE)all: $(if $(HAVE_ASTYLE),,$(MODRULE)all_astyle)
	@echo " . . . 'all' done" 

.PHONY: $(MODRULE)clean
$(MODRULE)clean:
	@$(if $(wildcard $(MODPATH)/src/astyle),cd $(MODPATH)/src/astyle/build/gcc; make clean > /dev/null)
	@echo " . . . clean done"

.PHONY: $(MODRULE)clean_dist
$(MODRULE)clean_dist: $(MODRULE)clean
	@echo "\n . . . removing the astyle directory and log file . . .$(MODPATH)/src/astyle"
	@rm -rf $(MODPATH)/src/astyle $(MODPATH)/src/last_patched
	@echo " . . . clean_dist done"

.PHONY: $(MODRULE)install
$(MODRULE)install: $(MODRULE)all $(if $(HAVE_ASTYLE),,$(MODRULE)install_astyle)
	@echo " . . . installation done"

.INTERMEDIATE: $(MODRULE)unpack
$(MODRULE)unpack: | $(MODPATH)/src/astyle
$(MODPATH)/src/astyle: | $(MODPATH)/src/astyle_$(ASTYLE_VER)_linux.tar.gz
	@echo ". . . unpacking the tar files . . . "
	@rm -f $(MODPATH)/src/last_patched
	@$(TAR) -C $(MODPATH)/src -xzf $(MODPATH)/src/astyle_$(ASTYLE_VER)_linux.tar.gz

.INTERMEDIATE: $(MODRULE)patch
$(MODRULE)patch: $(MODRULE)last_patched
$(MODRULE)last_patched: $(MODRULE)unpack $(MODPATH)/src/astyle.patch
	@cd $(MODPATH)/src/astyle; patch -p1 < ../astyle.patch
	@touch $(MODPATH)/src/last_patched
	@echo " . . . patch applied";\

.PHONY: $(MODRULE)prepare_patch
$(MODRULE)prepare_patch: $(MODRULE)unpack
	@mv $(MODPATH)/src/astyle.patch $(MODPATH)/src/astyle.patch.old
	@rm -rf $(MODPATH)/src/tmp_unpack; mkdir -p $(MODPATH)/src/tmp_unpack
	@$(TAR) -C $(MODPATH)/src/tmp_unpack -xzf $(MODPATH)/src/astyle_$(ASTYLE_VER)_linux.tar.gz
	@mv $(MODPATH)/src/tmp_unpack/astyle $(MODPATH)/src/tmp_unpack/astyle.orig
	@cd $(MODPATH)/src; LC_ALL=C TZ=UTC0 diff -Naur tmp_unpack/astyle.orig astyle > $(MODPATH)/src/astyle.patch || bash -c "exit $(echo $? |tr '1' '0')"
	@rm -rf $(MODPATH)/src/tmp_unpack
	@echo " . . . patch file prepared"

.INTERMEDIATE: $(MODRULE)all_astyle
$(MODRULE)all_astyle: $(MODPATH)/src/astyle/build/gcc/bin/astyle
$(MODPATH)/src/astyle/build/gcc/bin/astyle: $(MODRULE)patch
	@echo ". . . building . . . "
	@cd $(MODPATH)/src/astyle/build/gcc; $(MAKE) $(JOB_FLAG) all

.INTERMEDIATE: $(MODRULE)install_astyle
$(MODRULE)install_astyle: $(INSTALL_DIR)/bin/astyle
$(INSTALL_DIR)/bin/astyle: $(MODRULE)all_astyle
	@echo ". . . installing astyle . . . "
	@cd $(MODPATH)/src/astyle/build/gcc; prefix=$(INSTALL_DIR) $(MAKE) install
