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

#
# 3rd party Install files
#
INSTALL_FILES:=

#
# Jarfiles and their directories
#
DEBUG:=on

JARFILES:=jACSUtil
jACSUtil_DIRS:=com alma
jACSUtil_EXTRAS:=alma/acs/jhelpgen/content/*.gif alma/acs/classloading/*.txt
jACSUtil_EXT_JARS:=commons-lang3 hibernate-core jhall junit

#
# Scripts (public and local)
# ----------------------------
SCRIPTS:=acsExtractJavaSources acsJarPackageInfo acsJarsearch acsJarSignInfo acsJarUnsign acsJavaHelp
