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

PY_SCRIPTS  = ACSPyConsole ACSStartContainerPy
PY_PACKAGES = Acspy acs
Acspy_PKGS=ACS Acsalarmpy acscommon AcsContainerLogLTS ACSErr ACSErrTypeCommonImpl ACSErrTypeOKImpl acsnc acsnc__POA AcsNCTraceLogLTS ACS__POA AcsutilPy cdbErrType Logging Logging__POA maci maciErrType maciErrTypeImpl maci__POA NotifyExt NotifyMonitoringExt
acs_EXT_PKGS=redis tornado simplejson

SCRIPTS   = acspyInteractiveContainer acsLoggingMonitor
SCRIPTS_L = 

# 
# IDL Files and flags
# 
IDL_FILES = 
IDL_TAO_FLAGS =
USER_IDL =

CDB_SCHEMAS := ComponentCallerAPI EventConverter

#
# other files to be installed
#----------------------------
INSTALL_FILES =
