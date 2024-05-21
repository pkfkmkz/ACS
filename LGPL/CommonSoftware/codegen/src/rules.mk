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
# Scripts (public and local)
# ----------------------------
SCRIPTS         = generateTmcdbSchemas generateTmcdbHibernateStrategy generateStateMachines
SCRIPTS_L       =


#
# Jarfiles and their directories
#
JARFILES=acscodegen tmcdbGenerator
acscodegen_DIRS=alma/acs/genfw/
acscodegen_EXTRAS=
acscodegen_JARS=acsjlog
tmcdbGenerator_DIRS=alma/acs/tmcdb/translator
tmcdbGenerator_EXTRAS=alma/acs/tmcdb/generator
tmcdbGenerator_EXT_JARS=hibernate-core hibernate-tools-orm

#
# java sources in Jarfile on/off
DEBUG=on
