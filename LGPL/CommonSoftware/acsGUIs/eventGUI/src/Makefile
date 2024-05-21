#*******************************************************************************
# ALMA - Atacama Large Millimiter Array
# (c) European Southern Observatory, 2009 
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
#
# "@(#) $Id: Makefile,v 1.3 2012/03/26 12:56:11 rtobar Exp $"
#
# Makefile of ........
#
# who       when      what
# --------  --------  ----------------------------------------------
# almadev  2009-10-11  created
#

#*******************************************************************************
# This Makefile follows ACS Standards (see Makefile(5) for more).
#*******************************************************************************
# REMARKS
#    None
#-------------------------------------------------------------------------------
-include rules.mk

#
#>>>>> END OF standard rules

#
# INCLUDE STANDARDS
# -----------------

MAKEDIRTMP := $(shell searchFile include/acsMakefile)
ifneq ($(MAKEDIRTMP),\#error\#)
   MAKEDIR := $(MAKEDIRTMP)/include
   include $(MAKEDIR)/acsMakefile
endif

#
# TARGETS
# -------
#

# Determine the host architecture and use it to decide which version of the
# product should we install
ARCH=$(shell getconf LONG_BIT)

# We only support 32 and 64 bits builds
ifneq ($(ARCH),32)
ifneq ($(ARCH),64)
	$(error Unsupported architecture: "$(ARCH)")
endif
endif

# Deduce the zipfile suffix
ifeq ($(ARCH), 32)
   ZIP_SUFFIX=x86
else
   ZIP_SUFFIX=x86_64
endif

$(eval $(call acsMakeMavenPreparations,event-gui))

all:	do_all
	@$(if $(MAKE_NOMAVEN),,mvn -B -f .. -Dacs.version=$(event-gui_art_ver) package)
	@echo " . . . 'all' done" 

clean : clean_all 
	@$(if $(MAKE_NOMAVEN),,mvn -B -f .. -Dacs.version=$(event-gui_art_ver) clean)
	@echo " . . . clean done"

clean_dist : clean_all clean_dist_all 
	@echo " . . . clean_dist done"

man   : do_man 
	@echo " . . . man page(s) done"

install : install_all
	@$(if $(MAKE_NOMAVEN),,echo "Will install eventGUI to $(INSTALL_ROOT)/lib/event-gui")
	@$(if $(MAKE_NOMAVEN),,rm -rf $(INSTALL_ROOT)/lib/event-gui)
	@$(if $(MAKE_NOMAVEN),,$(TAR) --warning=none -C $(INSTALL_ROOT)/lib -xzf $(PWD)/../lib/poms/event-gui.product/target/products/event-gui-*-linux.gtk.$(ZIP_SUFFIX).tar.gz)
	@echo " . . . installation done"
