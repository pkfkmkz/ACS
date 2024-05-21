#*******************************************************************************
# ALMA - Atacama Large Millimiter Array
# (c) European Southern Observatory, 2002
# Copyright by ESO (in the framework of the ALMA collaboration),
# All rights reserved
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, 
# MA 02111-1307  USA

#*******************************************************************************
# This Makefile follows ACS Standards (see Makefile(5) for more).
#*******************************************************************************
# REMARKS
#    None
#------------------------------------------------------------------------

-include $(MODPATH)/src/rules.mk


$(MODRULE)all: $(MODRULE)gen $(MODPATH) $(MODDEP)
	$(AT)echo " . . . $@ done"

$(MODRULE)install: $(MODPATH) install_$(MODDEP)
	$(AT)echo " . . . $@ done"

$(MODRULE)clean: $(MODRULE)clean_gen $(MODPATH) clean_$(MODDEP)
	$(AT)echo " . . . $@ done"

$(MODRULE)clean_dist: $(MODPATH) clean_dist_$(MODDEP)
	$(AT)echo " . . . $@ done"

.INTERMEDIATE: $(MODRULE)gen
$(MODRULE)gen: $(MODPATH)/src/alma/tools/entitybuilder/jaxb/generated/EntitybuilderSettings.java

$(MODRULE)clean_gen:
	@rm -rf $(MODPATH)/src/alma/tools/entitybuilder/jaxb/generated

$(MODPATH)/src/alma/tools/entitybuilder/jaxb/generated/EntitybuilderSettings.java: $(MODPATH)/src/alma/tools/entitybuilder/EntitybuilderSettings.xsd $(MODPATH)/src/alma/tools/entitybuilder/jaxb/bindingschema_2_0.xsd $(MODPATH)/src/alma/tools/entitybuilder/jaxb/catalog.xsd $(MODPATH)/src/entity.xjb $(MODPATH)/src/bind.xjb $(MODPATH)/src/catalog.xjb
	@$(MODPATH)/src/xjc -npa -extension -b $(MODPATH)/src/entity.xjb -d $(MODPATH)/src -p alma.tools.entitybuilder.jaxb.generated $(MODPATH)/src/alma/tools/entitybuilder/EntitybuilderSettings.xsd
	@$(MODPATH)/src/xjc -npa -extension -b $(MODPATH)/src/bind.xjb -d $(MODPATH)/src -p alma.tools.entitybuilder.jaxb.generated.bind $(MODPATH)/src/alma/tools/entitybuilder/jaxb/bindingschema_2_0.xsd
	@$(MODPATH)/src/xjc -npa -extension -b $(MODPATH)/src/catalog.xjb -d $(MODPATH)/src -p alma.tools.entitybuilder.jaxb.generated.catalog $(MODPATH)/src/alma/tools/entitybuilder/jaxb/catalog.xsd
	@rm -f $(MODPATH)/src/alma/tools/entitybuilder/jaxb/generated/ObjectFactory.java
