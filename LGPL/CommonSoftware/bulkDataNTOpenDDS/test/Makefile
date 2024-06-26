#*******************************************************************************
# ALMA - Atacama Large Millimiter Array
# (c) European Southern Observatory, 2011 
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
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
# "@(#) $Id: Makefile,v 1.21 2013/02/06 13:49:08 bjeram Exp $"
#
# Makefile of ........
#
# who       when      what
# --------  --------  ----------------------------------------------
# bjeram  2011-07-05  created
#

#*******************************************************************************
# This Makefile follows VLT Standards (see Makefile(5) for more).
#*******************************************************************************
# REMARKS
#    None
#------------------------------------------------------------------------
USE_OPENDDS = 1

#MAKE_ONLY=C++ # impl is only for C++, and the same is with tests

#
# user definable C-compilation flags
USER_CFLAGS = -g


#
# additional include and library search paths
#USER_INC = -I$(NDDSHOME)/include -I$(NDDSHOME)/include/ndds
USER_INC = -I$(DDS_ROOT)
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
EXECUTABLES_L   = bdOpenDDSSenderTest bdOpenDDSReceiverTest bdOpenDDSTEST1 bdOpenDDSConfigurationParserTest bdOpenDDSReceiverImplClient bdOpenDDS32SendersTest bdOpenDDSMultiReceiversTest bdOpenDDSSenderMLTest

#
# <brief description of xxxxx program>
bdOpenDDSSenderTest_OBJECTS= bdOpenDDSSenderTest
bdOpenDDSSenderTest_LIBS= bulkDataOpenDDSSender

bdOpenDDSSenderMLTest_OBJECTS= bdOpenDDSSenderMLTest
bdOpenDDSSenderMLTest_LIBS= bulkDataNTSender OpenDDS_Dcps


bdOpenDDSReceiverTest_OBJECTS=  bdOpenDDSReceiverTest
bdOpenDDSReceiverTest_LIBS= bulkDataNTReceiver OpenDDS_Dcps

bdOpenDDSConfigurationParserTest_OBJECTS=bdOpenDDSConfigurationParserTest
bdOpenDDSConfigurationParserTest_LIBS=bulkDataNT OpenDDS_Dcps

bdOpenDDSTEST1_OBJECTS = bdOpenDDSTEST1
bdOpenDDSTEST1_LIBS = bulkDataReceiverStubs bulkDataSenderStubs maciClient

bdOpenDDSReceiverImplClient_OBJECTS= bdOpenDDSReceiverImplClient
bdOpenDDSReceiverImplClient_LIBS= maciClient bulkDataReceiverStubs

bdOpenDDS32SendersTest_OBJECTS = bdOpenDDS32SendersTest
bdOpenDDS32SendersTest_LIBS = bulkDataNTSender OpenDDS_Dcps

bdOpenDDSMultiReceiversTest_OBJECTS = bdOpenDDSMultiReceiversTest
bdOpenDDSMultiReceiversTest_LIBS= bulkDataNTReceiver OpenDDS_Dcps

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
LIBRARIES_L     = bdOpenDDSReceiverLibTest bdOpenDDSSenderLibTest bdOpenDDSSenderLibTestNew bdOpenDDSMasterLibTest
bdOpenDDSReceiverLibTest_OBJECTS = bdOpenDDSReceiverImplTest
bdOpenDDSReceiverLibTest_LIBS = bulkDataOpenDDSReceiver bulkDataReceiverStubs baci

bdOpenDDSSenderLibTest_OBJECTS = bdOpenDDSSenderImplTest
bdOpenDDSSenderLibTest_LIBS = bulkDataOpenDDSSenderImpl

bdOpenDDSSenderLibTestNew_OBJECTS = bdOpenDDSSenderImplTestNew
bdOpenDDSSenderLibTestNew_LIBS = bulkDataOpenDDSSenderImpl

bdOpenDDSMasterLibTest_OBJECTS = bdOpenDDSMasterImplTest
bdOpenDDSMasterLibTest_LIBS = bulkDataOpenDDSReceiver bulkDataReceiverStubs bulkDataNTSender baci


#
# <brief description of lllll library>
lllll_OBJECTS   =

#
# Scripts (public and local)
# ----------------------------
SCRIPTS         = 
SCRIPTS_L       = bulkDataOpenDDSTATEnv bulkDataOpenDDSOneFlowPerformanceTestJava BulkDataNTJavaUnitTest receiverSendNCError.sh

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
#JARFILES=jBulkDataTest
#jBulkDataTest_DIRS=alma
#jBulkDataTest_EXTRAS=
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

ifdef DDS_ROOT
all:	do_all
	@mkdir -p tmp
	@echo " . . . 'all' done" 
else
.DEFAULT_GOAL := all	
all: 
	@echo -e "\e[0;31mWARNING:  NDDSHOME not defined nothing to be done for target: all!\e[0m" 
 
test: 
	@echo -e "\e[0;31mWARNING:  NDDSHOME not defined nothing to be done for target: test!\e[0m" 
endif

clean : clean_all 
	@rm -rf tmp
	@echo " . . . clean done"

clean_dist : clean_all clean_dist_all 
	@rm -rf tatlogs
	@echo " . . . clean_dist done"

man   : do_man 
	@echo " . . . man page(s) done"

install : install_all
	@echo " . . . installation done"


#___oOo___
