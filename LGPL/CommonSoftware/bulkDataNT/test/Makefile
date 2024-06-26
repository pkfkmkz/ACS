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

#MAKE_ONLY=C++ # impl is only for C++, and the same is with tests

#
# user definable C-compilation flags
#USER_CFLAGS = 


#
# additional include and library search paths
USER_INC = -I$(NDDSHOME)/include -I$(NDDSHOME)/include/ndds
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
EXECUTABLES_L   = bdNTSenderTest bdNTReceiverTest bdNTTEST1 bdNTConfigurationParserTest bdNTReceiverImplClient bdNT32SendersTest bdNTMultiReceiversTest bdNTSenderMLTest

#
# <brief description of xxxxx program>
bdNTSenderTest_OBJECTS= bdNTSenderTest
bdNTSenderTest_LIBS= bulkDataNTSender

bdNTSenderMLTest_OBJECTS= bdNTSenderMLTest
bdNTSenderMLTest_LIBS= bulkDataNTSender


bdNTReceiverTest_OBJECTS=  bdNTReceiverTest
bdNTReceiverTest_LIBS= bulkDataNTReceiver

bdNTConfigurationParserTest_OBJECTS=bdNTConfigurationParserTest
bdNTConfigurationParserTest_LIBS=bulkDataNT

bdNTTEST1_OBJECTS = bdNTTEST1
bdNTTEST1_LIBS = bulkDataReceiverStubs bulkDataSenderStubs maciClient

bdNTReceiverImplClient_OBJECTS= bdNTReceiverImplClient
bdNTReceiverImplClient_LIBS= maciClient bulkDataReceiverStubs

bdNT32SendersTest_OBJECTS = bdNT32SendersTest
bdNT32SendersTest_LIBS = bulkDataNTSender

bdNTMultiReceiversTest_OBJECTS = bdNTMultiReceiversTest
bdNTMultiReceiversTest_LIBS= bulkDataNTReceiver 

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
LIBRARIES_L     = bdNTReceiverLibTest bdNTSenderLibTest bdNTSenderLibTestNew bdNTMasterLibTest
bdNTReceiverLibTest_OBJECTS = bdNTReceiverImplTest
bdNTReceiverLibTest_LIBS = bulkDataNTReceiver bulkDataReceiverStubs baci

bdNTSenderLibTest_OBJECTS = bdNTSenderImplTest
bdNTSenderLibTest_LIBS = bulkDataNTSenderImpl

bdNTSenderLibTestNew_OBJECTS = bdNTSenderImplTestNew
bdNTSenderLibTestNew_LIBS = bulkDataNTSenderImpl

bdNTMasterLibTest_OBJECTS = bdNTMasterImplTest
bdNTMasterLibTest_LIBS = bulkDataNTReceiver bulkDataReceiverStubs bulkDataNTSender baci


#
# <brief description of lllll library>
lllll_OBJECTS   =

#
# Scripts (public and local)
# ----------------------------
SCRIPTS         = 
SCRIPTS_L       = bulkDataNTTATEnv bulkDataNTOneFlowPerformanceTestJava BulkDataNTJavaUnitTest receiverSendNCError.sh

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
JARFILES=jBulkDataTest
jBulkDataTest_DIRS=alma
jBulkDataTest_EXTRAS=
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

ifdef NDDSHOME
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
