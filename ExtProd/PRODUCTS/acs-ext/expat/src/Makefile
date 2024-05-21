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
EXPAT_VER:=1.95.3

$(if $(ALMASW_INSTDIR),,$(error The ACS environment should be loaded. Please source .bash_profile.acs))
INSTALL_DIR:=$(if $(INSTALL_DIR),$(INSTALL_DIR),$(ACSDEPS))

include $(INSTALL_DIR)/include/config.mk

HAVE_EXPAT:=$(if $(MAKE_EXPAT),,$(shell echo "\#include <expat.h>" |g++ -E - 2> /dev/null |grep expat))

MODPATH:=$(if $(MODPATH),$(MODPATH),..)
MODRULE:=$(if $(MODRULE),$(MODRULE))

#
# TARGETS
# -------
$(MODRULE)all: $(if $(HAVE_EXPAT),,$(MODRULE)all_expat)
	@echo " . . . 'all' done"

$(MODRULE)clean: $(if $(HAVE_EXPAT),,$(MODRULE)clean_expat)
	@echo " . . . clean done"

$(MODRULE)clean_dist: $(if $(HAVE_EXPAT),,$(MODRULE)clean_dist_expat)
	@echo " . . . clean_dist done"

$(MODRULE)install: $(if $(HAVE_EXPAT),,$(MODRULE)install_expat)
	@echo " . . . installation done"

$(MODRULE)all_expat:
	make -C $(MODPATH)/src -f Makefile.lcu MAKEDIR=$(MODPATH)/make ACSROOT=$(INSTALL_DIR) all
$(MODRULE)install_expat:
	make -C $(MODPATH)/src -f Makefile.lcu MAKEDIR=$(MODPATH)/make ACSROOT=$(INSTALL_DIR) install
$(MODRULE)clean_expat:
	make -C $(MODPATH)/src -f Makefile.lcu MAKEDIR=$(MODPATH)/make ACSROOT=$(INSTALL_DIR) clean
$(MODRULE)clean_dist_expat:
	make -C $(MODPATH)/src -f Makefile.lcu MAKEDIR=$(MODPATH)/make ACSROOT=$(INSTALL_DIR) clean_dist
