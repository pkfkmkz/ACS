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
# This Makefile follows VLT Standards (see Makefile(5) for more).
#*******************************************************************************
# REMARKS
#    None
#-------------------------------------------------------------------------------
-include $(MODPATH)/src/rules.mk

$(MODRULE)all: $(MODRULE)prepare_xsdbind $(MODPATH) $(MODDEP)
	$(AT)echo " . . . $@ done"

$(MODRULE)install: $(MODPATH) install_$(MODDEP)
	$(AT)echo " . . . $@ done"

$(MODRULE)clean: $(MODRULE)clean_my_xsdbind $(MODPATH) clean_$(MODDEP)
	$(AT)echo " . . . $@ done"

$(MODRULE)clean_dist: $(MODPATH) clean_dist_$(MODDEP)
	$(AT)echo " . . . $@ done"

.PHONY: $(MODRULE)prepare_xsdbind
$(MODRULE)prepare_xsdbind: $(MODPATH)/config/CDB/schemas/xml.xsd
$(MODPATH)/config/CDB/schemas/xml.xsd: $(ACSROOT)/config/CDB/schemas/xml.xsd
	$(AT)echo " copying xml.xsd from ACSROOT, because we can't create binding classes up in ACS/LGPL/Tools/xercesj where this file comes from"
	$(AT)cp -a $(ACSROOT)/config/CDB/schemas/xml.xsd $(MODPATH)/config/CDB/schemas/

$(MODRULE)clean_my_xsdbind:
	$(AT)echo " will remove schema files copied for XSDBIND workaround . . ."
	$(AT)rm -f $(MODPATH)/config/CDB/schemas/xml.xsd
