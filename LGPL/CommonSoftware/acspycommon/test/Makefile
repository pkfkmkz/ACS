#*******************************************************************************
# ALMA - Atacama Large Millimiter Array
# (c) Associated Universities Inc., 2002 
# (c) European Southern Observatory, 2002
# Copyright by ESO (in the framework of the ALMA collaboration)
# and Cosylab 2002, All rights reserved
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
# "@(#) $Id: Makefile,v 1.1.1.1 2012/03/07 17:40:45 acaproni Exp $"
#
# Makefile of ........
#
# who       when      what
# --------  --------  ----------------------------------------------
# gchiozzi  11/02/02  created
#

#*******************************************************************************
# This Makefile follows VLT Standards (see Makefile(5) for more).
#*******************************************************************************
# REMARKS
#    None
#------------------------------------------------------------------------

PY_SCRIPTS_L =	acspyTestUnitTimeHelper \
		acspyTestUnitCDBAccess \
		acspyTestUnitACSHandler \
		acspyTestAcsCORBA \
		acspyTestCallbacks \
		acspyTestCDB \
		acspyTestError \
		acspyTestLogging \
		acspyTestLoggingStatistics \
		acspyTestNameTree \
		acspyTestTimehelper \
		acspyTestEpochHelper \
		acspyTestDurationHelper 

PY_PACKAGES = 

PY_PACKAGES_L = 

SCRIPTS_L = acspycommonTATPrologue acspyTestLoggingStatistics.sh


#
# other files to be installed
#----------------------------
INSTALL_FILES =

IDL_FILES = 
acspytestStubs_LIBS = 
acspyTestQoSStubs_LIBS = 

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
all:	do_all
	@mkdir -p tmp
	@echo " . . . 'all' done" 

clean : clean_all 
	$(RM) tatlogs
	$(RM) tmp
	@echo " . . . clean done"

clean_dist : clean_all clean_dist_all 
	@echo " . . . clean_dist done"

man   : do_man 
	@echo " . . . man page(s) done"

install : install_all
	@echo " . . . installation done"

#___oOo___
