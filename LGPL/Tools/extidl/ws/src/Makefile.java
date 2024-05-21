#*******************************************************************************
# PPPPPPPP
#
# "@(#) $Id: Makefile.java,v 1.11 2010/08/10 06:59:47 mzampare Exp $"
#
# Makefile of ........
#
# who       when      what
# --------  --------  ----------------------------------------------
# bjeram  17/04/08  created
#

# REMARKS
#    Here we generate stubs and skelts for Java only 
#------------------------------------------------------------------------

MAKE_NOIFR_CHECK = on # jagonzal: there is a cyclic dependency between acsstartupIrFeed and acsstartupLoadIFR (checker)

MAKE_ONLY=Java
DEBUG=on
# 
# IDL Files and flags
# 
IDL_TO_INSTALL=NotificationServiceMC NotifyExt 
IDL_FILES_L = Monitor_Types Monitor $(IDL_TO_INSTALL) NotifyMonitoringExt

#IDL_FILES =  NotifyExt 
#IDL_FILES_L = NotificationServiceMC  NotifyMonitoringExt

TAO_IDLFLAGS =
# USER_IDL is defined in top Makefile, so it has to be commented here !!
#USER_IDL =


#
# INCLUDE STANDARDS
# -----------------

MAKEDIRTMP := $(shell searchFile include/acsMakefile)
ifneq ($(MAKEDIRTMP),\#error\#)
   MAKEDIR := $(MAKEDIRTMP)/include
   include $(MAKEDIR)/acsMakefile
endif

define extidlMavenDeploy

$(eval $(call acsMakeMavenPreparations,$1))

.INTERMEDIATE: $(CURDIR)/../$1.pom.xml
$(CURDIR)/../$1.pom.xml:
	$(AT)generatePom -g $($1_grp_id) -a $($1_art_id) -v $($1_art_ver) -j lib/$1.jar $(if $(strip $($1_JARS) $($1_JLIBS) $($1_EXT_JARS)),-d $(subst $(SPACE),$(COMMA),$(sort $($1_JARS) $($1_JLIBS) $(foreach jar,$(sort $($1_EXT_JARS)),$(call get-jar-info,$(jar)))))) -f ../$1.pom.xml

.PHONY: install_extidl_$1
install_extidl_$1: $(CURDIR)/../$1.pom.xml $(CURDIR)/../lib/$1.jar
	$(AT)mvn -B -f $$< install -DskipTests

.PHONY: deploy_extidl_$1
deploy_extidl_$1: $(CURDIR)/../$1.pom.xml $(CURDIR)/../lib/$1.jar
	$(AT)mvn -B -f $$< deploy -DskipTests

endef

$(foreach art,$(IDL_FILES_L),$(eval $(call extidlMavenDeploy,$(art))))

#
# TARGETS
# -------
.NOTPARALLEL: all
all:	do_all
	@echo " . . . 'all' done" 

clean : clean_all 
	@echo " . . . clean done"

clean_dist : clean_all clean_dist_all 
	@echo " . . . clean_dist done"

man   : do_man 
	@echo " . . . man page(s) done"

install : install_all $(addprefix install_extidl_,$(IDL_FILES_L))
	# line below is superfluous with new acsMakefile
	# but will be needed as long as the old one is in use
	@cp $(foreach idl,$(IDL_TO_INSTALL),../idl/$(idl).idl) $(PRJTOP)/idl
	@cp $(foreach jar,$(IDL_FILES_L),../lib/$(jar).jar) $(PRJTOP)/lib

	@echo " . . . installation done"

deploy: deploy_all $(addprefix deploy_extidl_,$(IDL_FILES_L))

#___oOo___
