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
#
# "@(#) $Id$"
#
# Makefile of ........
#
# who       when      what
# --------  --------  ----------------------------------------------
# hsommer  20/01/03  created
#

#*******************************************************************************
# This Makefile follows ACS Standards (see Makefile(5) for more).
#*******************************************************************************
# REMARKS
#    None
#------------------------------------------------------------------------

-include rules.mk

#>>>>> END OF standard rules

XERCES_JARTMP := $(shell searchFile lib/endorsed/xercesImpl-2.12.2-acs.jar)
ifneq ($(XERCES_JARTMP),\#error\#)
   XERCES_JAR := $(XERCES_JARTMP)/lib/endorsed/xercesImpl-2.12.2-acs.jar
endif

CLASSPATH := $(CLASSPATH):$(XERCES_JAR)

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
all:	do_all
	@echo " . . . 'all' done"

clean : clean_all
	@echo " . . . clean done"

clean_dist : clean_all clean_dist_all
	@echo " . . . clean_dist done"

man   : do_man
	@echo " . . . man page(s) done"

install : install_all
	@echo " . . . installation done"

.INTERMEDIATE: gen
gen: alma/tools/entitybuilder/jaxb/generated/EntitybuilderSettings.java

do_all: gen

clean_gen:
	@rm -rf alma/tools/entitybuilder/jaxb/generated

clean_all: clean_gen

alma/tools/entitybuilder/jaxb/generated/EntitybuilderSettings.java: alma/tools/entitybuilder/EntitybuilderSettings.xsd alma/tools/entitybuilder/jaxb/bindingschema_3_0.xsd alma/tools/entitybuilder/jaxb/catalog.xsd entity.xjb bind.xjb catalog.xjb
	@./xjc -npa -extension -b entity.xjb -p alma.tools.entitybuilder.jaxb.generated alma/tools/entitybuilder/EntitybuilderSettings.xsd
	@./xjc -npa -extension -b bind.xjb -p alma.tools.entitybuilder.jaxb.generated.bind alma/tools/entitybuilder/jaxb/bindingschema_3_0.xsd
	@./xjc -npa -extension -b catalog.xjb -p alma.tools.entitybuilder.jaxb.generated.catalog alma/tools/entitybuilder/jaxb/catalog.xsd
	@rm -f alma/tools/entitybuilder/jaxb/generated/ObjectFactory.java
