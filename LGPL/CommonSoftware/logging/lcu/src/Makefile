#*******************************************************************************
# ALMA - Atacama Large Millimiter Array
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
# "@(#) $Id: Makefile,v 1.47 2010/10/28 06:49:45 bjeram Exp $" 
#
# Makefile of logging
#
# who       when      what
# --------  --------  ----------------------------------------------
# bgustafs 2001-07-12 modified for loggint 1.13, no debug
# almamgr 2000-09-26 created
#

#*******************************************************************************
# This Makefile follows VLT Standards (see Makefile(5) for more).
#*******************************************************************************
# REMARKS
#    None
#------------------------------------------------------------------------

OPTIMIZE=0

#USER_INC =

# Program to build
# Can be overwritten in the call

PROG = 
#USER_CFLAGS = -frepo 
#-fno-implicit-templates


#
# additional include and library search paths
#USER_LIB = 

#
# MODULE CODE DESCRIPTION:
# ------------------------
# As a general rule:  public file are "cleaned" and "installed"  
#                     local (_L) are not "installed".

#
# C programs (public and local)
# -----------------------------
EXECUTABLES     = loggingService

EXECUTABLES_L   = 

#
# <brief description of xxxxx program>

loggingService_OBJECTS   = logging loggingLocalSyslog loggingRemoteSyslog loggingLocalFile \
                           loggingLoggingTSSStorage loggingLogLevelDefinition loggingLoggingProxy  \
			   loggingACSLogger  loggingLogSvcHandler \
                           loggingLoggable \
			   loggingBaseLog loggingHandler loggingLogger loggingLogTrace loggingGetLogger loggingGenericLogger loggingStdoutHandler \
			   loggingLogThrottle loggingStopWatch loggingStatistics
#
# special compilation flags for single c sources
#yyyyy_CFLAGS   = 

#
# Includes (.h) files (public and local)
# ---------------------------------
INCLUDES        = 
INCLUDES_L      = 
#
# Libraries (public and local)
# ----------------------------
LIBRARIES       =
LIBRARIES_L     =

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
# list of all possible C-sources (used to create automatic dependencies)
# ------------------------------
CSOURCENAMES = \
	$(foreach exe, $(EXECUTABLES) $(EXECUTABLES_L), $($(exe)_OBJECTS)) \
	$(foreach lib, $(LIBRARIES) $(LIBRARIES_L), $($(lib)_OBJECTS))

#
#>>>>> END OF standard rules

#
# CHOSE PLATFORM
# --------------
# Default is UNIX, for VxVorks application next line MUST BE UNCOMMENTED
MAKE_VXWORKS = on   

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
all:	 do_all
	@echo " . . . 'all' done" 

clean :  clean_all 
	$(RM) *~ ../include/*~ ../dbl/*~ ../idl/*~ ../*~ core
	@echo " . . . clean done"

man   : do_man 
	@echo " . . . man page(s) done"

install : install_all
	@echo " . . . installation done"

#
# handle links to common source files (in slx/ws/src)
#
COMMON_SOURCES = \
	$(foreach exe, $(loggingService_OBJECTS), $(exe).cpp)
COMMON_SOURCES_ORIG = \
	$(foreach exe, $(loggingService_OBJECTS), ../../ws/src/$(exe).cpp)

$(COMMON_SOURCES) : $(COMMON_SOURCES_ORIG)
	- $(AT) if [ ! -h $@ ]; then echo "== Linking source: $@"; ln -s ../../ws/src/$@ $@; fi

: $(COMMON_SOURCES)

:
	$(AT) $(RM) $(COMMON_SOURCES)

#___oOo___
