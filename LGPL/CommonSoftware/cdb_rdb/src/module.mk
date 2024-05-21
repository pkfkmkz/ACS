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
SCRIPTS         = hibernateCdbJDal MonitoringSyncTool
SCRIPTS_L       =

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
# Configuration Database Files
# ----------------------------
CDB_SCHEMAS = ControlDevice

#
# Jarfiles and their directories
#
JARFILES=TMCDBswconfigStrategy cdbrdb-pojos cdb_rdb AcsTmcdbUtils

cdb_rdb_DIRS=com alma/TMCDB alma/acs/tmcdb/logic
cdb_rdb_EXTRAS=alma/TMCDB/maci/hibernate-mappings-maci.hbm.xml \
               alma/TMCDB/baci/hibernate-mappings-baci.hbm.xml \
               acsOnly-cdb_rdb-hibernate.cfg.xml
cdb_rdb_JLIBS := TMCDBswconfigStrategy cdbrdb-pojos 
cdb_rdb_JARS:=slf4j-acs cdbrdb-pojos CDB jacsutil2 tmcdbGenerator
cdb_rdb_EXT_JARS:=hibernate-core hsqldb

AcsTmcdbUtils_DIRS:=alma/acs/tmcdb/generated/lrutype alma/acs/tmcdb/utils
AcsTmcdbUtils_JLIBS:=cdb_rdb
AcsTmcdbUtils_JARS:=tmcdbGenerator
AcsTmcdbUtils_EXT_JARS:=commons-cli hibernate-core

TMCDBswconfigStrategy_DIRS:=alma/acs/tmcdb/translator
#TMCDBswconfigStrategy_DEPS:=$(MODPATH)/src/.done_generating_sql
#TMCDBswconfigStrategy_JARS:=
TMCDBswconfigStrategy_EXT_JARS:=hibernate-tools

cdbrdb-pojos_DIRS=alma/acs/tmcdb
cdbrdb-pojos_EXTRAS=SwCore-orm.xml SwExt-orm.xml
#cdbrdb-pojos_SRC=src/gen
#cdbrdb-pojos_DEPS:=$(MODPATH)/src/.done_generating_classes
cdbrdb-pojos_JARS=
cdbrdb-pojos_EXT_JARS:=hibernate-core javax.persistence-api

#
# java sources in Jarfile on/off
DEBUG=on

#
# other files to be installed
#----------------------------
INSTALL_FILES = ../lib/commons-cli-1.2.jar \
		../lib/jaxb-api-2.3.1.jar ../lib/jaxb-core-2.3.0.1.jar ../lib/jaxb-impl-2.3.2.jar \
		../lib/jaxb-xjc-2.3.2.jar ../lib/pfl-basic-4.0.1.jar

DDLDATA=$(ACSDATA)/config/DDL

$(MODRULE)all: $(MODPATH) $(MODDEP) $(MODPATH)/src/.done_generating_sql $(MODPATH)/src/.done_generating_classes
	$(AT)echo " . . . $@ done"

$(MODRULE)install: $(MODPATH) install_$(MODDEP)
	$(AT)mkdir -p $(DDLDATA)/generic
	$(AT)mkdir -p $(DDLDATA)/oracle/TMCDB_swconfigcore
	$(AT)mkdir -p $(DDLDATA)/oracle/TMCDB_swconfigext
	$(AT)mkdir -p $(DDLDATA)/hsqldb/TMCDB_swconfigcore
	$(AT)mkdir -p $(DDLDATA)/hsqldb/TMCDB_swconfigext
	$(AT)mkdir -p $(DDLDATA)/mysql/TMCDB_swconfigcore
	$(AT)mkdir -p $(DDLDATA)/mysql/TMCDB_swconfigext
	$(AT)echo "== Copying generic .ddl files to $(DDLDATA)/generic"
	$(AT)cp $(MODPATH)/src/generic/TMCDB_swconfigcore.ddl $(DDLDATA)/generic
	$(AT)cp $(MODPATH)/src/generic/TMCDB_swconfigext.ddl $(DDLDATA)/generic
	$(AT)echo "== Copying generated Oracle .sql files to $(DDLDATA)/oracle"
	$(AT)cp $(MODPATH)/config/TMCDB_swconfigcore/oracle/* $(DDLDATA)/oracle/TMCDB_swconfigcore
	$(AT)cp $(MODPATH)/config/TMCDB_swconfigext/oracle/* $(DDLDATA)/oracle/TMCDB_swconfigext
	$(AT)echo "== Copying generated HSQLDB .sql files to $(DDLDATA)/hsqldb"
	$(AT)cp $(MODPATH)/config/TMCDB_swconfigcore/hsqldb/* $(DDLDATA)/hsqldb/TMCDB_swconfigcore
	$(AT)cp $(MODPATH)/config/TMCDB_swconfigext/hsqldb/* $(DDLDATA)/hsqldb/TMCDB_swconfigext
	$(AT)echo "== Copying generated MySQL .sql files to $(DDLDATA)/mysql"
	$(AT)cp $(MODPATH)/config/TMCDB_swconfigcore/mysql/* $(DDLDATA)/mysql/TMCDB_swconfigcore
	$(AT)cp $(MODPATH)/config/TMCDB_swconfigext/mysql/* $(DDLDATA)/mysql/TMCDB_swconfigext
	$(AT)echo " . . . $@ done"

$(MODRULE)clean: $(MODPATH) clean_$(MODDEP)
	$(AT)echo "== Deleting generated code"
	$(AT)rm -rf $(MODPATH)/config/TMCDB_swconfigcore
	$(AT)rm -rf $(MODPATH)/config/TMCDB_swconfigext
	$(AT)rm -rf $(MODPATH)/src/alma/acs/tmcdb/generated
	$(AT)rm -rf $(MODPATH)/src/tmcdb
	$(AT)rm -rf $(MODPATH)/src/gen
	$(AT)rm -f $(MODPATH)/src/.done_generating_sql
	$(AT)rm -f $(MODPATH)/src/.done_generating_classes
	$(AT)rm -f $(MODPATH)/src/CreateHsqldbTables.sql
	$(AT)rm -f $(MODPATH)/src/alma/acs/tmcdb/translator/Column2Attribute_*
	$(AT)rm -f $(MODPATH)/src/alma/acs/tmcdb/translator/Table2Class_*
	$(AT)rm -f $(MODPATH)/src/alma/acs/tmcdb/translator/TableInheritance_*
	$(AT)rm -f $(MODPATH)/src/alma/acs/tmcdb/translator/*.class
	$(AT)echo " . . . $@ done"

$(MODRULE)clean_dist: $(MODPATH) clean_dist_$(MODDEP)
	$(AT)echo " . . . $@ done"

$(MODPATH)/src/alma/acs/tmcdb/generated/lrutype: $(MODPATH)/src/alma/acs/tmcdb/generated/lrutype/LruType.java

$(MODPATH)/src/alma/acs/tmcdb/generated/lrutype/LruType.java: $(MODPATH)/config/CDB/schemas/LRU.xsd
	PATH=$(dir $(call findDep,acsStartJava,script,bin,0)):$(PATH) acsStartJava -endorsed -jarpath $(dir $(call findDep,jACSUtil.jar,jar,lib,0,lib))$(PATH_SEP)$(dir $(call findDep,acsjlog.jar,jar,lib,0)) org.exolab.castor.builder.SourceGenerator -i $(MODPATH)/config/CDB/schemas/LRU.xsd -package alma.acs.tmcdb.generated.lrutype -dest $(MODPATH)/src

$(MODPATH)/src/.done_generating_sql : $(MODPATH)/src/generic/TMCDB_swconfigcore.ddl $(MODPATH)/src/generic/TMCDB_swconfigext.ddl
	$(AT)echo "=="
	$(AT)echo "== Generating SQL code"
	$(AT)echo "=="
	$(AT)PATH=$(dir $(call findDep,acsStartJava,script,bin,0)):$(PATH) $(call findDep,generateTmcdbSchemas,script,bin,0) $(MODPATH)/src/generic/TMCDB_swconfigcore.ddl $(MODPATH)/config $(dir $(call findDep,jACSUtil.jar,jar,lib,0))$(PATH_SEP)$(dir $(call findDep,acsjlog.jar,jar,lib,0))$(PATH_SEP)$(dir $(call findDep,tmcdbGenerator.jar,jar,lib,0))
	$(AT)PATH=$(dir $(call findDep,acsStartJava,script,bin,0)):$(PATH) $(call findDep,generateTmcdbSchemas,script,bin,0) $(MODPATH)/src/generic/TMCDB_swconfigext.ddl $(MODPATH)/config $(dir $(call findDep,jACSUtil.jar,jar,lib,0))$(PATH_SEP)$(dir $(call findDep,acsjlog.jar,jar,lib,0))$(PATH_SEP)$(dir $(call findDep,tmcdbGenerator.jar,jar,lib,0))
	$(AT)echo "=="
	$(AT)echo "== Generating SQL/Java translation code"
	$(AT)echo "=="
	$(AT)PATH=$(dir $(call findDep,acsStartJava,script,bin,0)):$(PATH) $(call findDep,generateTmcdbHibernateStrategy,script,bin,0) $(MODPATH)/src/generic/TMCDB_swconfigcore.ddl $(MODPATH)/src $(dir $(call findDep,jACSUtil.jar,jar,lib,0))$(PATH_SEP)$(dir $(call findDep,acsjlog.jar,jar,lib,0))$(PATH_SEP)$(dir $(call findDep,tmcdbGenerator.jar,jar,lib,0))
	$(AT)PATH=$(dir $(call findDep,acsStartJava,script,bin,0)):$(PATH) $(call findDep,generateTmcdbHibernateStrategy,script,bin,0) $(MODPATH)/src/generic/TMCDB_swconfigext.ddl $(MODPATH)/src $(dir $(call findDep,jACSUtil.jar,jar,lib,0))$(PATH_SEP)$(dir $(call findDep,acsjlog.jar,jar,lib,0))$(PATH_SEP)$(dir $(call findDep,tmcdbGenerator.jar,jar,lib,0))
	$(AT)touch $(MODPATH)/src/.done_generating_sql

$(MODPATH)/src/.done_generating_classes: $(MODPATH)/lib/TMCDBswconfigStrategy.jar
	$(AT)echo "=="
	$(AT)echo "== Generating Java domain classes"
	$(AT)echo "=="
	$(AT)rm -rf $(MODPATH)/src/tmcdb
	$(AT)mkdir $(MODPATH)/src/tmcdb
	$(AT)rm -f CreateHsqldbTables.sql
	$(AT)cat $(MODPATH)/config/TMCDB_swconfigcore/hsqldb/CreateHsqldbTables.sql $(MODPATH)/config/TMCDB_swconfigext/hsqldb/CreateHsqldbTables.sql > $(MODPATH)/src/CreateHsqldbTables.sql
	$(AT)acsStartJava --addToClasspath $(call findDep,jACSUtil.jar,jar,lib,0,lib) org.hsqldb.cmdline.SqlTool --rcFile sqltool.rc $(MODPATH)/src/tmcdb $(MODPATH)/src/CreateHsqldbTables.sql
	$(AT)CLASSPATH="$(shell acsMakeJavaClasspath)" ant -verbose generate
	$(AT)cp $(MODPATH)/config/TMCDB_swconfigcore/SwCore-orm.xml $(MODPATH)/src/gen
	$(AT)cp $(MODPATH)/config/TMCDB_swconfigcore/SwCore-ext.xml $(MODPATH)/src/gen
	$(AT)echo "Java domain classes generated"
	$(AT)touch $(MODPATH)/src/.done_generating_classes
