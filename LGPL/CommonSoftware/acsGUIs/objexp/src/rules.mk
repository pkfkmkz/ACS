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
# Java code
# ------------------------------
JARFILES = oe
# reverted to previous acs Makefile
# following line to be used in the future
oe_DIRS = si
oe_EXTRAS = device.gif domain.gif invocation.gif property.gif type.gif
oe_JLIBS=objexpErrType
oe_JARS:=acsGUIutil objexpErrType
oe_EXT_JARS:=jchart2d

ACSERRDEF = objexpErrType

#
# Scripts (public and local)
# ----------------------------
SCRIPTS         = objexp objexpNonSticky objexpSticky
SCRIPTS_L       =

#
# other files to be installed
#----------------------------
INSTALL_FILES =
