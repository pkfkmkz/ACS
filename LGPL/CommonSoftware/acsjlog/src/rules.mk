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

DEBUG = on

# 
# IDL Files and flags
# 
IDL_FILES =
IDL_TAO_FLAGS =
USER_IDL =


#
# Jarfiles and their directories
#
JARFILES = acsjlog slf4j-acs

acsjlog_DIRS:=alma
acsjlog_EXTRAS:=almalogging.properties
acsjlog_JARS:=maciSchemaBindings maci cdbDAL repeatGuard
acsjlog_EXT_JARS:=log4j-api log4j-core commons-math3 commons-logging junit castor

slf4j-acs_DIRS:=org
slf4j-acs_JARS:=acsjlog
slf4j-acs_EXT_JARS:=slf4j-api

#
# Scripts (public and local)
# ----------------------------
SCRIPTS         = 
SCRIPTS_L       = 
