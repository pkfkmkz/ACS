#*******************************************************************************
# ALMA - Atacama Large Millimeter Array
# Copyright (c) Associated Universities Inc., 2021
# (in the framework of the ALMA collaboration).
# All rights reserved.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#*******************************************************************************

SHELL:=/bin/bash
SHUNIT_VER:=2.1.8

$(if $(ALMASW_INSTDIR),,$(error The ACS environment should be loaded. Please source .bash_profile.acs))
INSTALL_DIR:=$(if $(INSTALL_DIR),$(INSTALL_DIR),$(ACSDEPS))

include $(INSTALL_DIR)/include/config.mk

HAVE_SHUNIT2:=$(if $(MAKE_SHUNIT2),,$(shell which shunit2 2> /dev/null |grep -v $(ALMASW_INSTDIR)))

MODPATH:=$(if $(MODPATH),$(MODPATH),..)
MODRULE:=$(if $(MODRULE),$(MODRULE))

#
# TARGETS
# -------
$(MODRULE)all: $(if $(HAVE_SHUNIT2),,$(MODRULE)all_shunit2)
	@echo " . . . 'all' done" 

$(MODRULE)clean:
	@echo " . . . clean done"

$(MODRULE)clean_dist: $(MODRULE)clean
	@echo "\n . . . removing the shunit2 directory . . ."
	@$(if $(wildcard $(MODPATH)/src/shunit2-$(SHUNIT_VER)),rm -rf $(MODPATH)/src/shunit2-$(SHUNIT_VER))
	@echo " . . . clean_dist done"

$(MODRULE)man:
	@echo " . . . man page(s) done"

$(MODRULE)install: $(MODRULE)all $(if $(HAVE_SHUNIT2),,$(MODRULE)install_shunit2)
	@echo " . . . installation done"

.INTERMEDIATE: $(MODRULE)unpack
$(MODRULE)unpack: | $(MODPATH)/src/shunit2-$(SHUNIT_VER)
$(MODPATH)/src/shunit2-$(SHUNIT_VER): $(MODPATH)/src/shunit2-$(SHUNIT_VER).tar.gz
	@echo ". . . unpacking the tar files . . . "
	@$(TAR) -C $(MODPATH)/src/ -xzf $(MODPATH)/src/shunit2-$(SHUNIT_VER).tar.gz

.INTERMEDIATE: (MODRULE)all_shunit2
$(MODRULE)all_shunit2: $(MODRULE)unpack $(MODPATH)/src/shunit2-$(SHUNIT_VER)/shunit2
$(MODPATH)/src/shunit2-$(SHUNIT_VER)/shunit2: | $(MODPATH)/src/shunit2-$(SHUNIT_VER)

.INTERMEDIATE: $(MODRULE)install_shunit2
$(MODRULE)install_shunit2: $(MODRULE)all_shunit2 $(INSTALL_DIR)/bin/shunit2
$(INSTALL_DIR)/bin/shunit2: $(MODPATH)/src/shunit2-$(SHUNIT_VER)/shunit2
	@echo ". . . installing shunit2 . . . "
	@cp $< $@
