#*******************************************************************************
# ALMA - Atacama Large Millimeter Array
# Copyright (c) Associated Universities Inc., 2020
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

#*******************************************************************************
# This Makefile follows ACS Standards (see Makefile(5) for more).
#*******************************************************************************
# REMARKS
#    None
#-------------------------------------------------------------------------------
-include $(MODPATH)/src/rules.mk

$(MODRULE)all: $(MODRULE)swig $(MODPATH) $(MODDEP)
	$(AT)echo " . . . $@ done"

$(MODRULE)install: $(MODPATH) install_$(MODDEP)
	$(AT)$(RM) $(INSTALL_ROOT)/$(PYTHON_SITE_PACKAGES)/_acstimeSWIG.$(SHLIB_EXT)
	$(AT)cp $(MODPATH)/lib/lib_acstimeSWIG.$(SHLIB_EXT) $(INSTALL_ROOT)/$(PYTHON_SITE_PACKAGES)/_acstimeSWIG.$(SHLIB_EXT)
	$(AT)echo " . . . $@ done"

$(MODRULE)clean: $(MODPATH) clean_$(MODDEP)
	$(AT)echo " . . . $@ done"

$(MODRULE)clean_dist: $(MODPATH) clean_dist_$(MODDEP)
	$(AT)echo " . . . $@ done"

.INTERMEDIATE: $(MODRULE)swig
$(MODPATH)/src/acstimeSWIG_wrap.cpp $(MODPATH)/src/acstimeSWIG.py: $(MODRULE)swig
$(MODRULE)swig: $(MODPATH)/config/acstimeSWIG.i
	$(AT)swig -c++ -python $(MODPATH)/config/acstimeSWIG.i
	$(AT)mv $(MODPATH)/config/acstimeSWIG_wrap.cxx $(MODPATH)/src/acstimeSWIG_wrap.cpp
	$(AT)mv $(MODPATH)/config/acstimeSWIG.py $(MODPATH)/src/acstimeSWIG.py
