#*******************************************************************************
# E.S.O. - ACS project
#
# "@(#) $Id: Makefile,v 1.195 2012/11/16 13:19:32 acaproni Exp $"
#
#

osrev:=$(shell uname -r)
os:=$(shell uname)

###############################################
# Modules in the various ACS sub-packages.    #
###############################################

MODULE_PREFIX = LGPL
#!#MODULES_KIT = vlt doc acs acstempl
MODULES_KIT = doc acs acstempl acsutilpy

MODULES_TOOLS = Tools

MODULES_ACS = jacsutil xmljbind xmlpybind acserridl acsidlcommon acsutil acsstartup loggingidl logging acserr acserrTypes acsQoS acsthread acscomponentidl cdbidl maciidl baciidl acsncidl repeatGuard acsjlog loggingts loggingtsTypes jacsutil2 cdb cdbChecker codegen cdb_rdb acsalarmidl acsalarm acsContainerServices acscomponent recovery basenc archiveevents parameter baci enumprop acscallbacks acsdaemonidl jacsalarm jmanager maci task acstime acsnc acsdaemon acslog acstestcompcpp acsexmpl jlogEngine acspycommon acsalarmpy acspy comphelpgen XmlIdl define acstestentities jcont jcontnc nsStatisticsService jacsalarmtest jcontexmpl jbaci monitoring acssamp mastercomp acspyexmpl nctest acscommandcenter acssim bulkDataNT bulkData containerTests acscourse ACSLaser acsGUIs acsExtras
######## end Modules ###########################

export ACS_DEPLOY_GROUP:=$(if $(ACS_DEPLOY_GROUP),$(ACS_DEPLOY_GROUP),alma.acs)

###############################################
# Macro definitions.                          #
###############################################
define makeIt
    (((/usr/bin/time -f "$1 COMPILATION TIME %E" make $(MAKE_FLAGS) -C $1 $2 2>&1) && (echo "### ==> SUCCEDED" | tee -a $4 >/dev/null)) || (echo "### ==> FAILED $2 ! " | tee -a $3 $4 1>&2 && false)) | tee -a $3 $4 >/dev/null && (exit $${PIPESTATUS[0]}) || RESULT=1;
endef

define makeItAux
    (($(MAKE) $(MAKE_FLAGS) -C $1 $2 2>&1) || (echo "### ==> FAILED $2 ! " | tee -a $3 $4 1>&2 && false)) | tee -a $3 $4 >/dev/null && (exit $${PIPESTATUS[0]}) || RESULT=1;
endef
###############################################

#
# Try to build BENCHMARK modules only if they are part of the distribution 
#
HAS_BENCHMARK = $(shell if [ -d Benchmark ]; then echo "TRUE"; else echo "FALSE"; fi)
ifeq ($(HAS_BENCHMARK),TRUE)
    MODULES_BENCHMARK = util analyzer
endif

#
# Try to build NO-LGPL modules only if they are part of the distribution 
#
MODULE_PREFIX_NO-LGPL = NO-LGPL
HAS_NO-LGPL = $(shell if [ -d NO-LGPL ]; then echo "TRUE"; else echo "FALSE"; fi)

ifeq ($(HAS_NO-LGPL),TRUE)
    MODULES_NO-LGPL = fftw 
endif

VXWORKS_RTOS = $(shell if [ $(WIND_BASE) ] ; then echo "YES"; else echo "NO"; fi)

HAS_VW = $(shell if [ -d NO-LGPL/vw ] ; then echo "TRUE"; else echo "FALSE"; fi)
MODULE_PREFIX_VW = $(MODULE_PREFIX_NO-LGPL)/vw
ifeq ($(VXWORKS_RTOS) $(HAS_VW),YES TRUE)
    MODULES_VW = lcuboot accdb
    ACCDB_CONFIG = accdb_config
endif

MODULES:=$(foreach kit, $(MODULES_KIT), $(MODULE_PREFIX)/Kit/$(kit)) \
         $(foreach tool,$(MODULES_TOOLS), $(MODULE_PREFIX)/$(tool)) \
         $(foreach acs, $(MODULES_ACS), $(MODULE_PREFIX)/CommonSoftware/$(acs)) \
         $(foreach bm, $(MODULES_BENCHMARK), Benchmark/$(bm)) \
         $(foreach nolgpl, $(MODULES_NO-LGPL), $(MODULE_PREFIX_NO-LGPL)/$(nolgpl)) \
         $(MODULES_RTOS) \
         $(addprefix $(MODULE_PREFIX_VW)/, $(MODULES_VW)) \
         $(MODULE_PREFIX)/acsBUILD

#!##
#!## No VLT Central Common Software (CCS) is available.
#!## Some modules in the KIT and TOOLS sub-packages
#!## come from the VLT CCS and use the NOCCS flag to
#!## compile when the core of CCS is not available 
#!##
#!#
#!## Commented out empty MAKE_FLAGS, because it does not work on SUN
#!## MAKE_FLAGS = ""
#!#
#!#ifeq ($(os) $(VXWORKS_RTOS),Linux NO)
#!#    MAKE_FLAGS = "NOCCS=1"
#!#endif

SHELL=/bin/bash
ECHO=echo

ifdef MAKE_VERBOSE
    AT = 
    OUTPUT =
else
    AT = @
    OUTPUT = > /dev/null
endif
#

startupDir = $(shell pwd)


#
#
# what's the intelligence from pkginBuild ?
# you want the four targets: clean, all, install, test
# where test is the most controversial
# FEATURES:
# o   recognize if you live on SunOS
#     and set the compiler accordingly
#     (that's already done at local Makefile level)
# o   turn verbose on and off 
# o   have logging into some well defined place
# o   set specialized variables for CXX/CC/JAVA
#
#
# following example for Workstation
#

#
# This target just forward any make target to all modules
#
define canned
	@$(ECHO) "############ Executing '$@' on all ACS modules #################"
	@for member in $(foreach name, $(MODULES), $(name) ) ; do \
	    $(ECHO) "############ $${member}" ;\
	    if [ ! -d $${member} ]; then \
	        echo "######## ==> $${member} MODULE NOT FOUND! FAILED! " | tee -a build.log;\
	    fi;\
	    if [ -f $${member}/src/Makefile ]; then \
	        $(MAKE) $(MAKE_FLAGS) -C $${member}/src/ $@ || break ;\
	    elif [ -f $${member}/ws/src/Makefile ]; then \
	        $(MAKE) $(MAKE_FLAGS) -C $${member}/ws/src/ $@ || break ;\
	    elif [ -f $${member}/Makefile ]; then \
	        $(MAKE) $(MAKE_FLAGS) -C $${member}/ $@ | tee -a build.log;\
	    fi;\
	    if [ "$(VXWORKS_RTOS)" == "YES" ]; then \
	        if [ -f $${member}/lcu/src/Makefile ]; then \
	            $(MAKE) $(MAKE_FLAGS) -C $${member}/lcu/src/ $@ || break ;\
	        fi;\
	    fi;\
	done
endef

#
# This target builds and installs the complete ACS 
# on a clean directory structure.
# Per each module it executes:
#    make clean all install
#
build: repo-tag clean_log checkModuleTree prepare update
	@$(ECHO) "... done"

#
# This target builds and installs the complete ACS 
# on a clean directory structure.
# Per each module it executes:
#    make clean all man install clean
#
build_clean: repo-tag clean_log checkModuleTree prepare update_clean
	@$(ECHO) "... done"

#
# This target builds and installs the complete ACS 
# on a clean directory structure.
# Per each module it executes:
#    make clean all man install clean
# then, before going to the next module, tries to run the
# modular test.
# This is useful to discover circular dependencies between
# modules.
#
build_clean_test: repo-tag clean_log checkModuleTree prepare update_clean_test
	@$(ECHO) "... done"

#
# This target re-builds and installs the complete ACS 
# on an existing directory structure.
# Per each module it executes:
#    make clean all man install clean
#
rebuild: repo-tag clean_log update
	@$(ECHO) "... done"

clean_log:
	@$(ECHO) "############ Clean Build Log File: build.log #################"
	@rm -f build.log
	@touch build.log

clean_test_log:
	@$(ECHO) "############ Clean Test Log File: test.log #################"
	@rm -f test.log
	@touch test.log

clean_deploy_log:
	@$(ECHO) "############ Clean Deploy Log File: deploy.log #################"
	@rm -f deploy.log
	@touch deploy.log

#
# Check module tree
#
checkModuleTree:	
	@$(ECHO) "############ Check directory tree for modules #################"| tee -a build.log
	@for member in $(foreach name, $(MODULES), $(name) ) ; do \
	    if [ ! -d $${member} ]; then \
	        echo "######## ==> $${member} MODULE NOT FOUND! FAILED! " | tee -a build.log;\
	    fi;\
	    if [ -f $${member}/Makefile ]; then \
	        $(SHELL) $(MODULE_PREFIX)/acsBUILD/src/acsBUILDCheckModuleTree.sh $${member} >> build.log 2>& 1;\
	    fi;\
	    if [ -f $${member}/src/Makefile ]; then \
	        $(SHELL) $(MODULE_PREFIX)/acsBUILD/src/acsBUILDCheckModuleTree.sh $${member} >> build.log 2>& 1;\
	    fi;\
	    if [ -f $${member}/ws/src/Makefile ]; then \
	        $(SHELL) $(MODULE_PREFIX)/acsBUILD/src/acsBUILDCheckModuleTree.sh $${member}/ws >> build.log 2>& 1;\
	    fi;\
	    if [ -f $${member}/lcu/src/Makefile ]; then \
	        $(SHELL) $(MODULE_PREFIX)/acsBUILD/src/acsBUILDCheckModuleTree.sh $${member}/lcu >> build.log 2>& 1;\
	    fi;\
	done

#
# Before being able to cleanly build and install ACS I need to have available
# - the directory tree
#!## - the Kit modules: vlt doc acs acstempl
# - the Kit modules: doc acs acstempl
#   Notice that vlt and doc have a circular dependency
#   and therefore they are built "ad hoc" by the prepare kit script
prepare:	
	@$(ECHO) "############ Prepare installation areas      #################" | tee -a build.log
	@cd $(MODULE_PREFIX); $(SHELL) acsBUILD/src/acsBUILDPrepareKit.sh >> ../build.log 2>& 1
	@$(MAKE) $(MAKE_FLAGS) -C $(MODULE_PREFIX)/Kit/acs/src/ all install clean >> build.log 2>& 1 || echo "### ==> FAILED! " | tee -a build.log
	@$(MAKE) $(MAKE_FLAGS) -C $(MODULE_PREFIX)/Kit/acstempl/src/ all install clean >> build.log 2>& 1 || echo "### ==> FAILED! " | tee -a build.log

#
# Update of all core components
# According to SE standards does not make man and does not cleanup at the end.
#
# There is a 'true' at the end of the loop to ensure  that if the LAST
#  module fails the whole Make does not fail
#

update:	repo-tag checkModuleTree
	@$(ECHO) "############ (Re-)build ACS Software         #################"| tee -a build.log
	@RESULT=0; for member in $(foreach name, $(MODULES), $(name) ) ; do \
	    if [ ! -d $${member} ]; then \
	        echo "######## ==> $${member} MODULE NOT FOUND! FAILED! " | tee -a build.log;\
	    fi;\
	    if [ -f $${member}/src/Makefile ]; then \
	        $(ECHO) "############ $${member} SRC" | tee -a build.log;\
	        $(call makeItAux,$${member}/src,clean,build.log,$${member}/src/NORM-BUILD-OUTPUT) \
	        $(call makeIt,$${member}/src,all,build.log,$${member}/src/NORM-BUILD-OUTPUT) \
	        $(call makeItAux,$${member}/src,install,build.log,$${member}/src/NORM-BUILD-OUTPUT) \
	    elif [ -f $${member}/ws/src/Makefile ]; then \
	        $(ECHO) "############ $${member} WS" | tee -a build.log;\
	        $(call makeItAux,$${member}/ws/src,clean,build.log,$${member}/ws/src/NORM-BUILD-OUTPUT) \
	        $(call makeIt,$${member}/ws/src,all,build.log,$${member}/ws/src/NORM-BUILD-OUTPUT) \
	        $(call makeItAux,$${member}/ws/src,install,build.log,$${member}/ws/src/NORM-BUILD-OUTPUT) \
	    elif [ -f $${member}/Makefile ]; then \
	        $(ECHO) "############ $${member} MAIN" | tee -a build.log;\
	        $(MAKE) $(MAKE_FLAGS) -C $${member}/ -s $@ 2>&1 || (echo "### ==> FAILED all ! " && false) | (tee -a build.log | tee $${member}/NORM-BUILD-OUTPUT) && (exit $${PIPESTATUS[0]}) || RESULT=1; \
	    fi;\
	    if [ "$(VXWORKS_RTOS)" == "YES" ]; then \
	        if [ -f $${member}/lcu/src/Makefile ]; then \
	            $(ECHO) "############ $${member} LCU" | tee -a build.log;\
	            $(call makeItAux,$${member}/lcu/src,clean,build.log,$${member}/lcu/src/NORM-BUILD-OUTPUT) \
	            $(call makeIt,$${member}/lcu/src,all,build.log,$${member}/lcu/src/NORM-BUILD-OUTPUT) \
	            $(call makeItAux,$${member}/lcu/src,install,build.log,$${member}/lcu/src/NORM-BUILD-OUTPUT) \
	        fi;\
	    fi;\
	done;\
	$(SHELL) $(MODULE_PREFIX)/acsBUILD/src/acsBUILDAfterBuildMod.sh >> build.log 2>& 1;\
	if [ $${RESULT} -ne 0 ]; then \
	    $(ECHO) "############ FAILED (Re-)build ACS Software    #################"| tee -a build.log; \
	    false; \
	else \
	    true; \
	fi;
	@$(ECHO) "############ DONE (Re-)build ACS Software    #################"| tee -a build.log

deploy: clean_deploy_log
	@$(ECHO) "############ Deploy ACS Software         #################"| tee -a deploy.log
	@RESULT=0; for member in $(foreach name, $(MODULES), $(name) ) ; do \
	    if [ ! -d $${member} ]; then \
	        echo "######## ==> $${member} MODULE NOT FOUND! FAILED! " | tee -a deploy.log;\
	    fi;\
	    if [ -f $${member}/src/Makefile ]; then \
	        $(ECHO) "############ $${member} SRC" | tee -a deploy.log;\
	        $(call makeItAux,$${member}/src,deploy,deploy.log,$${member}/src/NORM-BUILD-OUTPUT) \
	    elif [ -f $${member}/ws/src/Makefile ]; then \
	        $(ECHO) "############ $${member} WS" | tee -a deploy.log;\
	        $(call makeItAux,$${member}/ws/src,deploy,deploy.log,$${member}/ws/src/NORM-BUILD-OUTPUT) \
	    elif [ -f $${member}/Makefile ]; then \
	        $(ECHO) "############ $${member} MAIN" | tee -a deploy.log;\
	        $(MAKE) $(MAKE_FLAGS) -C $${member}/ -s $@ 2>&1 || (echo "### ==> FAILED deploy ! " && false) | (tee -a deploy.log | tee $${member}/NORM-BUILD-OUTPUT) && (exit $${PIPESTATUS[0]}) || RESULT=1; \
	    fi;\
	done;\
	if [ $${RESULT} -ne 0 ]; then \
	    $(ECHO) "############ FAILED Deploy ACS Software    #################"| tee -a deploy.log; \
	    false; \
	else \
	    true; \
	fi;
	@$(ECHO) "############ DONE Deploy ACS Software    #################"| tee -a deploy.log

#
# Update of all core components
# This does also make man and does clenup at the end.
# We use a define for the procedure of a single module, so that
# we can reuse it also in the update_clean_test target further down.

define update-clean-one-module
	if [ ! -d $${member} ]; then \
	    echo "######## ==> $${member} MODULE NOT FOUND! FAILED! " | tee -a build.log;\
	fi;\
	if [ -f $${member}/src/Makefile ]; then \
	    $(ECHO) "############ $${member} SRC" | tee -a build.log;\
	    $(MAKE) $(MAKE_FLAGS) -C $${member}/src/ clean >> build.log 2>& 1;\
	    $(MAKE) $(MAKE_FLAGS) -C $${member}/src/ all >> build.log 2>& 1 || echo "### ==> FAILED all ! " | tee -a build.log; \
	    $(MAKE) $(MAKE_FLAGS) -C $${member}/src/ man >> build.log 2>& 1 || echo "### ==> FAILED man ! " | tee -a build.log; \
	    $(MAKE) $(MAKE_FLAGS) -C $${member}/src/ install >> build.log 2>& 1 || echo "### ==> FAILED install ! " | tee -a build.log; \
	    $(MAKE) $(MAKE_FLAGS) -C $${member}/src/ clean >> build.log 2>& 1 || echo "### ==> FAILED clean ! " | tee -a build.log; \
	elif [ -f $${member}/ws/src/Makefile ]; then \
	    $(ECHO) "############ $${member} WS" | tee -a build.log;\
	    $(MAKE) $(MAKE_FLAGS) -C $${member}/ws/src/ clean >> build.log 2>& 1;\
	    $(MAKE) $(MAKE_FLAGS) -C $${member}/ws/src/ all >> build.log 2>& 1 || echo "### ==> FAILED all ! " | tee -a build.log; \
	    $(MAKE) $(MAKE_FLAGS) -C $${member}/ws/src/ man >> build.log 2>& 1 || echo "### ==> FAILED man ! " | tee -a build.log; \
	    $(MAKE) $(MAKE_FLAGS) -C $${member}/ws/src/ install >> build.log 2>& 1 || echo "### ==> FAILED install ! " | tee -a build.log; \
	    $(MAKE) $(MAKE_FLAGS) -C $${member}/ws/src/ clean >> build.log 2>& 1 || echo "### ==> FAILED clean ! " | tee -a build.log; \
	elif [ -f $${member}/Makefile ]; then \
	    $(ECHO) "############ $${member} MAIN" | tee -a build.log;\
	    $(MAKE) $(MAKE_FLAGS) -C $${member}/ -s $@ || echo "### ==> FAILED all ! " | tee -a build.log;\
	fi;\
	if [ "$(VXWORKS_RTOS)" == "YES" ]; then \
	    if [ -f $${member}/lcu/src/Makefile ]; then \
	        $(ECHO) "############ $${member} LCU" | tee -a build.log;\
	        $(MAKE) $(MAKE_FLAGS) -C $${member}/lcu/src/ clean >> build.log 2>& 1;\
	        $(MAKE) $(MAKE_FLAGS) -C $${member}/lcu/src/ all >> build.log 2>& 1 || echo "### ==> FAILED all ! " | tee -a build.log; \
	        $(MAKE) $(MAKE_FLAGS) -C $${member}/lcu/src/ man >> build.log 2>& 1 || echo "### ==> FAILED man ! " | tee -a build.log; \
	        $(MAKE) $(MAKE_FLAGS) -C $${member}/lcu/src/ install >> build.log 2>& 1 || echo "### ==> FAILED install ! " | tee -a build.log; \
	        $(MAKE) $(MAKE_FLAGS) -C $${member}/lcu/src/ clean >> build.log 2>& 1 || echo "### ==> FAILED clean ! " | tee -a build.log; \
	    fi;\
	fi
endef

# There is a 'true' at the end of the loop to ensure that if the LAST
# module fails the whole Make does not fail
#
update_clean: checkModuleTree
	@$(ECHO) "############ (Re-)build ACS Software         #################"| tee -a build.log
	@for member in  $(foreach name, $(MODULES), $(name) ) ; do \
	    $(update-clean-one-module);\
	done;\
	true;
	@$(SHELL) $(MODULE_PREFIX)/acsBUILD/src/acsBUILDAfterBuildMod.sh >> build.log 2>& 1
	@$(ECHO) "############ DONE (Re-)build ACS Software    #################"| tee -a build.log

#
# Test target
# GCH 2003-09-03
# Changed test strategy because of problems in the interaction between make test and tat
# (see spr.2003071)
# Now if there is a WS and LCU part I do the following:
#    - make all in LCU
#    - make all in ws
#    - make test in ws
# This model assumes that tests exercising the LCU code are in any case driven by the WS side.
# This assumpion may change in the future but works now for ACS.
# We are therefore not using any more the following code:
#	$(MAKE) -k -C $${member}/ws/test/ $@ | tee -a $(startupDir)/test.log |  egrep '(Nothing to|FAILED.|PASSED.|Error:)';\
#	if [ "$(VXWORKS_RTOS)" == "YES" ]; then \
#	    if [ -d $${member}/lcu/test ]; then\
#	        $(ECHO) "############ $${member}/lcu/test LCU TEST ############" | tee -a $(startupDir)/test.log;\
#	        $(MAKE) -k -C $${member}/lcu/test/ $@ | tee -a $(startupDir)/test.log |  egrep '(Nothing to|FAILED.|PASSED.|Error:)';\
#	    fi;\
#	fi;\
# GCH 2004-10-21
# I have changed this again.
# Also doing a make test in ws AFTER a make all in lcu and ws does not work.
# The problem is that tat tries again to go on the LCU part and build it and
# gets confused by the environment it receives from the make command.
# The only solution seem to call tat directly.
# Now if there is a WS and LCU part I do the following:
#    - make all in LCU
#    - make all in ws
#    - tat in ws
#

#
# Check if the ACS_INSTANCE variable is defined
# This allows to check for a clean test environment.
#
ifdef ACS_INSTANCE
    MAKE_TEST_ACS_INSTANCE = $(ACS_INSTANCE)
else
    MAKE_TEST_ACS_INSTANCE = 0
endif

# We use a define for the procedure of a single module, so that
# we can reuse it also in the update_clean_test target further down.

define test-one-module
	if [ -d $(ACSDATA)/tmp/ACS_INSTANCE.$(MAKE_TEST_ACS_INSTANCE) ]; then \
	    $(ECHO) "############ $${member}: WARNING: ACS_INSTANCE.$(MAKE_TEST_ACS_INSTANCE) NOT CLEAN!  ############" | tee -a $(startupDir)/test.log ;\
	fi;\
	if [ -f $${member}/ws/test/Makefile ]; then\
	    $(ECHO) "############ $${member}/ws/test WS TEST ############" | tee -a $(startupDir)/test.log ;\
	    if [ -f $${member}/lcu/test/Makefile ]; then \
	        $(MAKE) $(MAKE_FLAGS) -C $${member}/lcu/test/ all >> $(startupDir)/test.log 2>& 1 || echo "### ==> FAILED all lcu/test/! " | tee -a $(startupDir)/test.log; \
	    fi;\
	    $(MAKE) $(MAKE_FLAGS) -C $${member}/ws/test/ all >> $(startupDir)/test.log 2>& 1 || echo "### ==> FAILED all ws/test/! " | tee -a $(startupDir)/test.log; \
	    $(MAKE) $(MAKE_FLAGS) -C $${member}/ws/test/ test 2>& 1 | tee -a $(startupDir)/test.log | egrep '(Nothing to|FAILED.|PASSED.|Error:)'; \
	elif [ -f $${member}/test/Makefile ]; then\
	    $(ECHO) "############ $${member}/test MAIN TEST ############" | tee -a $(startupDir)/test.log ;\
	    $(MAKE) -k -C $${member}/test/ test | tee -a $(startupDir)/test.log | egrep '(Nothing to|FAILED.|PASSED.|Error:)';\
	elif [ -f $${member}/Makefile ]; then\
	    $(MAKE) -C $${member} $@ | tee -a $(startupDir)/test.log;\
	else\
	    $(ECHO) "######## ==> $${member} TEST DIRECTORY STRUCTURE NOT FOUND! CANNOT TEST ANYTHING!" | tee -a $(startupDir)/test.log ;\
	fi
endef

.PHONY: test

#
# If running on a machine where VxWorks is ocnfigured and tests have to be urn on the LCU.
# $(ACCDB_CONFIG) will be defined and the target accdb_config will be called to
# reconfigure the acc database in a clean way.
#
Test = test
$(Test): clean_test_log $(ACCDB_CONFIG)
	@$(ECHO) "############ TEST ACS Software #################"| tee -a $(startupDir)/test.log
	@for member in $(foreach name,$(MODULES),$(name)); do\
	    $(test-one-module);\
	done;\
	true;
	@$(ECHO) "############ DONE TEST ACS Software    #################"| tee -a $(startupDir)/test.log


update_clean_test: clean_test_log $(ACCDB_CONFIG)
	@$(ECHO) "############ UPDATE and TEST ACS Software #################"| tee -a build.log
	@for member in $(foreach name,$(MODULES),$(name)); do\
	    $(update-clean-one-module);\
	    $(test-one-module);\
	done;\
	true;
	@$(SHELL)  $(MODULE_PREFIX)/acsBUILD/src/acsBUILDAfterBuildMod.sh >> build.log 2>& 1
	@$(ECHO) "############ DONE UPDATE and TEST ACS Software    #################"| tee -a build.log


#
# Rund the accdbConfig tool to cleanup the acc database abd startup
# msqld if not runnin.
#
accdb_config:
	@$(ECHO) "############ Reconfigure and startup acc database #################"| tee -a $(startupDir)/test.log
	@accdbConfig >> $(startupDir)/test.log 2>& 1

#
# show_modules target
#
# Simply lists all MODULES that would be build
# with the current setup
#
show_modules:
	@$(ECHO) "Modules in build list are:" 
	@$(ECHO) ${MODULES}

################################################################
# Repository targets.
# 
# The following targets and expressions are helpers for
# Repository operations on the ACS tree.
################################################################

#
# This expression extracts the Repository tag for the
# ACS/Makefile file (if exists).
# This does not warranty that all files have the same tag,
# but it is at least an indication.
#
REPO_URL = $(shell git remote -v |grep fetch |awk '{print $$2}' | sed 's|://.*@|://|')
REPO_TAG = $(shell git branch |grep "^*" |sed "s/(\(.*\))/\1/" |awk '{print $$NF}')

#
#
# This target puts the Repository tag for the ACS/Makefile file
# (if exists) into a file, so that it can be used to mark an
# installation.
#
repo-tag:
	@ $(ECHO) "Evaluating current ACS TAG from $(REPO_URL)"; \
	if [ X$(REPO_TAG) != X ]; then \
	    $(ECHO) "REPO tag is: $(REPO_TAG)"; \
	    $(ECHO) $(REPO_TAG) > ACS_TAG ; \
	else \
	    if [ -f ACS_TAG ]; then\
	        $(ECHO) "ACS tag file already exist: "; cat ACS_TAG; $(ECHO) ""; \
	    else \
	        $(ECHO) "No Repo tag available"; \
	    fi; \
	fi

#
# This target gets from Repository the correct ACS_VERSION and
# ACS_PATCH_LEVEL files.
#
repo-get-version:
	@ $(ECHO) "Extracting from Repository version files"; \
	if [ X$(REPO_TAG) != X ]; then \
	    $(ECHO) "Repository tag is: $(REPO_TAG)"; \
	else \
	    $(ECHO) "No Repository tag available"; \
	fi; \
	git fetch; git checkout origin/$(REPO_TAG) -- ACS_PATCH_LEVEL ACS_VERSION

#
# This target gets from Repository all files needed for an LGPL distribution
#
LGPL_FILES=README README-new-release LGPL
repo-get-lgpl: repo-tag repo-get-version
	@ $(ECHO) "Extracting from Repository LGPL files"; \
	if [ X$(REPO_TAG) != X ]; then \
	    $(ECHO) "Repo tag is: $(REPO_TAG)"; \
	else \
	    $(ECHO) "No Repo tag available"; \
	fi; \
	git fetch; git checkout origin/$(REPO_TAG) -- $(LGPL_FILES)

#
# This target gets from Repository a complete ACS code distribution
#
NO-LGPL_FILES=Benchmark NO-LGPL
repo-get-no-lgpl: repo-tag repo-get-version repo-get-lgpl repo-get-no-lgpl-extract

repo-get-no-lgpl-extract:
	@$(ECHO) "Extracting from Repo NO-LGPL files"; \
	if [ X$(REPO_TAG) != X ]; then \
	    $(ECHO) "Repo tag is: $(REPO_TAG)"; \
	else \
	    $(ECHO) "No Repo tag available"; \
	fi; \
	git fetch; git checkout origin/$(REPO_TAG) -- $(NO-LGPL_FILES)

#
# Standard canned targets
#
clean:	
	$(canned)
all:	
	$(canned)
install:
	$(canned)

man:
	$(canned)

#
# ___oOo___
