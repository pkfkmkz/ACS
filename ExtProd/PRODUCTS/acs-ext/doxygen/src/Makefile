#*************************************************************************
# E.S.O. - ACS project
#
# Makefile of doxygen
#
# who       when      what
# --------  --------  ----------------------------------------------
# psivera  13/07/01  created
# psivera  03/09/01  added graphviz stuff (in dist_clean)
#

define doxygen-version
$(shell doxygen -v)
endef

define graphviz-version
$(shell dot -V 2>&1 |cut -d " " -f 5)
endef

#USER_CFLAGS =
SHELL=/bin/bash
PLATFORM:=$(shell uname)

$(if $(ALMASW_INSTDIR),,$(error The ACS environment should be loaded. Please source .bash_profile.acs))
INSTALL_DIR:=$(if $(INSTALL_DIR),$(INSTALL_DIR),$(ACSDEPS))

include $(INSTALL_DIR)/include/config.mk

DOX_VER:=1.8.14
GRAPH_VER:=2.40.1

MODULES:=graphviz-$(GRAPH_VER) doxygen-$(DOX_VER)

HAVE_DOXYGEN:=$(if $(MAKE_DOXYGEN),,$(shell which doxygen 2> /dev/null |grep -v $(ALMASW_INSTDIR)))
HAVE_DOXYGEN:=$(if $(HAVE_DOXYGEN),$(if $(filter $(DOX_VER),$(shell echo $(DOX_VER) $(doxygen-version)|xargs -n1 |sort -V |head -n1)),$(HAVE_DOXYGEN),),)

HAVE_GRAPHVIZ:=$(if $(MAKE_GRAPHVIZ),,$(shell which dot 2> /dev/null |grep -v $(ALMASW_INSTDIR)))
HAVE_GRAPHVIZ:=$(if $(HAVE_GRAPHVIZ),$(if $(filter $(GRAPH_VER),$(shell echo $(GRAPH_VER) $(graphviz-version)|xargs -n1 |sort -V |head -n1)),$(HAVE_GRAPHVIZ),),)

MODPATH:=$(if $(MODPATH),$(MODPATH),..)
MODRULE:=$(if $(MODRULE),$(MODRULE))

.PHONY: $(MODRULE)all
$(MODRULE)all: $(if $(HAVE_DOXYGEN),,$(MODRULE)all_dox) $(if $(HAVE_GRAPHVIZ),,$(MODRULE)all_gv)
	@echo " . . . 'all' done"

$(MODRULE)clean:
	@rm -rf $(MODPATH)/src/doxygen-$(DOX_VER)/build
	@echo " . . . 'clean' done"

$(MODRULE)clean_dist: $(MODRULE)clean
	@echo " . . . removing the doxygen/graphviz directories and log file . . ."
	@rm -rf $(MODPATH)/src/doxygen-$(DOX_VER) $(MODPATH)/src/graphviz-$(GRAPH_VER) $(MODPATH)/src/config_dox.log $(MODPATH)/src/config_gv.log $(MODPATH)/src/last_patched_dox $(MODPATH)/src/last_patched_gv
	@echo " . . . 'clean_dist' done"

$(MODRULE)install: $(MODRULE)all $(if $(HAVE_DOXYGEN),,$(MODRULE)install_dox) $(if $(HAVE_GRAPHVIZ),,$(MODRULE)install_gv)
	@echo " . . . 'install' done"

# This target prepares the patch file after new patches have been applied/coded. It assumes that the new/patched files are in
#     doxygen-$(DOX_VER)
# and unpacks the unpatched code to make the diff
#     tmp_unpack/doxygen-$(DOX_VER).orig
#
# Does not use doxygen as directory name but adds .orig to make clearer reading the patch file. Before preparing the patch also cleans up the code with the patches
# makes a copy of the previous patch file for comparison and deleted the unpatched code afterwards.

$(MODRULE)preparePatch_dox:
	@mv $(MODPATH)/src/doxygen.patch $(MODPATH)/src/doxygen.patch.old
	@rm -rf $(MODPATH)/src/tmp_unpack
	@mkdir -p $(MODPATH)/src/tmp_unpack
	@$(TAR) -C $(MODPATH)/src/tmp_unpack -xzf $(MODPATH)/src/doxygen-$(DOX_VER).src.tar.gz
	@mv $(MODPATH)/src/tmp_unpack/doxygen-$(DOX_VER) $(MODPATH)/src/tmp_unpack/doxygen-$(DOX_VER).orig
	@cd $(MODPATH)/src; LC_ALL=C TZ=UTC0 diff -Naur tmp_unpack/doxygen-$(DOX_VER).orig doxygen-$(DOX_VER) > doxygen.patch || bash -c "exit $(echo $? |tr '1' '0')"
	@rm -rf i$(MODPATH)/src/tmp_unpack
	@echo " . . . doxygen patch file prepared"

$(MODRULE)preparePatch_gv:
	@mv $(MODPATH)/src/graphviz.patch $(MODPATH)/src/graphviz.patch.old
	@rm -rf $(MODPATH)/src/tmp_unpack
	@mkdir -p $(MODPATH)/src/tmp_unpack
	@$(TAR) -C $(MODPATH)/src/tmp_unpack -xzf $(MODPATH)/src/graphviz-$(GRAPH_VER).tar.gz
	@mv $(MODPATH)/src/tmp_unpack/graphviz-$(GRAPH_VER) $(MODPATH)/src/tmp_unpack/graphviz-$(GRAPH_VER).orig
	@cd $(MODPATH)/src; LC_ALL=C TZ=UTC0 diff -Naur tmp_unpack/graphviz-$(GRAPH_VER).orig graphviz-$(GRAPH_VER) > graphviz.patch || bash -c "exit $(echo $? |tr '1' '0')"
	@rm -rf i$(MODPATH)/src/tmp_unpack
	@echo " . . . graphviz patch file prepared"

.INTERMEDIATE: $(MODRULE)unpack_dox
$(MODRULE)unpack_dox: | $(MODPATH)/src/doxygen-$(DOX_VER)
$(MODPATH)/src/doxygen-$(DOX_VER):
	@$(TAR) -C $(MODPATH)/src -xzf $(MODPATH)/src/doxygen-$(DOX_VER).src.tar.gz
	@echo "unpacking doxygen-$(DOX_VER) done"

.INTERMEDIATE: $(MODRULE)unpack_gv
$(MODRULE)unpack_gv: | $(MODPATH)/src/graphviz-$(GRAPH_VER)
$(MODPATH)/src/graphviz-$(GRAPH_VER):
	@$(TAR) -C $(MODPATH)/src -xzf $(MODPATH)/src/graphviz-$(GRAPH_VER).tar.gz
	@echo "unpacking graphviz-$(GRAPH_VER) done"

.INTERMEDIATE: $(MODRULE)patch_dox
$(MODRULE)patch_dox: $(MODPATH)/src/last_patched_dox
$(MODPATH)/src/last_patched_dox: $(MODRULE)unpack_dox $(MODPATH)/src/doxygen.patch
	@cd $(MODPATH)/src/doxygen-$(DOX_VER); patch -p1 < ../doxygen.patch
	@touch $(MODPATH)/src/last_patched_dox
	@echo " . . . doxygen patch applied"

.INTERMEDIATE: $(MODRULE)patch_gv
$(MODRULE)patch_gv: $(MODPATH)/src/last_patched_gv
$(MODPATH)/src/last_patched_gv: $(MODRULE)unpack_gv $(MODPATH)/src/graphviz.patch
	@cd $(MODPATH)/src/graphviz-$(GRAPH_VER); patch -p1 < ../graphviz.patch
	@touch $(MODPATH)/src/last_patched_gv
	@echo " . . . graphviz patch applied"

.INTERMEDIATE: $(MODRULE)configure_dox
$(MODRULE)configure_dox: $(MODPATH)/src/doxygen-$(DOX_VER)/build/Makefile
$(MODPATH)/src/doxygen-$(DOX_VER)/build/Makefile: $(MODRULE)patch_dox | $(MODPATH)/src/doxygen-$(DOX_VER)/build
	@echo "Configuring doxygen . . . "
	@cd $(MODPATH)/src/doxygen-$(DOX_VER)/build; cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR) -G "Unix Makefiles" .. > ../../config_dox.log

$(MODPATH)/src/doxygen-$(DOX_VER)/build: |$(MODPATH)/src/doxygen-$(DOX_VER)
	@$(if $(wildcard $(MODPATH)/src/doxygen-$(DOX_VER)/build),,mkdir $(MODPATH)/src/doxygen-$(DOX_VER)/build)

.INTERMEDIATE: $(MODRULE)configure_gv
$(MODRULE)configure_gv: $(MODPATH)/src/graphviz-$(GRAPH_VER)/Makefile
$(MODPATH)/src/graphviz-$(GRAPH_VER)/Makefile: $(MODRULE)patch_gv
	@echo "Configuring graphviz . . . "
	@$(if $(filter Linux,$(OSYSTEM)),cd $(MODPATH)/src/graphviz-$(GRAPH_VER); ./configure --prefix=$(INSTALL_DIR) --disable-swig > ../config_gv.log)
	@$(if $(filter SunOS,$(OSYSTEM)),cd $(MODPATH)/src/graphviz-$(GRAPH_VER); ./configure --prefix=$(INSTALL_DIR) --with-pnglibdir=$TCLTK_ROOT/lib --with-pngincludedir=$TCLTK_ROOT/include > ../config_gv.log)

.INTERMEDIATE: $(MODRULE)all_dox
$(MODRULE)all_dox: $(MODPATH)/src/doxygen-$(DOX_VER)/build/bin/doxygen
$(MODPATH)/src/doxygen-$(DOX_VER)/build/bin/doxygen: $(MODRULE)configure_dox
	@$(MAKE) $(JOB_FLAG) -C $(MODPATH)/src/doxygen-$(DOX_VER)/build
	@echo " . . . 'all_dox' done"

.INTERMEDIATE: $(MODRULE)all_gv
$(MODRULE)all_gv: $(MODPATH)/src/graphviz-$(GRAPH_VER)/cmd/dot/dot
$(MODPATH)/src/graphviz-$(GRAPH_VER)/cmd/dot/dot: $(MODRULE)configure_gv
	@$(MAKE) $(JOB_FLAG) -C $(MODPATH)/src/graphviz-$(GRAPH_VER) all
	@echo " . . . 'all_gv' done"

.INTERMEDIATE: $(MODRULE)install_dox
$(MODRULE)install_dox: $(INSTALL_DIR)/bin/doxygen
$(INSTALL_DIR)/bin/doxygen: $(MODRULE)all_dox
	@$(MAKE) -C $(MODPATH)/src/doxygen-$(DOX_VER)/build install
	@echo " . . . 'install_dox' done"

.INTERMEDIATE: $(MODRULE)install_gv
$(MODRULE)install_gv: $(INSTALL_DIR)/bin/dot
$(INSTALL_DIR)/bin/dot: $(MODRULE)all_gv
	@$(MAKE) -C $(MODPATH)/src/graphviz-$(GRAPH_VER) install
	@echo " . . . 'install_gv' done"
