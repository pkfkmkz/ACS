#*******************************************************************************
# PPPPPPPP
#
# "@(#) $Id$"
#
# Makefile of ........
#
# who       when      what
# --------  --------  ----------------------------------------------
# danilo.zanella [at] iag.usp.br  16/02/21  created
#

# ALMA - Atacama Large Millimeter Array
# Copyright (c) ESO - European Southern Observatory, 2014
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
# This Makefile follows ALMA/ACS Standards (see Makefile(5) for more).
#*******************************************************************************
# REMARKS
#    None
#------------------------------------------------------------------------

#
# user definable C-compilation flags
#USER_CFLAGS = 

#
# additional include and library search paths
#USER_INC = 
#USER_LIB = 

#
# MODULE CODE DESCRIPTION:
# ------------------------
# As a general rule:  public file are "cleaned" and "installed"  
#                     local (_L) are not "installed".

#
# C programs (public and local)
# -----------------------------
EXECUTABLES     =
EXECUTABLES_L   = 

#
# <brief description of xxxxx program>
xxxxx_OBJECTS   =	
xxxxx_LDFLAGS   =
xxxxx_LIBS      =

#
# special compilation flags for single c sources
#yyyyy_CFLAGS   = 

#
# Includes (.h) files (public only)
# ---------------------------------
INCLUDES        =

#
# Libraries (public and local)
# ----------------------------
LIBRARIES       =
LIBRARIES_L     =

#
# <brief description of lllll library>
lllll_OBJECTS   =

#
# Scripts (public and local)
# ----------------------------
SCRIPTS         =
SCRIPTS_L       =

#
# TCL scripts (public and local)
# ------------------------------
TCL_SCRIPTS     =
TCL_SCRIPTS_L   =

#
# Python stuff (public and local)
# ----------------------------
PY_SCRIPTS         =
PY_SCRIPTS_L       =

PY_MODULES         =
PY_MODULES_L       =

PY_PACKAGES        =
PY_PACKAGES_L      =
pppppp_MODULES	   =

#
# <brief description of tttttt tcl-script>
tttttt_OBJECTS  =
tttttt_TCLSH    = 
tttttt_LIBS     = 

#
# TCL libraries (public and local)
# ------------------------------
TCL_LIBRARIES   =
TCL_LIBRARIES_L =

#
# <brief description of tttlll library>
tttlll_OBJECTS  = 

#
# Configuration Database Files
# ----------------------------
CDB_SCHEMAS = 

# 
# IDL Files and flags
# 
IDL_FILES =
TAO_IDLFLAGS =
USER_IDL =
#
# Jarfiles and their directories
#
JARFILES= 
jjj_DIRS=
jjj_EXTRAS=
# For expressing dependencies between jarfiles (parallel builds)
jjj_JLIBS= 
#
# java sources in Jarfile on/off
DEBUG= 
#
# ACS XmlIdl generation on/off
#
XML_IDL= 
#
# Java Component Helper Classes generation on/off
#
COMPONENT_HELPERS=
#
# Java Entity Classes generation on/off
#
XSDBIND=
#
# Schema Config files for the above
#
XSDBIND_INCLUDE=
# man pages to be done
# --------------------
MANSECTIONS =
MAN1 =
MAN3 =
MAN5 =
MAN7 =
MAN8 =

#
# local man pages
# ---------------
MANl =

#
# ASCII file to be converted into Framemaker-MIF
# --------------------
ASCII_TO_MIF = 

#
# other files to be installed
#----------------------------
INSTALL_FILES =

#
# list of all possible C-sources (used to create automatic dependencies)
# ------------------------------
CSOURCENAMES = \
	$(foreach exe, $(EXECUTABLES) $(EXECUTABLES_L), $($(exe)_OBJECTS)) \
	$(foreach rtos, $(RTAI_MODULES) , $($(rtos)_OBJECTS)) \
	$(foreach lib, $(LIBRARIES) $(LIBRARIES_L), $($(lib)_OBJECTS))

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
	@echo " . . . 'all' done" 

clean : clean_all 
	@echo " . . . clean done"

clean_dist : clean_all clean_dist_all 
	@echo " . . . clean_dist done"

man   : do_man 
	@echo " . . . man page(s) done"

install : install_all
	@echo " . . . installation done"

DEFAULT_FEATURE_FILE := $(ACE_ROOT)/bin/MakeProjectCreator/config/default.features
QOS_XML_HANDLER_PATCH := $(PWD)/patches/OpenDDS_QOS_XML_Handler.patch

OS := $(shell uname)
ifeq ($(OS),Linux)
	OS_TYPE := linux
endif
NUMPROC := $(shell nproc)

OPENDDS_URL := https://github.com/objectcomputing/OpenDDS.git
OPENDDS_INSTDIR := $(ALMASW_INSTDIR)/OpenDDS
OPENDDS_VERSION := 3.13.2

build_opendds: ace_xml_utils_build $(OPENDDS_INSTDIR)
	@echo "Cloning build tree to $(OPENDDS_INSTDIR)/build/$(OS_TYPE)..."
	@cd $(OPENDDS_INSTDIR); \
		$(ACE_ROOT)/MPC/clone_build_tree.pl -f $(OS_TYPE)
	@echo "Configuring OpenDDS..."
	@cd $(OPENDDS_INSTDIR)/build/$(OS_TYPE); \
		XSC_ROOT=$(ACE_ROOT)/XSC \
		PATH=$(XSC_ROOT)/bin:$(PATH) \
		LD_LIBRARY_PATH=$(XSC_ROOT)/lib:$(LD_LIBRARY_PATH) \
	       	./configure  --xerces3=$(ACSROOT) --boost=$(ALMASW_INSTDIR)/boost --verbose
	@echo "Configuration done!"
	@echo "Building OpenDDS"
	$(MAKE) -C $(OPENDDS_INSTDIR)/build/$(OS_TYPE) -j$(NUMPROC)
	@echo "Compilation done!"
	@echo "Creating link to $(ALMASW_INSTDIR)/DDS"
	@ln -s $(OPENDDS_INSTDIR)/build/$(OS_TYPE) $(ALMASW_INSTDIR)/DDS


$(OPENDDS_INSTDIR):
	@echo "Clonning OpenDDS from $(OPENDDS_URL)"
	@git clone -b DDS-$(OPENDDS_VERSION) $(OPENDDS_URL) $(ALMASW_INSTDIR)/OpenDDS
	@echo "Applying QOS_XML_Handler patch"
	@git am $(QOS_XML_HANDLER_PATCH)


clean_opendds_build:
ifneq ($(wildcard $(OPENDDS_INSTDIR)/build/.),)
	@echo "Removing OpenDDS build directory"
	@rm -r $(OPENDDS_INSTDIR)/build 
endif

clean_opendds:
ifneq ($(wildcard $(OPENDDS_INSTDIR)/.),)
	@echo "Removing OpenDDS directory and link"
	rm -rf $(OPENDDS_INSTDIR)
	rm $(ALMASW_INSTDIR)/DDS
endif

ace_xml_utils_build: build_xsc $(DEFAULT_FEATURE_FILE)
ifneq ($(wildcard $(ACSROOT)/include/xercesc/.),)
	@echo "Rebuilding ACE"
	@cd $(ACE_ROOT); \
		XSC_ROOT=$(ACE_ROOT)/XSC \
		MPC_ROOT=$(ACE_ROOT)/MPC bin/mwc.pl -type gnuace ace/ace.mwc
	XERCESCROOT=$(ACSROOT) \
		    BOOST_ROOT=$(ALMASW_INSTDIR)/boost \
		    XSC_ROOT=$(ACE_ROOT)/XSC \
		    $(MAKE) -C $(ACE_ROOT)/ace
else
	@echo "xerces-c not found in directory $(ACSROOT)/include/xercesc."
endif

$(DEFAUL_FEATURE_FILE): linux/default.features
ifeq ($(OS), Linux)
	@echo "Copying default.features to ACE"
	@cp $< $@
endif


build_xsc: $(ACE_ROOT)/../../XSC
	@echo "Building XSC..."
	@cd $(ACE_ROOT)/XSC; \
		XSC_ROOT=$(ACE_ROOT)/XSC \
		MPC_ROOT=$(ACE_ROOT)/MPC ../bin/mwc.pl -type make XSC.mwc
	XERCESCROOT=$(ACSROOT) BOOST_ROOT=$(ALMASW_INSTDIR)/boost $(MAKE) -C $(ACE_ROOT)/XSC -j$(NUMPROC)

$(ACE_ROOT)/../../XSC:
	@echo "Clonning XSC from DOC Group (https://github.com/DOCGroup)"
	@git clone --depth 1 https://github.com/DOCGroup/XSC.git $(ACE_ROOT)/../../XSC
	@cd $(ACE_ROOT)/../../; MPC_ROOT=$(ACE_ROOT)/MPC; \
		$(ACE_ROOT)/MPC/clone_build_tree.pl
	



#___oOo___
