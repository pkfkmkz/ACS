#*******************************************************************************
# PPPPPPPP
#
# "@(#) $Id: Makefile,v 1.8 2012/10/24 15:00:27 rtobar Exp $"
#
# Makefile of ........
#
# who       when      what
# --------  --------  ----------------------------------------------
# rtobar  02/12/09  created
#

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
JARFILES=cdb_rdb AcsTmcdbUtils

cdb_rdb_DIRS=com alma/TMCDB alma/acs/tmcdb/logic
cdb_rdb_EXTRAS=alma/TMCDB/maci/hibernate-mappings-maci.hbm.xml \
               alma/TMCDB/baci/hibernate-mappings-baci.hbm.xml \
               acsOnly-cdb_rdb-hibernate.cfg.xml
cdb_rdb_JLIBS := TMCDBswconfigStrategy cdbrdb-pojos 
cdb_rdb_EXT_JARS:=hibernate-core hsqldb

AcsTmcdbUtils_DIRS := alma/acs/tmcdb/generated/lrutype alma/acs/tmcdb/utils
AcsTmcdbUtils_JLIBS := cdb_rdb
AcsTmcdbUtils_JARS:=tmcdbGenerator
AcsTmcdbUtils_EXT_JARS:=commons-cli hibernate-core

#
# java sources in Jarfile on/off
DEBUG=on

#
# other files to be installed
#----------------------------
POJOS_JAR = cdbrdb-pojos.jar
INSTALL_FILES = ../lib/$(POJOS_JAR) ../lib/TMCDBswconfigStrategy.jar

DDLDATA=$(ACSDATA)/config/DDL

ANT_OPTS=" -Djavax.xml.parsers.SAXParserFactory=com.sun.org.apache.xerces.internal.jaxp.SAXParserFactoryImpl -Djavax.xml.parsers.DocumentBuilderFactory=com.sun.org.apache.xerces.internal.jaxp.DocumentBuilderFactoryImpl"

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
gen:
	acsStartJava -endorsed org.exolab.castor.builder.SourceGenerator \
            -i ../config/CDB/schemas/LRU.xsd  -package alma.acs.tmcdb.generated.lrutype


all:	gen .done_generating_sql ../lib/TMCDBswconfigStrategy.jar .done_generating_classes ../lib/$(POJOS_JAR) do_all
	@echo " . . . 'all' done" 

clean : clean_all 
	@echo "== Deleting generated code"
	@rm -rf ../config/TMCDB_swconfigcore
	@rm -rf ../config/TMCDB_swconfigext
	@rm -rf alma/acs/tmcdb/generated
	@rm -rf tmcdb
	@rm -rf gen
	@rm -f .done_generating_sql
	@rm -f .done_generating_classes
	@rm -f CreateHsqldbTables.sql
	@rm -f alma/acs/tmcdb/translator/Column2Attribute_*
	@rm -f alma/acs/tmcdb/translator/Table2Class_*
	@rm -f alma/acs/tmcdb/translator/TableInheritance_*
	@rm -f alma/acs/tmcdb/translator/*.class
	@rm -f ../lib/$(POJOS_JAR)
	@rm -f ../lib/cdbrdb-helper-pojos.jar
	@rm -f ../lib/TMCDBswconfigStrategy.jar
	@echo " . . . clean done"

clean_dist : clean_all clean_dist_all 
	@echo " . . . clean_dist done"

man   : do_man 
	@echo " . . . man page(s) done"

install : install_all
	@mkdir -p $(DDLDATA)/generic
	@mkdir -p $(DDLDATA)/oracle/TMCDB_swconfigcore
	@mkdir -p $(DDLDATA)/oracle/TMCDB_swconfigext
	@mkdir -p $(DDLDATA)/hsqldb/TMCDB_swconfigcore
	@mkdir -p $(DDLDATA)/hsqldb/TMCDB_swconfigext
	@mkdir -p $(DDLDATA)/mysql/TMCDB_swconfigcore
	@mkdir -p $(DDLDATA)/mysql/TMCDB_swconfigext
	@echo "== Copying generic .ddl files to $(DDLDATA)/generic"
	@cp generic/TMCDB_swconfigcore.ddl $(DDLDATA)/generic
	@cp generic/TMCDB_swconfigext.ddl $(DDLDATA)/generic
	@echo "== Copying generated Oracle .sql files to $(DDLDATA)/oracle"
	@cp ../config/TMCDB_swconfigcore/oracle/* $(DDLDATA)/oracle/TMCDB_swconfigcore
	@cp ../config/TMCDB_swconfigext/oracle/* $(DDLDATA)/oracle/TMCDB_swconfigext
	@echo "== Copying generated HSQLDB .sql files to $(DDLDATA)/hsqldb"
	@cp ../config/TMCDB_swconfigcore/hsqldb/* $(DDLDATA)/hsqldb/TMCDB_swconfigcore
	@cp ../config/TMCDB_swconfigext/hsqldb/* $(DDLDATA)/hsqldb/TMCDB_swconfigext
	@echo "== Copying generated MySQL .sql files to $(DDLDATA)/mysql"
	@cp ../config/TMCDB_swconfigcore/mysql/* $(DDLDATA)/mysql/TMCDB_swconfigcore
	@cp ../config/TMCDB_swconfigext/mysql/* $(DDLDATA)/mysql/TMCDB_swconfigext
	@echo " . . . installation done"

.done_generating_sql : generic/TMCDB_swconfigcore.ddl generic/TMCDB_swconfigext.ddl
	@echo "=="
	@echo "== Generating SQL code"
	@echo "=="
	@generateTmcdbSchemas generic/TMCDB_swconfigcore.ddl ../config
	@generateTmcdbSchemas generic/TMCDB_swconfigext.ddl ../config
	@echo "=="
	@echo "== Generating SQL/Java translation code"
	@echo "=="
	@generateTmcdbHibernateStrategy generic/TMCDB_swconfigcore.ddl .
	@generateTmcdbHibernateStrategy generic/TMCDB_swconfigext.ddl .
	@touch .done_generating_sql

.done_generating_classes: ../lib/TMCDBswconfigStrategy.jar ../lib/cdbrdb-helper-pojos.jar
	@echo "=="
	@echo "== Generating Java domain classes"
	@echo "=="
	@-rm -rf tmcdb
	@-mkdir tmcdb
	@rm -f CreateHsqldbTables.sql
	@cat ../config/TMCDB_swconfigcore/hsqldb/CreateHsqldbTables.sql ../config/TMCDB_swconfigext/hsqldb/CreateHsqldbTables.sql > CreateHsqldbTables.sql
	@acsStartJava org.hsqldb.cmdline.SqlTool --rcFile sqltool.rc tmcdb CreateHsqldbTables.sql
	@CLASSPATH="$(shell acsMakeJavaClasspath)" ANT_OPTS=$(ANT_OPTS) ant -verbose generate
	echo "Java domain classes generated"
	@touch .done_generating_classes

../lib/$(POJOS_JAR): .done_generating_classes
	@echo "=="
	@echo "== Compiling generated domain classes"
	@cd gen;\
	    CLASSPATH="$(shell acsMakeJavaClasspath)" javac alma/acs/tmcdb/*.java; \
	    jar cf ../../lib/$(POJOS_JAR) alma/acs/tmcdb/*.class; cd ..; 
	    mv gen src; jar uf ../lib/$(POJOS_JAR) src/alma/acs/tmcdb/*.java; mv src gen/; \
	    jar uf ../lib/$(POJOS_JAR) -C ../config/TMCDB_swconfigcore/ SwCore-orm.xml; \
	    jar uf ../lib/$(POJOS_JAR) -C ../config/TMCDB_swconfigext/ SwExt-orm.xml;

$(eval $(call acsMakeMavenPreparations,cdbrdb-pojos))

.INTERMEDIATE: ../cdbrdb-pojos.pom.xml
../cdbrdb-pojos.pom.xml:
	generatePom -g $(cdbrdb-pojos_grp_id) -a $(cdbrdb-pojos_art_id) -v $(cdbrdb-pojos_art_ver) -j lib/cdbrdb-pojos.jar $(if $(strip $(cdbrdb-pojos_JARS) $(cdbrdb-pojos_JLIBS) $(cdbrdb-pojos_EXT_JARS)),-d $(subst $(SPACE),$(COMMA),$(sort $(cdbrdb-pojos_JARS) $(cdbrdb-pojos_JLIBS) $(foreach jar,$(sort $(cdbrdb-pojos_EXT_JARS)),$(call get-jar-info,$(jar)))))) -f $@

.PHONY: install_cdbrdb-pojos
install_cdbrdb-pojos: ../cdbrdb-pojos.pom.xml ../lib/$(POJOS_JAR)
	$(AT)mvn -B -f $< install

install: install_cdbrdb-pojos

.PHONY: deploy_cdbrdb-pojos
deploy_cdbrdb-pojos: ../cdbrdb-pojos.pom.xml ../lib/$(POJOS_JAR)
	$(AT)mvn -B -f $< deploy

deploy: deploy_cdbrdb-pojos

../lib/TMCDBswconfigStrategy.jar: .done_generating_sql 
	@echo "== Compiling TMCDBswconfigStrategy.jar "
	@CLASSPATH="$(shell acsMakeJavaClasspath)" javac alma/acs/tmcdb/translator/*.java; jar cf ../lib/TMCDBswconfigStrategy.jar alma/acs/tmcdb/translator/*.class; cd ..; jar uf lib/TMCDBswconfigStrategy.jar src/alma/acs/tmcdb/translator/*.java;
	@rm -f alma/acs/tmcdb/translator/*.class

../lib/cdbrdb-helper-pojos.jar: .done_generating_sql
	@echo "== Compiling temporal cdbrdb-helper-pojos.jar "
	@cd gen; CLASSPATH="$(shell acsMakeJavaClasspath)" javac alma/acs/tmcdb/*.java; jar cf ../../lib/cdbrdb-helper-pojos.jar alma/acs/tmcdb/*.class
	@rm -f gen/alma/acs/tmcdb/*.class

$(eval $(call acsMakeMavenPreparations,TMCDBswconfigStrategy))

.INTERMEDIATE: ../TMCDBswconfigStrategy.pom.xml
../TMCDBswconfigStrategy.pom.xml:
	generatePom -g $(TMCDBswconfigStrategy_grp_id) -a $(TMCDBswconfigStrategy_art_id) -v $(TMCDBswconfigStrategy_art_ver) -j lib/TMCDBswconfigStrategy.jar $(if $(strip $(TMCDBswconfigStrategy_JARS) $(TMCDBswconfigStrategy_JLIBS) $(TMCDBswconfigStrategy_EXT_JARS)),-d $(subst $(SPACE),$(COMMA),$(sort $(TMCDBswconfigStrategy_JARS) $(TMCDBswconfigStrategy_JLIBS) $(foreach jar,$(sort $(TMCDBswconfigStrategy_EXT_JARS)),$(call get-jar-info,$(jar)))))) -f $@

.PHONY: install_TMCDBswconfigStrategy
install_TMCDBswconfigStrategy: ../TMCDBswconfigStrategy.pom.xml ../lib/TMCDBswconfigStrategy.jar
	$(AT)mvn -B -f $< install

install: install_TMCDBswconfigStrategy

.PHONY: deploy_TMCDBswconfigStrategy
deploy_TMCDBswconfigStrategy: ../TMCDBswconfigStrategy.pom.xml ../lib/TMCDBswconfigStrategy.jar
	$(AT)mvn -B -f $< deploy

deploy: deploy_TMCDBswconfigStrategy
