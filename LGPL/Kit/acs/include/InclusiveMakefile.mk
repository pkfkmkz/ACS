MAKEFLAGS += --no-builtin-rules
$(info Profile: $(MAKEID))

.SUFFIXES:

MAKECONFIGDIR:=$(if $(wildcard $(MAKEDIR)/../include/$(MAKEID)MakefileConfig.mk),$(abspath $(MAKEDIR)/..),$(shell searchFile include/$(MAKEID)MakefileConfig.mk))
$(if $(filter $(MAKECONFIGDIR),#error#), $(error "No configuration file available '$(MAKEID)MakefileConfig.mk'."),$(eval MAKECONFIGDIR:=$(MAKECONFIGDIR)/include)$(eval include $(MAKECONFIGDIR)/$(MAKEID)MakefileConfig.mk))

# This variable has to be propagated to the recipes
export INSTALL_ROOT
COLON:= :
EMPTY:=
SPACE:= $(EMPTY) $(EMPTY)
PYTHONINC:=$(shell python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())" 2> /dev/null)
PYTHONINS:=$(shell python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())" 2> /dev/null)
PYTHONVER:=$(shell python -c "import sys; print('.'.join(map(str, sys.version_info[:2])))" 2> /dev/null)
PYTHONABI:=$(shell python-config --abiflags 2> /dev/null)
PYTHONLIB:=python$(PYTHONVER)$(PYTHONABI)
PYTHON_VERS:=$(shell python -V 2>&1 | awk '{print $$2}' | awk -F. '{print $$1 "." $$2}')
PYTHON_ROOT := $(shell python-config --prefix)
PYTHON_LIB_SUFFIX?="lib/python"
PYTHON_SITE_PACKAGES?="$(PYTHON_LIB_SUFFIX)/site-packages"
pycache_base:=$(shell python -c "import importlib; print(importlib.util.cache_from_source('PYCACHE_PLACEHOLDER.py'))" 2>/dev/null)
pycache=$(foreach py,$(patsubst %.py,%,$1),$(if $(findstring PYCACHE_PLACEHOLDER,$(pycache_base)),$(subst ./,,$(dir $(py)))$(subst PYCACHE_PLACEHOLDER,$(notdir $(py)),$(pycache_base)),$(py).pyc))
pycachedir=$(foreach py,$(patsubst %.py,%,$1),$(patsubst %/,%,$(if $(findstring PYCACHE_PLACEHOLDER,$(pycache_base)),$(subst ./,,$(dir $(py)))$(dir $(subst PYCACHE_PLACEHOLDER,$(notdir $(py)),$(pycache_base))),$(subst ./,,$(dir $(py).pyc)))))

$(if $(MAKE_VERBOSE),$(eval AT:=)$(eval OUTPUT:=)$(eval PYTHON_OUTPUT:=)$(VERBOSE_DEF:=-veerbose),$(eval AT:=@)$(eval OUTPUT:=/dev/null)$(eval PYTHON_OUTPUT:=-q)$(VERBOSE_DEF:=))

# force Korn shell as the shell used to interpret the commands
#SHELL = /bin/bash
debug_trace:=
debug_trace_ignore:=
debug_trace_macros:=

THIS_MAKEFILE:=$(word 1,$(MAKEFILE_LIST))

#Current execution directory
#PWD:=$(shell pwd)

#Figure out the current platform.
OS:=$(shell uname)
OSREV:=$(shell uname -r)
#ICT-5964: do not treat directories as text files when grep-ing for a pattern
$(if $(LINUX_HOME),$(eval kernel_install_subfold := $(shell egrep --regexp="define[[:space:]]+UTS_RELEASE" --no-messages $(LINUX_HOME)/include/linux/*.h $(LINUX_HOME)/include/generated/*.h | cut --delimiter="\"" --fields=2 | tail -n1)))

#1: Module Full Name
#2: Language to test
must-build=$(filter-out false,$(if $($1_MAKE_ONLY),$(call get-must-build,$1,$2),true))
set-must-build=$(eval $1_MAKE_ONLY_$2:=$(if $(findstring $2,$($1_MAKE_ONLY)),true,false))
get-must-build=$(if $($1_MAKE_ONLY_$2),,$(call set-must-build,$1,$2))$($1_MAKE_ONLY_$2)

#Define WS or LCU related variables
$(if $(MAKEDIRTMP),,$(eval MAKEDIRTMP:=$(ACSROOT)/include))
$(if $(MAKE_VXWORKS),$(eval -include $(MAKEDIRTMP)/$(MAKEID)MakefileVxWorks.mk))

dist-profile=$(if $(wildcard $(MAKEDIR)/../include/$(MAKEID)MakefileProfile.$1.mk),$(abspath $(MAKEDIR)/..),$(shell searchFile include/$(MAKEID)MakefileProfile.$1.mk))
check-dist-profile=$(if $(filter $(call dist-profile,$1),\#error\#),,True)
get-dist-profile=$(call dist-profile,$1)/include/$(MAKEID)MakefileProfile.$1.mk

#Retrieve appropriate Makefile profile
DIST_NAME:=$(if $(shell which lsb_release),$(shell lsb_release -i |awk '{print $$3}'),Default$(warning lsb_release is not installed. Using 'Default' as DIST!))
DIST_VER:=$(if $(shell which lsb_release),$(shell lsb_release -r |awk '{print $$2}' |cut -d. -f1))
DIST:=$(DIST_NAME)$(DIST_VER)
MAKEPROFILE:=$(firstword $(foreach dist,$(DIST) $(DIST_NAME) RedHatEnterpriseLinux,$(if $(call check-dist-profile,$(dist)),$(call get-dist-profile,$(dist)))))
$(if $(MAKEPROFILE),,$(error Problem with ACS installation as 'RedHatEnterpriseLinux' profile could not be found))
$(if $(filter $(patsubst $(MAKEID)MakefileProfile.%.mk,%,$(notdir $(MAKEPROFILE))),RedHatEnterpriseLinux),$(warning Unsupported operating system '$(DIST)'. Defaulting to 'RedHatEnterpriseLinux'.))
include $(MAKEPROFILE)

BINDIR   = bin
LIBDIR   = lib
$(if $(MAKE_PURIFY_TYPE),$(eval MAKE_PURIFY_TYPE:=OCI))
$(if $(MAKE_PURE),$(eval ENABLE_PURIFY:=on)$(eval ENABLE_PURECOV:=on))
$(if $(filter $(MAKE_PURIFY_TYPE),SCI),,$(if $(MAKE_PUREGUI),$(eval ENABLE_PURIFY:=on)$(eval ENABLE_PURECOV:=on),))
$(if $(MAKE_PURIFY),$(eval ENABLE_PURIFY:=on))
$(if $(MAKE_PURECOV),$(eval ENABLE_PURECOV:=on)$(if $(filter $(MAKE_PURIFY_TYPE),SCI),$(eval ENABLE_PURIFY:=on),),)
$(if $(ENABLE_PURIFY),$(eval PURIFY:=purify -always-use-cache-dir -user-path="../test:../src:src:test" -g++=yes -linker=$(GNU_ROOT)/bin/ld)$(if $(MAKE_PUREGUI),,$(eval PURIFY:=$(PURIFY) -log-file=./.purifydir/MemoryReport -append-logfile=yes -messages=batch -view-file=./.purifydir/purify-%v.pv)),$(eval PURIFY:=))
$(if $(ENABLE_PURECOV),$(eval PURECOV:=purecov -dlclose-mode=2 -follow-child-processes=yes -always-use-cache-dir)$(if $(MAKE_PUREGUI),,$(eval PURECOV:=$(PURECOV) -counts-file=./.purifydir/purecov-%v.pcv))$(eval override OPTIMIZE:=)$(eval override DEBUG:=defined),$(eval PURECOV:=))
$(if $(DEBUG),$(eval CFLAGS:=$(CFLAGS) -g3 -ggdb3 -DDEBUG),$(if $(OPTIMIZE),,$(eval CFLAGS:=$(CFLAGS) -g -DDEBUG -O)))
$(if $(OPTIMIZE),$(eval O_LEVEL:=-O),)
$(if $(filter $(OPTIMIZE),0 1 2 3 4 5 6 7 8 9),$(eval O_LEVEL:=$(O_LEVEL)$(OPTIMIZE)),)
$(if $(O_LEVEL),$(eval CFLAGS:=$(CFLAGS) $(O_LEVEL)),)
$(if $(USER_CFLAGS),$(eval CFLAGS:=$(CFLAGS) $(USER_CFLAGS)))
$(if $(MAKE_GCOV),$(eval CFLAGS:=$(CFLAGS) -g -fprofile-arcs -ftest-coverage),)
#External make flags
MAKE_FLAGS:=$(MAKE_FLAGS) $(MAKE_PARS)

##################################################################
#   TAO search paths for include files and libraries             #
##################################################################
$(if $(and $(ACE_ROOT_DIR),$(ACE_ROOT)),$(if $(TAO_ROOT),,$(eval TAO_ROOT:=$(ACE_ROOT)/TAO)),)
$(if $(MAKE_VXWORKS),$(error TODO VXWORKS!),$(eval CFLAGS:=-pipe -D_POSIX_THREADS -D_POSIX_THREAD_SAFE_FUNCTIONS -D_REENTRANT -DACE_HAS_AIO_CALLS $(CFLAGS))$(eval CPPFLAGS:=-fcheck-new))
CXXFLAGS:=$(CFLAGS) $(CXXFLAGS)

#################################################
# IDL                                           #
#################################################
# COMP-8768: ensure no subdirs of CVS/ or .svn/ are included
MK_IDL_PATH_LIST:=$(shell if [ -d ../idl  ]; then find ../idl -type d ! \( -name CVS -prune \)  ! \( -name .svn -prune \) -printf "%p " 2>/dev/null ; fi )

##################################################################
#   set search paths for include files and libraries             #
##################################################################

#
# ... for GNU and TCLTK tools

# from MAY97 on, GNU, TCLTK, Data Flow tools are not installed under
# /usr/local, but they have a dedicated directories.

# Default values:
TOOLS_INC:=$(INC_DEFAULT)
TOOLS_LIB:=$(LIB_DEFAULT)

ACSDEPS_ROOT:=$(wildcard $(ACSDEPS))

$(if $(GNU_ROOT),$(if $(MAKE_VXWORKS),$(eval TOOLS_INC:=-I$(GNU_ROOT)/include $(TOOLS_INC))$(eval TOOLS_LIB:=-L$(GNU_ROOT)/lib $(TOOLS_LIB)),),)
$(if $(TCLTK_ROOT),$(eval TOOLS_INC:=-I$(TCLTK_ROOT)/include $(TOOLS_INC))$(eval TOOLS_LIB:=-L$(TCLTK_ROOT)/lib $(TOOLS_LIB)),)
$(if $(PYTHON_ROOT),$(eval TOOLS_INC:=-I$(PYTHONINC) $(TOOLS_INC))$(if $(filter $(PLATFORM),Cygwin),$(eval TOOLS_LIB:=-L$(PYTHON_ROOT)/bin $(TOOLS_LIB)),$(eval TOOLS_LIB:=-L$(PYTHON_ROOT)/lib $(TOOLS_LIB))),)
$(if $(ACSDEPS_ROOT),$(eval TOOLS_INC:=-I$(ACSDEPS_ROOT)/include $(TOOLS_INC))$(eval TOOLS_LIB:=-L$(ACSDEPS_ROOT)/lib $(TOOLS_LIB)),)
$(if $(ACSROOT),$(eval TOOLS_INC:=-I$(ACSROOT)/include $(TOOLS_INC))$(if $(MAKE_VXWORKS),$(eval TOOLS_INC:=-I$(ACSROOT)$(VW)/include $(TOOLS_INC))$(eval TOOLS_LIB:=-L$(ACSROOT)$(VW)/lib $(TOOLS_LIB)),),)

#
# ... for software products
$(if $(MAKE_VXWORKS),$(eval VXINC:=-I$(VXROOT)/h/wrn/coreip/)$(eval VXLIB:=-L$(VXROOT)/lib),$(eval XINC?=$(XINC_DEFAULT))$(eval XLIB?=$(XLIB_DEFAULT)))

empty:=
space:=$(empty) $(empty)

##
## define basic paths to ACSROOT:
$(if $(ACSROOT),$(eval ACSINC:=-I$(ACSROOT)/include -I$(ALMASW_INSTDIR)/boost/include),)
$(if $(and $(ACSROOT),$(MAKE_VXWORKS)),$(eval ACSINC:=-I$(ACSROOT)$(VW)/include $(ACSINC)),)
$(if $(ACSROOT),$(eval SEARCHPATH:=$(ACSROOT)$(VW)),)
$(if $(ACSROOT),$(eval ACSLIB:=-L$(ACSROOT)$(VW)/$(LIBDIR) -L$(ALMASW_INSTDIR)/boost/lib),)
$(if $(ACSROOT),$(eval PRJTOP:=$(ACSROOT)$(VW)),)
$(if $(ACSROOT),$(eval INSTALL_ROOT:=$(ACSROOT)),)
$(if $(ACSROOT),$(eval CDBS:=$(ACSROOT)/config/CDB/schemas),)
$(if $(ACSROOT),$(eval PRJTOP_LOG:=$(ACSROOT)),)
$(if $(ACSROOT),$(eval ACSIDL:=-I$(ACSROOT)/idl),)
$(if $(and $(ACSROOT),$(MAKE_VXWORKS)),$(eval ACSIDL:=-I$(ACSROOT)$(VW)/idl $(ACSIDL)),)

#For each item in INTLIST add search paths:
DIRLIST:=$(subst :, , $(INTLIST))

#If INTLIST is defined, override or complete the search paths:
$(if $(INTLIST),$(eval ACSINC:=$(foreach dir,$(DIRLIST), -I$(dir)/include) $(ACSINC)),)
$(if $(and $(INTLIST),$(MAKE_VXWORKS)),$(eval ACSINC:=$(foreach dir, $(DIRLIST), -I$(dir)$(VW)/include) $(ACSINC)),)
$(if $(INTLIST),$(eval SEARCHPATH:=$(subst $(space),:,$(foreach dir, $(DIRLIST),$(dir)$(VW))):$(SEARCHPATH)),)
$(if $(INTLIST),$(eval ACSLIB:=$(foreach dir, $(DIRLIST), -L$(dir)$(VW)/$(LIBDIR)) $(ACSLIB)),)
$(if $(INTLIST),$(eval PRJTOP:=$(word 1, $(DIRLIST))$(VW)),)
$(if $(INTLIST),$(eval INSTALL_ROOT:=$(word 1, $(DIRLIST))),)
$(if $(INTLIST),$(eval CDBS:=$(word 1, $(DIRLIST))/config/CDB/schemas),)
$(if $(INTLIST),$(eval PRJTOP_LOG:=$(word 1, $(DIRLIST))),)
$(if $(INTLIST),$(eval ACSIDL:=$(foreach dir, $(DIRLIST), -I$(dir)/idl) $(ACSIDL)),)
$(if $(and $(INTLIST),$(MAKE_VXWORKS)),$(eval ACSIDL:=$(foreach dir,$(DIRLIST), -I$(dir)$(VW)/idl) $(ACSIDL)),)


#If INTROOT is defined, override or complete the search paths:
$(if $(INTROOT),$(eval ACSINC:=-I$(INTROOT)/include $(ACSINC)),)
$(if $(and $(INTROOT),$(MAKE_VXWORKS)),$(eval ACSINC:=-I$(INTROOT)$(VW)/include $(ACSINC)),)
$(if $(INTROOT),$(eval SEARCHPATH:=$(INTROOT)$(VW):$(SEARCHPATH)),)
$(if $(INTROOT),$(eval ACSLIB:=-L$(INTROOT)$(VW)/$(LIBDIR) $(ACSLIB)),)
$(if $(INTROOT),$(eval PRJTOP:=$(INTROOT)$(VW)),)
$(if $(INTROOT),$(eval INSTALL_ROOT:=$(INTROOT)),)
$(if $(INTROOT),$(eval CDBS:=$(INTROOT)/config/CDB/schemas),)
$(if $(INTROOT),$(eval PRJTOP_LOG:=$(INTROOT)),)
$(if $(INTROOT),$(eval ACSIDL:=-I$(INTROOT)/idl $(ACSIDL)),)
$(if $(and $(INTROOT),$(MAKE_VXWORKS)),$(eval ACSIDL:=-I$(INTROOT)$(VW)/idl $(ACSIDL)),)

$(eval INSTDIR:=$(INSTALL_ROOT))

$(if $(ACE_ROOT),$(eval ACSINC:=-I$(ACE_ROOT)/TAO -I$(ACE_ROOT)/TAO/tao -I$(ACE_ROOT)/ace -I$(ACE_ROOT)/TAO/tao/IORTable \
   -I$(ACE_ROOT)/TAO/tao/IFR_Client -I$(ACE_ROOT)/TAO/tao/PortableServer \
   -I$(ACE_ROOT)/TAO/tao/SmartProxies -I$(ACE_ROOT)/TAO/tao/DynamicAny  \
   -I$(ACE_ROOT)/TAO/tao/DynamicInterface -I$(ACE_ROOT)/TAO/tao/Messaging \
   -I$(ACE_ROOT)/TAO/tao/Valuetype -I$(ACE_ROOT)/TAO/orbsvcs/orbsvcs -I$(ACE_ROOT)/TAO/orbsvcs \
   -I$(ACE_ROOT)/TAO/orbsvcs/orbsvcs/Log -I$(ACE_ROOT) $(ACSINC)),)
$(if $(ACE_ROOT),$(eval ACSLIB:=-L$(ACE_ROOT)/lib $(ACSLIB)),)
$(if $(ACE_ROOT),$(eval TAO_MK_IDL_PATH := -I$(ACE_ROOT)/TAO/orbsvcs/orbsvcs -I$(ACE_ROOT)/TAO/tao -I$(ACE_ROOT)/TAO -I$(ACE_ROOT)/TAO/orbsvcs),)
$(if $(and $(ACE_ROOT),$(USE_OPENDDS)),$(eval TAO_MK_IDL_PATH:=$(TAO_MK_IDL_PATH) -I$(DDS_ROOT)),)
$(if $(and $(ACE_ROOT),$(USE_OPENDDS)),$(eval TAO_IDLFLAGS+=-Gdcps),)
$(if $(and $(ACE_ROOT),$(USE_OPENDDS)),$(eval USER_INC+= -I$(DDS_ROOT)),)
$(if $(and $(ACE_ROOT),$(USE_OPENDDS)),$(eval USER_LIB+= -L$(DDS_ROOT)/lib),)

I_PATH:=$(USER_INC) $(ACSINC)
L_PATH:=$(USER_LIB) $(ACSLIB)
MK_IDL_PATH:=$(USER_IDL) $(ACSIDL)

$(if $(MAKE_VXWORKS),$(eval I_PATH:=$(I_PATH) $(VXINC) $(VX_IPNET_INC_ALLOBJECTS) $(TOOLS_INC)),$(eval I_PATH:=$(I_PATH) $(XINC) $(TOOLS_INC)))
$(if $(MAKE_VXWORKS),$(eval L_PATH:=$(L_PATH) $(VXLIB)),$(eval L_PATH:=$(L_PATH) $(XLIB) $(TOOLS_LIB)))

$(if $(filter prepare,$(MAKECMDGOALS)),,$(if $(PRJTOP),$(if $(wildcard $(PRJTOP)),,$(error The installation root-directory '$(PRJTOP)' does not exist - check your INTROOT/INTLIST/ACSROOT settings)),$(error INTROOT, INTLIST and ACSROOT are all undefined - cannot determine an installation root-directory)))
$(if $(PRJTOP),$(eval BIN:=$(PRJTOP)/$(BINDIR)),)
$(if $(PRJTOP),$(eval LIB:=$(PRJTOP)/$(LIBDIR)),)
$(if $(PRJTOP),$(eval INCLUDE:=$(PRJTOP)/include),)
$(if $(PRJTOP),$(eval MAN:=$(PRJTOP)/man),)

#  Define the "mode" masks for file installation. If the installation
#  is into INTROOT, the mask are set also as group writable, so
#  a colleague can overwrite an existing application when the owner
#  is not available (holiday, illness, etc.)
$(if $(INTROOT),$(eval P755:=775),$(eval P755 = 755))
$(if $(INTROOT),$(eval P644:=664),$(eval P644 = 644))

#Man page generation Last Change flag
$(if $(ACSROOT),$(eval LASTCHANGE:="$(MODVERSION) $(shell date '+%d/%m/%y-%H:%M')"),$(eval LASTCHANGE:="development $(shell date '+%d/%m/%y-%H:%M')"))
#Doxygen                                       #
$(if $(MAKE_PDF),$(eval DOXYGEN_PDF:="pdf"),$(eval DOXYGEN_PDF:=""))

MANSECTIONS_INSTALL:=$(filter-out l, $(MANSECTIONS))

#This gives a unique number that can be used for the filename
#     important: ":=" is needed to force the substitution here, and not at every occurence of $FILE
UNIQUE_NUMBER:=$(shell echo $$$$)
USER_NAME:=$(shell whoami)
tDir:=tmp$(UNIQUE_NUMBER)
FILE:=/tmp/acsMake_$(UNIQUE_NUMBER)_$(USER_NAME)

# RTAI Part, both clean, install and all are augmented here
$(if $(RTAI_HOME),$(eval I_PATH:=$(I_PATH) -I$(RTAI_HOME)/include -I$(LINUX_HOME)),)
$(if $(RTAI_HOME),$(eval CFLAGS:=$(CFLAGS) -DRTAI_HOME),)
$(if $(LINUX_HOME),$(eval CFLAGS:=$(CFLAGS) -DLINUX_HOME),)
#######################################################################
# REMARK: having 'all' as the first target in Makefile should be enough,
#         but I do this to have the possibility to define here other
#         standard targets.
#default : all

#################################################
#################################################
# entry points for various language specific
# features
# *********************************************

CREATE_DIRS:=include object doc $(if $(RTAI_HOME),rtai/$(kernel_install_subfold),) $(if $(RTAI_HOME),,$(if $(LINUX_HOME),kernel/$(kernel_install_subfold),)) bin lib lib/ACScomponents $(PYTHON_SITE_PACKAGES) idl config
$(if $(MAKE_VXWORKS),$(if $(filter $(VX_VERSION),6.9),,$(eval CREATE_DIRS+=src/.obj)),)
$(if $(MAKE_VXWORKS),$(if $(filter $(VX_VERSION),6.9),,$(eval CREATE_DIRS+=test/.obj)),)

# Never needed for VxWorks. $(platform) is the host OS, not the target OS, useless test.
# For now keep for legacy VxWorks 6.7
$(if $(MAKE_VXWORKS),$(if $(filter $(VX_VERSION),6.9),,$(eval CREATE_DIRS+=src/.purifydir)),)
$(if $(MAKE_VXWORKS),$(if $(filter $(VX_VERSION),6.9),,$(eval CREATE_DIRS+=test/.purifydir)),)

#_MKDIRS:=$(foreach mkdir,$(CREATE_DIRS),$(if $(wildcard ../$(mkdir)),,$(shell mkdir -p ../$(mkdir))))

ifneq ($(strip $(LINUX_HOME)),)
ifeq ($(CPU),x86_64)
KERNEL_MODULE_CFLAGS = -D__KERNEL__ -DMODULE -O2 -Wall -Wstrict-prototypes -Wno-trigraphs  -fomit-frame-pointer -fno-strict-aliasing -fno-common -pipe -falign-functions=4 -I$(LINUX_HOME)/include/linux -I$(LINUX_HOME)/include/asm-i386/mach-default $(USER_KERNEL_MODULE_CFLAGS)
else
KERNEL_MODULE_CFLAGS = -D__KERNEL__ -DMODULE -O2 -Wall -Wstrict-prototypes -Wno-trigraphs  -fomit-frame-pointer -fno-strict-aliasing -fno-common -pipe  -march=i686 -falign-functions=4 -I$(LINUX_HOME)/include/linux -I$(LINUX_HOME)/include/asm-i386/mach-default $(USER_KERNEL_MODULE_CFLAGS)
endif
KDIR := /lib/modules/$(kernel_install_subfold)/build
CCKERNEL:=cc
USR_INC = -I$(LINUX_HOME)/include  $(patsubst -I..%,-I$(CURDIR)/..%,$(I_PATH))
EXTRA_CFLAGS = -I. -D_FORTIFY_SOURCE=0 -ffast-math -mhard-float -Werror-implicit-function-declaration  $(patsubst ..%,$(CURDIR)/..%,$(USR_INC)) $(USER_KERNEL_MODULE_CFLAGS) -DLINUX_HOME
endif

.PHONY: vxworks_license_check
vxworks_license_check:
	$(AT) lmutil lmstat -c $(WRSD_LICENSE_FILE) >/dev/null || ( $(ECHO) "=== License Server not Reachable! Please contact your system administrator ==="; exit -1);


CHECKS1:=$(foreach idl,$(IDL_FILES),$(foreach jar,$(JARFILES),$(if $(filter $(idl),$(jar)),$(error "$(idl) is duplicated in JARFILES and IDL_FILES",))))
CHECKS2:=$(foreach cjar,$(COMPONENT_JARFILES),$(foreach jar,$(JARFILES),$(if $(filter $(cjar),$(jar)),$(error "$(cjar) is duplicated in JARFILES and COMPONENT_JARFILES",))))
CHECKS3:=$(foreach idl,$(IDL_FILES),$(foreach xml,$(ACSERRDEF),$(if $(filter $(idl),$(xml)),$(warning $(xml) is duplicated, removing it),"$(idl)")))

isContained=$(findstring YES,$(foreach item,$(2),$(if $(filter $(1),$(item)),YES,NO)))
$(if $(ACSERRDEF),$(eval IDL_FILES:=$(foreach idl,$(IDL_FILES),$(if $(call isContained,$(idl),$(ACSERRDEF)),,$(idl)))),)

# notify the user about current file in use and version
.PHONY : version
version:
	$(AT)$(ECHO) "Makefile in use: $(MAKEDIRTMP)/IncluseiveMakefile"
	$(AT)$(ECHO) "Make ID is: $(MAKEID)"

CPPFLAGS:=$(CPPFLAGS)
CFLAGS:=$(CFLAGS) $(CSTD) $(CPU) $(if $(INTROOT),-I$(INTROOT)/include,) $(foreach idir,$(INTLIST),-I$(idir)/include) -I$(ACSROOT)/include
CXXFLAGS:=$(CXXFLAGS) $(CXXSTD) $(CPU) $(if $(INTROOT),-I$(INTROOT)/include,) $(foreach idir,$(INTLIST),-I$(idir)/include) -I$(ACSROOT)/include
LDFLAGS:=$(LDFLAGS) $(CPU) $(if $(INTROOT),-L$(INTROOT)/lib,) $(foreach ldir,$(INTLIST),-L$(ldir)/lib) -L$(ACSROOT)/lib

#GIT:=$(shell git rev-parse 2&>1 > /dev/null; echo $$?)
#$(if $(filter $(GIT),0), $(eval BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)) $(eval REVISION:=$(shell git rev-parse HEAD)) $(eval SHORT_REVISION:=$(shell git rev-parse --short HEAD)),)

TAO_IDL:=$(ACE_ROOT)/TAO/TAO_IDL/tao_idl
OMNI_IDL:=omniidl
OMNI_ROOT:=$(shell python-config --prefix)
JAVA_IDL:=$(JACORB_HOME)/bin/idl
JACORB_MK_IDL_PATH:=-I$(JACORB_HOME)/idl/jacorb -I$(JACORB_HOME)/idl/omg
XALAN:=xalan-2.7.3.jar
XALAN_SER:=serializer-2.7.3.jar
BASE_IDL_EXTENSIONS+=C.h C.cpp S.cpp C.inl S.h

-include $(if $(wildcard $(MAKEDIR)/../include/$(MAKEID)MakefileTargets.mk),$(MAKEDIR)/../include/(MAKEID)MakefileTargets.mk,$(MAKEDIRTMP)/$(MAKEID)MakefileTargets.mk)

#################################################################################
#
# ENTERING FORMER ACSMAKEFILE.ALL AREA
#################################################################################


LIB_PATH_LIST:=$(strip $(patsubst -L%,%,$(L_PATH)))
INC_PATH_LIST:=$(strip $(patsubst -I%,%,$(I_PATH)))
IDL_PATH_LIST:=$(strip $(patsubst -I%,%,$(MK_IDL_PATH) $(TAO_MK_IDL_PATH)))

vpath  %.o
vpath  %.h  $(INC_PATH_LIST)
vpath  %.idl $(IDL_PATH_LIST)
vpath  %.a  $(LIB_PATH_LIST)
vpath  %.$(SHLIB_EXT)  $(LIB_PATH_LIST)
vpath  %.jar  $(LIB_PATH_LIST)

#%.a:
#	@echo "ERROR: ----> $@  does not exist."; exit 1

# Include Automatic Dependancies for C source files, libraries, ....
# ------------------------------------------------------------------
# (REMARK: if the files are not existing make does them using the appropriate
#          rule as from above. (see GNU Make 3.64, pag 26)
#
# if the list of C-sources names is not empty, include dependencies files.
# Todo: Nowhere used
CSOURCENAMES := $(sort $(CSOURCENAMES))

#1: Makefile to analyze
#2: Current MODRULE value
#3: Current MODPATH value
get-make-targets=$(shell make -pRrq -f $1 MODRULE:=$2 MODPATH:=$3 : 2>/dev/null | awk -v RS= -F: '/^\# File/,/^\# Finished Make data base/ {if ($$1 !~ "^[\#.]") {print $$1}}')

plugins_list:=
get-plugins=$(plugins_list)
add-plugin=$(eval plugins_list+=$1)
has-plugin=$(if $(filter $1,$(get-plugins)),true)

#1 Plugin Name
#2 Module path
define load-plugin
$(eval $1_plg_entry:=$(patsubst %.mk,%,$1))
$(eval $1_plg_found:=$(call findDep,$($1_plg_entry).mk,plg,include,1))
$(if $(and $2,$(wildcard $2/include/$($1_plg_entry).mk)),$(eval $1_plg_found:=$2/include/$($1_plg_entry).mk))
$(if $(call has-plugin,$($1_plg_entry)),,$(if $(filter $($1_plg_entry).mk,$($1_plg_found)),$(warning The plugin '$($1_plg_entry)' could not be loaded.),$(call add-plugin,$($1_plg_entry))include $($1_plg_found)))
endef

#mod
#obj
#abs
#src
define sourceDeps
$(call args-set-names,$0,mod,obj,abs,src)$(debug-enter)$(shell $(CCDEP) $(CXXFLAGS) $((mod)_USER_CXXFLAGS) $(I_PATH) $($(obj)_cflags) -I$(abs)/include -I$(abs)/object $(src) | grep "^ [^/]" |sed "s'^ \(.*\) .*$$$$'\1'")$(debug-leave)
endef

#Makefile Generation Step Functions
make_step:=unkwnown
get-make-step=$(make_step)
set-make-step=$(eval make_step:=$1)
is-make-step=$(if $(filter $1,$(get-make-step)),true,)

#Debugging Macro Functions

#Macro functions support N - 1 arguments:
args_list:=1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21
comma:=,
#(debug time)
debug-msg=$(if $(MAKE_VERBOSE),$(warning $1: $2),)
debug-time=$(shell date -u +"%s%N")
#$(call debug-time-diff,t0,tf)
debug-time-diff=$(shell echo "scale=3; ($2 - $1)/1000000000.0" | bc -l)
$(should-debug)
should-debug=$(or $(and $(debug_trace),$(if $(filter $0,$(debug_trace_ignore)),,$0)),$(filter $0,$(debug_trace_macros)))
#$(debug-enter)
debug-enter=$(if $(should-debug),$(eval $(if $(value $0_macro_t0),$0_macro_t0+=$(debug-time),$0_macro_t0:=$(debug-time)))$(warning "Entering '$0 ($(words $($0_macro_t0)))': ($(echo-args))"))
#$(debug-leave)
debug-leave=$(if $(should-debug),$(warning "Leaving '$0 ($(words $($0_macro_t0)))': Took $(call debug-time-diff,$(lastword $($0_macro_t0)),$(debug-time)) seconds to execute macro...")$(eval $0_macro_t0:=$(filter-out $(lastword $($0_macro_t0)),$($0_macro_t0))))
echo-args=$(subst ' ','$(comma) ',$(strip $(foreach arg,$(args_list),$(if $(or $(value $(arg)),$(call args-has-name,$0,$(arg))),'$(call args-get-name,$0,$(arg))($$$(arg)):$($(arg))'))))
args-set-names=$(if $(value vars_$1),,$(eval vars_$1:=)$(foreach arg,$(wordlist 2,$(words $(args_list)),$(args_list)),$(if $(value $(arg)),$(eval vars_$1+=$($(arg))))))
args-has-name=$(if $(value vars_$1),$(if $(word $2,$(vars_$1)),true))
args-get-name=$(if $(value vars_$1),$(if $(word $2,$(vars_$1)),$(word $2,$(vars_$1)),$(warning Argument (\$$2) was not defined for function '$1'.)?),$(warning No argument has been defined for function '$1'.)?)

#check-target: Checks whether the target has already been generated by the macro
#1: Macro name
#2: Target
#3: Target Full Name
check-target=$(if $(filter $2,$($1_targets)),true$(call debug-msg,$1,"WARNING: The dependency target of '$3' ('$2') will be ignored as it already exists. There are cases when this is expected"),)
#add-target: Adds a new target to the list of targets associated with the macro
#1: Macro name
#2: Target
add-target=$(eval $1_targets:=$(strip $($1_targets) $2))

#1: Plugin Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
define makePlugins
$(call args-set-names,$0,plgName,install,modName,modFullName,modRelPath,modAbspath)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
$(eval $1_plg_path:=include)
$(eval $1_plg_name:=$(patsubst %.mk,%,$1))
$(eval $1_plg_file:=$($1_plg_name).mk)
$(eval $($1_plg_file)_install_path:=$6)
$(eval $($1_plg_file)_install_dir:=$($1_plg_path))
$(eval $($1_plg_name).mk_plg_path:=$6)
$(eval $($1_plg_name).mk_plg_dir:=$($1_plg_path))
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
$4_$1_plg: $6/$($1_plg_path)/$($1_plg_file)
	$(AT)
clean_$4_$1_plg:
	$(AT)
)

$(eval $(call installFiles,$4_$1_plg,$6/$($1_plg_path)/$($1_plg_file),$($1_plg_path),$($1_plg_file)))
$(eval $(call cleanDistFiles,$4_$1_plg,$6/$($1_plg_path)/$($1_plg_file),$($1_plg_path),$($1_plg_file)))
$(debug-leave)
endef

unique=$(strip $(eval seen :=)$(foreach _,$1,$(if $(filter $_,${seen}),,$(eval seen += $_)))${seen})
get-libs=$(call unique,$(foreach lib,$1,$(if $($(lib)_target),$(foreach dep,$($(lib)_libs),$(call get-libs,$(dep))) $($(lib)_lib_path),-l$(lib))))
get-libs-with-path=$(patsubst %/,%,$(call unique,$(foreach lib,$1,$(if $($(lib)_target),$(foreach dep,$($(lib)_libs),$(call get-libs-with-path,$(dep))) -L$(dir $($(lib)_lib_path)) -l$(lib),-l$(lib)))))

#makeLibraries: Makes targets for c++ libraries, both local and installable.
#1: Library Name
#2: List of Library Dependencies
#3: List of Objects
#4: List of CFLAGS
#5: List of LDLAGS
#6: Bool to Install or Not
#7: Module to Make
#8: Module Full Name
#9: Module Relative Path
#10: Module Absolute Path
#11: Wait for dependency
#12: Src dir
#13: Src extension
define makeLibraries
$(call args-set-names,$0,lName,lDeps,lObjs,lCFlags,lLDFlags,install,modName,modFullName,modRelPath,modAbsPath,waitFor,srcDir,srcExt)
$(debug-enter)
#ALL_TARGETS=$(ALL_TARGETS) $(10)/lib/lib$1.so
$(if $(call must-build,$8,C++),
$(if $(call is-make-step,prepare-auto),
$(eval $1_obj_src_dir:=$(if $(12),$(12),src))
$(eval $1_obj_src_ext:=$(if $(13),$(13),$(if $($1_EXTENSION),$($1_EXTENSION),cpp)))
$(eval $1_libs:=$(call unique,$2 $(patsubst -l%,%,$($8_USER_LIB))))
$(eval $1_objs:=$3)
$(foreach obj,$3,$(eval $(obj)_cflags:=$4))
$(eval $1_ldflags:=$5)
$(eval $1_target:=$8_$1_lib)
$(eval $1_lib_path:=$(10)/lib/lib$1.so)
$(eval lib$1.so_lib_path:=$(10))
$(eval lib$1.so_lib_dir:=lib)
)
$(if $(call is-make-step,prepare-cross),
)

$(foreach obj,$3,$(eval $(call makeObjects,$(obj),$7,$8,$9,$(10),$($1_obj_src_dir),$($1_obj_src_ext),$(11))))

$(if $(call is-make-step,generate),
.PHONY: $8_$1_lib
$8_$1_lib: $(10)/lib/lib$1.so $(11)
	$(AT)
$(if $(and $(filter $($1_COMPILE),no),$(filter is_empty,$(or $($1_OBJECTS),is_empty))),,
$(10)/lib/lib$1.so: $(foreach obj,$3,$(10)/object/$(obj).o) $(call get-libs,$($1_libs)) $(11) | $(10)/lib
	$(AT)$(LD) -shared -L$(10)/lib $(call get-libs-with-path,$($1_libs)) $(L_PATH) $(LDFLAGS) $5 $(foreach obj,$3,$(10)/object/$(obj).o) -o $(10)/lib/lib$1.so
	$(AT)LD_LIBRARY_PATH=$(subst $(SPACE),:,$(strip $(patsubst -L%,%,$(patsubst -l%,,$(call get-libs-with-path,$1))))):$(LD_LIBRARY_PATH) $(call findDep,acsMakeCheckUnresolvedSymbols,script,bin,0) -w $(10)/lib/lib$1.so
)
$(if $(or $(filter clean,$(MAKECMDGOALS)),$(filter clean_dist,$(MAKECMDGOALS))),,$(eval -include $(foreach obj,$3,$(10)/object/$(obj).d)))
)

$(eval $(call genTargets,$8_$1_lib,$(10)/lib/lib$1.so,lib,lib$1.so,$6,$(foreach obj,$3,$8_$1_$(obj)_obj) $(foreach obj,$3,$8_$1_$(obj)_dep),,$8_$1_lib))
$(foreach obj,$3,$(eval $(call cleanFiles,$8_$1_$(obj)_obj,$(10)/object/$(obj).o,object,$(obj).o)))
$(foreach obj,$3,$(eval $(call cleanFiles,$8_$1_$(obj)_dep,$(10)/object/$(obj).d,object,$(obj).d)))
)
$(debug-leave)
endef

#makeKernelModules: Compile targets for kernel modules
#1: Kernel module name
#2: List of kernel module dependencies
#3: List of kernel module objects
#4: List of CFLAGS
#5: List of LDFLAGS (unused?)
#6: Bool to Install or Not
#7: Module to Make
#8: Module Full Name
#9: Module Relative Path
#10: Module Absolute Path
define makeKernelModules
$(call args-set-names,$0,kmName,kmObjs,kmCFlags,kmLDFlags,install,modName,modFullName,modRelPath,modAbsPath)
$(debug-enter)
$(if $(call must-build,$8,C++),
$(if $(call is-make-step,prepare-auto),
$1_kernel_module_auxprogs = $(if $(and $(wildcard load$1.cpp),$(wildcard unload$1.cpp)),1,)
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
.PHONY:
$8_$1_ko: $(10)/kernel/$(kernel_install_subfold)/$1.ko $(if $(and $(wildcard load$1.cpp),$(wildcard unload$1.cpp)),do_exe_load$1 do_exe_unload$1,);

$1_sources = $(patsubst %, $(10)/src/%.c, $3)
$1_kernel_module_components = $(if $(and $(filter 1,$(words $3)),$(filter $1,$(word 1,$3))),,$1-objs := $(addsuffix .o,$3))
$(10)/kernel/$(kernel_install_subfold)/$1.ko: $$($1_sources) $(10)/bin/installLKM-$1 | $(10)/kernel/$(kernel_install_subfold)
	+$(AT)if [ -f $(10)/src/Kbuild ]; then $(MAKE) -C $(KDIR) CC=$(CCKERNEL) M=$(10)/src clean ; fi
# here we have to generate the Kbuild file
	$(AT)lockfile -s 2 -r 10 $(10)/src/Kbuild.lock || echo "WARNING$(comma) ignoring lock Kbuild.lock"
	$(AT)$(ECHO) "obj-m += $1.o" > $(10)/src/Kbuild
	$(AT)$(ECHO) "$$($1_kernel_module_components)" >> $(10)/src/Kbuild
	$(AT)$(ECHO) "" >> $(10)/src/Kbuild
	$(AT)$(ECHO) "USR_INC :=  $(USR_INC)"   >> $(10)/src/Kbuild
	$(AT)$(ECHO) "EXTRA_CFLAGS := -I. -I$(10)/include -I$(10)/object $(EXTRA_CFLAGS) $($1_CFLAGS)" >> $(10)/src/Kbuild
	$(AT)$(ECHO) "KBUILD_EXTRA_SYMBOLS=\"$(LINUX_HOME)/modules/Module.symvers\"" >> $(10)/src/Kbuild
# ICT-9314: remove kbuild.lock immediately if make of kernel modules fails
ifdef MAKE_VERBOSE
	+$(AT)$(MAKE) -C $(KDIR) CC=$(CCKERNEL) M=$(10)/src V=2 modules || $(MAKE) $1_remove_kbuild_lock
else
	+$(AT)$(MAKE) -C $(KDIR) CC=$(CCKERNEL) M=$(10)/src V=0 modules || $(MAKE) $1_remove_kbuild_lock
endif
	$(AT)$(RM) $(10)/src/Kbuild.lock
	$(AT)mv $(10)/src/$1.ko $(10)/kernel/$(kernel_install_subfold)

.PHONY: clean_$8_$1_ko
clean_$8_$1_ko:
	+$(AT)if [ -f $(10)/src/Kbuild ]; then $(MAKE) -C $(KDIR) CC=$(CCKERNEL) M=$(10)/src clean ; fi
	$(AT)$(RM) $(10)/kernel/$(kernel_install_subfold)/$1.ko $(addprefix $(10)/object/,$(addsuffix .o,$2)) $(10)/src/Kbuild.lock $(10)/bin/installLKM-$1

$(10)/bin/installLKM-$1: | $(10)/bin
	@$(ECHO) "echo 'installing $1 into ${PRJTOP}/kernel/${kernel_install_subfold}..'" > $(10)/bin/installLKM-$1
	@$(ECHO) "if [ ! -d $(PRJTOP)/kernel/${kernel_install_subfold} ]; then mkdir $(PRJTOP)/kernel/${kernel_install_subfold}; fi" >> $$@
	@$(ECHO) "install -d $(PRJTOP)/kernel/${kernel_install_subfold}" >> $$@
	@$(ECHO) "install -m 664 -c $(10)/kernel/$(kernel_install_subfold)/$1.ko $(PRJTOP)/kernel/${kernel_install_subfold}" >> $$@
ifeq ($$($1_kernel_module_auxprogs),1)
	@$(ECHO) "echo 'setting uid permissions and ownership..'" >> $$@
	@$(ECHO) "chown root:root $(BIN)/load$1" >> $$@
	@$(ECHO) "chmod u+s $(BIN)/load$1" >> $$@
	@$(ECHO) "chown root:root $(BIN)/unload$1" >> $$@
	@$(ECHO) "chmod u+s $(BIN)/unload$1" >> $$@
endif
	@chmod a+x $$@

.PHONY: install_$8_$1_ko
install_$8_$1_ko: $(if $(and $(wildcard load$1.cpp),$(wildcard unload$1.cpp)),install_exe_load$1 install_exe_unload$1,) $(PRJTOP)/kernel/$(kernel_install_subfold)/$1.ko

$(PRJTOP)/kernel/$(kernel_install_subfold)/$1.ko: $(10)/kernel/$(kernel_install_subfold)/$1.ko
	-$(AT)$(ECHO) "\t$1.ko"
	-$(AT)if [ ! -d \$(PRJTOP)/kernel/\$(kernel_install_subfold) ]; then mkdir \$(PRJTOP)/kernel/\$(kernel_install_subfold) ; fi
	$(AT)if [ -f load$1.cpp ]; then \
	    if [ "$(MAKE_KERNEL_IGNORE_INSTALL_FAILURE)" != "" ]; then  \
	      if ssh -q -oPasswordAuthentication=no  root@$(HOST) $(10)/bin/installLKM-$1; then \
                echo "Kernel module $1 installed.";  \
              else \
                echo "WARNING: Kernel module $1 not installed"; \
              fi; \
            else  \
             if ssh -q -oPasswordAuthentication=no  root@$(HOST) $(10)/bin/installLKM-$1; then \
                echo "Kernel module $1 installed."; \
             else \
                echo "FAILURE: Kernel module $1 not installed. Check your SSH configuration"; \
                /bin/false;  \
             fi; \
            fi; \
        else \
	$(10)/bin/installLKM-$1; \
        fi

.PHONY: clean_dist_$8_$1_ko
clean_dist_$8_$1_ko:

$1_remove_kbuild_lock:
	$(AT)$(RM) $(10)/src/Kbuild.lock
)
)
$(debug-leave)
endef

#makeExecutables: Makes targets for c++ executables, both local and installable.
#1: Executable Name
#2: List of Library Dependencies
#3: List of Objects
#4: List of CFLAGS
#5: List of LDLAGS
#6: Bool to Install or Not
#7: Module to Make
#8: Module Full Name
#9: Module Relative Path
#10: Module Absolute Path
#11: Wait for dependency
#12: Src dir
#13: Src extension
define makeExecutables
$(call args-set-names,$0,exeName,exeDeps,exeObjs,exeCFlags,exeLDFlags,install,modName,modFullName,modRelPath,modAbsPath,waitFor,srcDir,srcExt)
$(debug-enter)
$(if $(call must-build,$8,C++),
$(if $(call is-make-step,prepare-auto),
$(foreach obj,$3,$(eval $(obj)_cflags:=$4))
$(eval $1_obj_src_dir:=$(if $(12),$(12),src))
$(eval $1_obj_src_ext:=$(if $(13),$(13),$(if $($1_EXTENSION),$($1_EXTENSION),cpp)))
$(eval $1_libs:=$(call unique,$2 $(patsubst -l%,%,$($8_USER_LIB))))
$(eval $1_target:=$8_$1_exe)
$(eval $1_exe_path:=$(10)/bin/$1)
)
$(if $(call is-make-step,prepare-cross),
)

$(foreach obj,$3,$(eval $(call makeObjects,$(obj),$7,$8,$9,$(10),$($1_obj_src_dir),$($1_obj_src_ext),$(11))))

$(if $(call is-make-step,generate),
.PHONY: $7_$1_exe
$8_$1_exe: $(10)/bin/$1
	$(AT)
$(10)/bin/$1: $(foreach obj,$3,$(10)/object/$(obj).o) $(call get-libs,$($1_libs)) | $(10)/bin
	$(AT)$(LD) -L$(10)/lib $(call get-libs-with-path,$($1_libs)) $(LDFLAGS) $5 $(L_PATH) -o $(10)/bin/$1 $(foreach obj,$3,$(10)/object/$(obj).o)
$(if $(or $(filter clean,$(MAKECMDGOALS)),$(filter clean_dist,$(MAKECMDGOALS))),,$(eval -include $(foreach obj,$3,$(10)/object/$(obj).d)))
)

$(eval $(call genTargets,$8_$1_exe,$(10)/bin/$1,bin,$1,$6,$(foreach obj,$3,$8_$1_$(obj)_obj) $(foreach obj,$3,$8_$1_$(obj)_dep),,$8_$1_exe))
$(foreach obj,$3,$(eval $(call cleanFiles,$8_$1_$(obj)_obj,$(10)/object/$(obj).o,object,$(obj).o)))
$(foreach obj,$3,$(eval $(call cleanFiles,$8_$1_$(obj)_dep,$(10)/object/$(obj).d,object,$(obj).d)))
)
$(debug-leave)
endef

#makeScripts: Makes targets for scripts, both local and installable.
#1: Script Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
define makeScripts
$(call args-set-names,$0,scrName,install,modName,modFullName,modRelPath,modAbsPath)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
$(eval $1_target:=$4_$1_scr)
$(eval $1_script_file:=$(if $(wildcard $6/src/$1.sh),$1.sh,$1))
$(eval $1_path:=$6/bin/$($1_script_file))
$(eval $1_script_path:=$6)
$(eval $1_script_dir:=bin)
)
$(if $(call is-make-step,prepare-cross),
$(eval $4_$1_scr_dep:=$(foreach dep,$($1_DEPS),$(if $($(dep)_exp),$($(dep)_exp),$(dep))))
)

$(if $(call is-make-step,generate),
$4_$1_scr: $6/bin/$1 $($4_$1_scr_dep)
	$(AT)
$6/bin/$1: $6/src/$($1_script_file) $($4_$1_scr_dep) | $6/bin
	$(AT)cp $6/src/$($1_script_file) $6/bin/$1
	$(AT)chmod +x $6/bin/$1
)

$(eval $(call genTargets,$4_$1_scr,$6/bin/$1,bin,$1,$2,,,$4_$1_scr))
$(debug-leave)
endef

#makePyScripts: Makes targets for Python scripts, both local and installable.
#1: Python Script Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Full Path
define makePyScripts
$(call args-set-names,$0,psName,install,modName,modFullName,modRelPath,modAbspath)
$(debug-enter)
$(if $(call must-build,$4,Python),
$(if $(call is-make-step,prepare-auto),
$(eval $1_pys_path:=$6)
$(eval $1_pys_dir:=bin)
)
$(if $(call is-make-step,prepare-cross),
)

$(eval $(call makePyDoc,$1,$2,$3,$4,$6))

$(if $(call is-make-step,generate),
$4_$1_pys: $6/bin/$1
	$(AT)
$6/bin/$1: $6/src/$1.py | $6/bin
	$(AT)cp $$? $$@
	$(AT)chmod +x $$@
#$4_$1_pys_doc: $6/doc/api/html/python/scripts/$1.html
#	$(AT)
#$6/doc/api/html/python/scripts/$1.html: $6/src/$1.py | $6/doc/api/html/python/scripts
#	$(AT)PYTHONPATH=$(PYTHONPATH):$6/src pydoc -w $1
#	$(AT)mv $6/src/$1.html $6/doc/api/html/python/scripts/$1.html
)

$(eval $(call genTargets,$4_$1_pys,$6/bin/$1,bin,$1,$2,,,$4_$1_pys))
)
$(debug-leave)
endef

#1: Python File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#7: Suffix
define makePyDoc
$(call args-set-names,$0,pyDocName,install,modName,modFullName,modRelPath,modAbsPath,suffix)
$(debug-enter)
$(if $(call must-build,$4,Python),
$(if $(call is-make-step,prepare-auto),
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
)
)
$(debug-leave)
endef

#makeTclScripts: Makes targets for TCL scripts, both local and installable.
#1: TCL Script Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
define makeTclScripts
$(call args-set-names,$0,tclScrName,install,modName,modFullName,modRelPath,modAbsPath)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
$4_$1_tsc: $6/bin/$1
	$(AT)
$6/bin/$1: $(addprefix $6/src/,$(addsuffix .tcl,$($1_OBJECTS))) $(if $(acsMakeTclScript_target),$(acsMakeTclScript_path),) | $6/bin
	$(AT)$(if $(acsMakeTclScript_target),$(acsMakeTclScript_path),acsMakeTclScript) "$(TCL_CHECKER)" "$(WISH)" "$($1_TCLSH)" "$1" "$(addprefix $6/src/,$($1_OBJECTS))" "$($1_LIBS)" "$6" $(if $(OUTPUT),> $(OUTPUT) 2>&1,)
	$(AT)chmod +x $$@
)

$(eval $(call genTargets,$4_$1_tsc,$6/bin/$1,bin,$1,$2,,,$4_$1_tsc))
$(debug-leave)
endef

#makeTclLibraries: Makes targets for TCL libraries, both local and installable.
#1: TCL Library Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
define makeTclLibraries
$(call args-set-names,$0,tclLibName,install,modName,modFullName,modRelPath,modAbsPath)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
$4_$1_tlb: $6/lib/lib$1.tcl
	$(AT)
$6/lib/lib$1.tcl: $(addprefix $6/src/,$(addsuffix .tcl,$($1_OBJECTS))) $(if $(acsMakeTclLib_target),$(acsMakeTclLib_path),) | $6/lib
	$(AT)$(if $(acsMakeTclLib_target),$(acsMakeTclLib_path),acsMakeTclLib) "$(TCL_CHECKER)"  "$1" "$(addprefix $6/src/,$($1_OBJECTS))" "$6" $(if $(OUTPUT),> $(OUTPUT) 2>&1,)
)

$(eval $(call genTargets,$4_$1_tlb,$6/lib/lib$1.tcl,lib,lib$1.tcl,$2,,,$4_$1_tlb))
$(debug-leave)
endef


#genTargets: Generates clean, install and clean_dist targets.
#1: Target Name
#2: Associated File
#3: Associated Directory
#4: File Name
#5: Bool to Install or Not
#6: List of Target's Dependencies
#7: Bool to Install Dependencies or Not
#8: Install dependency to all
#9: Avoid cleaning from local files
#10: List of target's dependencies not to be installed
define genTargets
$(call args-set-names,$0,targetName,targetFile,targetDir,fileName,install,targetDeps,depsInstall,InstallDepToAll,cleanLocal,targetDepsNoInstall)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
)

$(eval $(call cleanFiles,$1,$2,$3,$4,$6 $(10),,$9))
$(if $(filter true,$5),$(eval $(call installFiles,$1,$2,$3,$4,$6,$7,$8)),)
$(if $(filter true,$5),$(eval $(call cleanDistFiles,$1,$2,$3,$4,$6,$7)),)
$(debug-leave)
endef

#installFiles: Generates targets to install in installation areas.
#1: Target Name
#2: File to Install
#3: Directory
#4: File Name
#5: Dependencies
#6: Bool to Install Dependencies or Not
#7: Install dependency to all
define installFiles
$(call args-set-names,$0,targetName,targetFile,targetDir,fileName,targetDeps,depsInstall,InstallDepToAll)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
.PHONY: install_$1
install_$1: $7 $(if $4,$(INSTDIR)/$3/$4,) $(if $(filter true,$6),$(foreach e,$5,install_$e),)
	$(AT)

$(if $4,$(if $(call check-target,$0,$(INSTDIR)/$3/$4,$1),,$(call add-target,$0,$(INSTDIR)/$3/$4)
$(INSTDIR)/$3/$4: $2 | $(INSTDIR)/$3
	$(AT)$$(if $$(wildcard $(INSTDIR)/$3/$4),$(if $(filter /,$(patsubst %/,/,$2)),rm -rf $(INSTDIR)/$3/$4,rm -f $(INSTDIR)/$3/$4),)
	$(AT)$(if $(filter /,$(patsubst %/,/,$2)),cp -r $2 $(INSTDIR)/$3/$4,cp $2 $(INSTDIR)/$3/$4)
),)
)
$(debug-leave)
endef

#cleanFiles: Generates targets to clean from local areas.
#1: Target Name
#2: File to Clean
#3: Directory
#4: File Name
#5: Dependencies
#6: Bool to Install Dependencies or Not.
#7: Bool to avoid cleaning local file
define cleanFiles
$(call args-set-names,$0,targetName,targetFile,targetDir,fileName,targetDeps,depsInstall,cleanLocal)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
.PHONY: clean_$1
clean_$1: $(foreach f,$5,clean_$(f))
	$(AT)$(if $(findstring true,$7),,$(if $4,$$(if $$(wildcard $2),rm -rf $2,),))
)
$(debug-leave)
endef

#cleanDistFiles: Generates targets to clean from installation areas.
#1: Target Name
#2: File to Clean
#3: Directory
#4: File Name
#5: Dependencies
#6: Bool to Install Dependencies or Not.
define cleanDistFiles
$(call args-set-names,$0,targetName,targetFile,targetDir,fileName,targetDeps,depsInstall)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
.PHONY: clean_dist_$1
clean_dist_$1: clean_$1 $(if $(findstring true,$6),$(foreach e,$5,clean_dist_$e),)
	$(AT)$$(if $$(wildcard $(INSTDIR)/$3/$4),$(if $4,rm -rf $(INSTDIR)/$3/$4,),)
)
$(debug-leave)
endef

#1: Python Module Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: Wait for dependency
#8: Relative directory to look for Python source
define makePyModules
$(call args-set-names,$0,pmName,install,modName,modFullName,modRelPath,modAbspath,waitFor,srcDir)
$(debug-enter)
$(if $(call must-build,$4,Python),
$(if $(call is-make-step,prepare-auto),
$(eval $1_pym_src:=$(if $8,$6/$8,$6/src))
$(eval $1_pym_path:=$6)
$(eval $1_pym_dir:=lib)
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
.INTERMEDIATE: $4_$1_pym
$4_$1_pym: $6/$(PYTHON_SITE_PACKAGES)/$(call pycache,$1.py)
	$(AT)
$6/$(PYTHON_SITE_PACKAGES)/$(call pycache,$1.py): $6/$(PYTHON_SITE_PACKAGES)/$1.py | $(if $(call pycachedir,$1.py),$6/$(PYTHON_SITE_PACKAGES)/$(call pycachedir,$1.py),)
	$(AT)python -m compileall $$? $(PYTHON_OUTPUT)
$(if $(call pycachedir,$1.py),$(if $(call check-target,$0,$6/$(PYTHON_SITE_PACKAGES)/$(call pycachedir,$1.py),$1),,$(call add-target,$0,$6/$(PYTHON_SITE_PACKAGES)/$(call pycachedir,$1.py))
$6/$(PYTHON_SITE_PACKAGES)/$(call pycachedir,$1.py): | $6/$(PYTHON_SITE_PACKAGES)
	$(AT)$(if $(wildcard $6/$(PYTHON_SITE_PACKAGES)/$(call pycachedir,$1.py)),,mkdir $6/$(PYTHON_SITE_PACKAGES)/$(call pycachedir,$1.py))
),)
$6/$(PYTHON_SITE_PACKAGES)/$1.py: $($1_pym_src)/$1.py | $6/$(PYTHON_SITE_PACKAGES)
	$(AT)cp $$? $$@

#$4_$1_pym_doc: $6/doc/api/html/python/modules/$1.html
#	$(AT)
#$6/doc/api/html/python/modules/$1.html: $($1_pym_src)/$1.py | $6/doc/api/html/python/modules
#	$(AT)PYTHONPATH=$(PYTHONPATH): $($1_pym_src) pydoc -w $1
#	$(AT)mv $1.html $6/doc/api/html/python/modules/$1.html
)

$(eval $(call genTargets,$4_$1_pym,$6/$(PYTHON_SITE_PACKAGES)/$1.py,$(PYTHON_SITE_PACKAGES),$1.py,$2,$4_$1_pym_pyc,true,$4_$1_pym))
$(eval $(call genTargets,$4_$1_pym_pyc,$6/$(PYTHON_SITE_PACKAGES)/$(call pycache,$1.py),$(PYTHON_SITE_PACKAGES)$(if $(call pycachedir,$1.py),/$(call pycachedir,$1.py),),$(notdir $(call pycache,$1.py)),$2))
)
$(debug-leave)
endef

#1: IDL File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: Wait for dependency
define makeIdlDependencies
$(call args-set-names,$0,idlName,install,modName,modFullName,modRelPath,modAbspath,waitFor)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
$(eval $1_idl_module:=$4)
$(eval $1_idl_idls:=$($1_IDLS))
$(eval $1_path:=$6/idl/$1.idl)
$(eval $1.idl_idl_path:=$6)
$(eval $1.idl_idl_dir:=idl)
$(eval $1.idl_or_midl:=$(if $(wildcard $6/idl/$1.midl),midl,$(if $(wildcard $6/idl/$1.idl),idl,)))
$(if $($1_idl_prefix),,$(if $($1.idl_or_midl),$(eval $1_idl_prefix:=$(sort $(shell grep "^#pragma *prefix" $6/idl/$1.$($1.idl_or_midl) |awk '{print $$3}' |sed 's/"\(.*\.\)*\(.*\)"/\2/'))),$(error It was not possible to obtain IDL prefix. Check that IDL, MIDL or XML files exist. If custom mechanism, check that it fills $1_idl_prefix variable correctly in module $4)))
$(if $($1_idl_mods),,$(if $($1.idl_or_midl),$(eval $1_idl_mods:=$(sort $(shell grep "^ *module" $6/idl/$1.$($1.idl_or_midl) |awk '{print $$2}'))),$(error It was not possible to obtain IDL list of modules. Check that IDL, MIDL or XML files exist. If custom mechanism, check that it fills $1_idl_mods variable correctly)))
$(if $($1_idl_prefix),,$(eval $1_idl_prefix:=$($1_idl_mods)))
$(eval $4_$1_idl_lang:=$(if $(call must-build,$4,C++),$4_$1_idl_c++) $(if $(call must-build,$4,Python),$4_$1_idl_py) $(if $(call must-build,$4,Java),$4_$1_idl_java))
$(foreach mod,$($1_idl_mods),$(eval idl_$(mod)_idl_list:=$(call unique,$(idl_$(mod)_idl_list) $1.idl)))
)
$(if $(call is-make-step,prepare-cross),
)

$(eval $(call makeIdlC++,$1,$2,$3,$4,$5,$6,$7))
$(eval $(call makeIdlJava,$1,$2,$3,$4,$5,$6,$7))
$(eval $(call makeIdlPy,$1,$2,$3,$4,$5,$6,$7))

$(if $(call is-make-step,generate),
.INTERMEDIATE: $4_$1_idl
$4_$1_idl: $($4_$1_idl_lang) $7
$(if $(wildcard $6/idl/$1.midl),$6/idl/$1.idl: $6/idl/$1.midl $(foreach dep,$($1_idl_idls),$(call findDep,$(dep).idl,idl,idl,0)) $7
	$(AT)echo "== (preprocessing MIDL => IDL) $6/idl/$1.midl"
	$(AT)JacPrep $6/idl/$1.midl "-I$(JACORB_HOME)/idl/jacorb -I$(JACORB_HOME)/idl/omg -I$6/idl $$(call getIdlUnmetDeps,$$@,$$<,$4,$6) $(MK_IDL_PATH) $(MIDL_FLAGS)" > $6/idl/$1.idl
)
$6/object/$1.id: $6/idl/$1.idl $(foreach dep,$($1_idl_idls),$(call findDep,$(dep).idl,idl,idl,0)) $7 | $6/object
	$(AT)$(CCDEP) -xc++ -I$6/idl $$(call getIdlUnmetDeps,$$@,$$<,$4,$6) $(CXXFLAGS) $($4_USER_CXXFLAGS) $(MK_IDL_PATH) $$($$(patsubst %.id,%,$$(lastword $$(subst /, ,$$@)))_cflags) $$< | \
sed -e "s'$$*\.o'$(foreach ext,$($1_IDL_EXTENSIONS),$6/object/$$*$(ext)) $6/object/$$*.id '" -e "s':': $6/src/module.mk '" > $$@; if [ ! -s $$@ ]; then $(RM) $$@; fi
$(if $(or $(filter clean,$(MAKECMDGOALS)),$(filter clean_dist,$(MAKECMDGOALS))),,$(eval -include $6/object/$1.id))
)

$(eval $(call genTargets,$4_$1_idl,$6/idl/$1.idl,idl,$1.idl,$2,$($4_$1_idl_lang),true,$4_$1_idl,true))
$(debug-leave)
endef

#1 Variable name
#2 Type
#3 Dependency Type
define expandDependencies
$(call args-set-names,$0,varName,varType,depType)$(debug-enter)$(foreach dep,$($1_$2_$3),$(strip $(dep) $(call expandDependencies,$(dep),$2,$3)))$(debug-leave)
endef

#1: IDL File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: Wait for dependency
define makeIdlC++
$(call args-set-names,$0,idlName,install,modName,modFullName,modRelPath,modAbspath,waitFor)
$(debug-enter)
$(if $(call must-build,$4,C++),
$(if $(call is-make-step,prepare-auto),
$(eval $1_IDL_EXTENSIONS:=$(call unique,$(BASE_IDL_EXTENSIONS) $($1_IDL_EXTENSIONS) $($4_IDL_EXTENSIONS)))
$(eval $1_TAO_IDLFLAGS:=$(call unique,$($1_TAO_IDLFLAGS) $($4_TAO_IDLFLAGS)))
$(eval $1Stubs_OBJECTS:=$1C $1S $($1Stubs_OBJECTS))
$(eval $1Stubs_LIBS:= $(addsuffix Stubs,$($1_IDLS)) $($1Stubs_LIBS))
$(eval TAOStubsLIBS:=TAO TAO_PortableServer)
)
$(if $(call is-make-step,prepare-cross),
)

$(eval $(call makeLibraries,$1Stubs,$($1Stubs_LIBS) $(TAOStubsLIBS),$($1Stubs_OBJECTS),$($1Stubs_CFLAGS),$($1Stubs_LDFLAGS),true,$3,$4,$5,$6,$7 $(addprefix $6/object/$1,$($1_IDL_EXTENSIONS)) $(foreach dep,$(call expandDependencies,$1,idl,idls),$(call findDep,$(dep)C.h,include,object,0,include) $(call findDep,$(dep)C.inl,include,object,0,include)) $(foreach dep,$(call expandDependencies,$1,idl,idls),$(call findDep,$(dep)S.h,include,object,0,include)),object,cpp))
$(foreach ext,$(filter %.h %.inl,$($1_IDL_EXTENSIONS)),$(eval $(call makeIncludes,$1$(ext),true,$3,$4,$5,$6,object,$7 $6/object/$1$(ext))))

$(if $(call is-make-step,generate),
.INTERMEDIATE: $4_$1_idl_c++
$4_$1_idl_c++: $(addprefix $6/object/$1,$($1_IDL_EXTENSIONS)) $6/lib/lib$1Stubs.so $7
.INTERMEDIATE: $(addprefix $4_$1_idl_c++_,$($1_IDL_EXTENSIONS))
$(addprefix $4_$1_idl_c++_,$($1_IDL_EXTENSIONS)): $$(addprefix $6/object/$1,$$(notdir $$@)) $7
$(addprefix $6/object/$1,$($1_IDL_EXTENSIONS)): $4_$1_idl_c++_gen $7 | $6/object
$6/object/$1C.h: $(foreach dep,$(call expandDependencies,$1,idl,idls),$(call findDep,$(dep)C.h,include,object,0,include) $(call findDep,$(dep)C.inl,include,object,0,include))
$6/object/$1S.h: $(foreach dep,$(call expandDependencies,$1,idl,idls),$(call findDep,$(dep)S.h,include,object,0,include))
.INTERMEDIATE: $4_$1_idl_c++_gen
$4_$1_idl_c++_gen: $6/idl/$1.idl $6/object/$1.id $(foreach dep,$(call expandDependencies,$1,idl,idls),$(if $($(dep)_idl_module),$($(dep)_idl_module)_$(dep)_idl_c++,$(dep).idl)) $7 | $6/object
	$(AT)$(TAO_IDL) -Sg -I$6/idl $$(call getIdlUnmetDeps,$$<,$$<,$4,$6) $(MK_IDL_PATH) $(TAO_MK_IDL_PATH) -o $6/object $($1_TAO_IDLFLAGS) $$<
)

$(eval $(call genTargets,$4_$1_idl_c++,,,,$2,$4_$1Stubs_lib $(addsuffix _inc,$(addprefix $4_$1,$(filter %.h %.inl,$($1_IDL_EXTENSIONS)))),true,$4_$1_idl_c++,,$(addprefix $4_$1_idl_c++_,$($1_IDL_EXTENSIONS)) $4_$1_idl_dep))
$(foreach ext,$(filter %.cpp,$($1_IDL_EXTENSIONS)),$(eval $(call genTargets,$4_$1_idl_c++_$(ext),$6/object/$1$(ext),object,$1$(ext),false,,,$4_$1_idl_c++_$(ext))))
$(foreach ext,$(filter %.h %.inl,$($1_IDL_EXTENSIONS)),$(eval $(call cleanFiles,$4_$1_idl_c++_$(ext),$6/object/$1$(ext),include,$1$(ext))))
$(call cleanFiles,$4_$1_idl_dep,$6/object/$1.id,object,$1.id)
)
$(debug-leave)
endef

#1: IDL File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: Wait for dependency
define makeIdlJava
$(call args-set-names,$0,idlName,install,modName,modFullName,modRelPath,modAbspath,waitFor)
$(debug-enter)
$(if $(call must-build,$4,Java),
$(if $(call is-make-step,prepare-auto),
$(eval $1_EXTRAS:=$($1_EXTRAS))
$(eval $1_DIRS:=$($1_idl_prefix) $($1_DIRS))
$(eval $1_ENDORSED:=$($1_ENDORSED))
$(eval $1_JARS:=$($1_JARS) $($1_IDLS))
)
$(if $(call is-make-step,prepare-cross),
)

$(eval $(call makeJarFiles,$1,false,$2,$3,$4,$5,$6,$7 $4_$1_idl_java_rule $(foreach dep,$(call expandDependencies,$1,idl,idls),$(call findDep,$(dep).jar,jar,lib,0,lib)),object/$1))

$(if $(call is-make-step,generate),
.INTERMEDIATE: $4_$1_idl_java
$4_$1_idl_java: $4_$1_idl_java_rule $6/lib/$1.jar

.INTERMEDIATE: $4_$1_idl_java_rule
$4_$1_idl_java_rule: $6/object/$1/$1.done

$6/object/$1.idl: $6/idl/$1.idl $(foreach dep,$($1_idl_idls),$(if $(filter $($(dep).idl_idl_path),$6),$6/object/$(dep).idl)) $7 | $6/object/$1/src
	$(AT)echo "== (preprocessing) $1"
	$(AT)JacPrep $6/idl/$1.idl "-I$(JACORB_HOME)/idl/jacorb -I$(JACORB_HOME)/idl/omg -I$6/idl $$(call getIdlUnmetDeps,$$<,$$<,$4,$6) $(MK_IDL_PATH)" > $6/object/$1.idl
.INTERMEDIATE: $4_$1_idl_java_gen
$(addprefix $6/object/$1/,$1.done $(addprefix src/,$($1_idl_prefix))): $4_$1_idl_java_gen
$4_$1_idl_java_gen: $6/object/$1.idl $6/object/$1.id $(foreach dep,$(call expandDependencies,$1,idl,idls),$(if $($(dep)_idl_module),$($(dep)_idl_module)_$(dep)_idl_java $(if $(filter $($(dep)_idl_module),$($1_idl_module)),$6/object/$(dep).idl),$(dep).idl)) $7 | $6/object/$1/src
	$(AT)echo "== IDL Compiling for JacORB (Java): $1"
	$(AT)$(JAVA_IDL) -auto_prefix -I$6/object $$(call getIdlUnmetDeps,$$<,$$<,$4,$6) $(JACORB_MK_IDL_PATH) $(MK_IDL_PATH) -d $6/object/$1/src $6/object/$1.idl
	$(AT)touch $6/object/$1/$1.done
)

$(eval $(call genTargets,$4_$1_idl_java,,,,$2,$4_$1_jar,true,$4_$1_idl_java,,$4_$1_idl_java_idl $4_$1_idl_java_dir))
$(call cleanFiles,$4_$1_idl_java_idl,$6/object/$1.idl,object,$1.idl)
$(call cleanFiles,$4_$1_idl_java_dir,$6/object/$1,object,$1)
)
$(debug-leave)
endef

#1: IDL File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: Wait for dependency
define makeIdlPy
$(call args-set-names,$0,idlName,install,modName,modFullName,modRelPath,modAbspath,waitFor)
$(debug-enter)
$(if $(call must-build,$4,Python),
$(if $(call is-make-step,prepare-auto),
)
$(if $(call is-make-step,prepare-cross),
)

$(eval $(call makePyModules,$1_idl,true,$3,$4,$5,$6,$7 $4_$1_idl_py_rule,object))
$(foreach mod,$($1_idl_mods),$(eval $(call makePyPackages,$(mod),true,$3,$4_$1,$5,$6,$7 $4_$1_idl_py_rule,object)))
$(foreach mod,$($1_idl_mods),$(eval $(call makePyPackages,$(mod)__POA,true,$3,$4_$1,$5,$6,$7 $4_$1_idl_py_rule,object)))

$(if $(call is-make-step,generate),
.INTERMEDIATE: $4_$1_idl_py
$4_$1_idl_py: $4_$1_idl_py_rule $4_$1_idl_pym $(foreach mod,$($1_idl_mods),$4_$1_$(mod)_pyp $4_$1_$(mod)__POA_pyp)
.INTERMEDIATE: $4_$1_idl_py_rule
$4_$1_idl_py_rule: $6/object/$1_idl.py $(foreach mod,$($1_idl_mods),$6/object/$(mod)/__init__.py $6/object/$(mod)__POA/__init__.py)
.INTERMEDIATE: $4_$1_idl_py_gen
$6/object/$1_idl.py $(addprefix $6/object/,$($1_idl_mods) $(addsuffix __POA,$($1_idl_mods))) $(foreach mod,$($1_idl_mods),$6/object/$(mod)/__init__.py $6/object/$(mod)__POA/__init__.py): $4_$1_idl_py_gen
$4_$1_idl_py_gen: $6/idl/$1.idl $($1_IDLprereq) $7
	$(AT)lockfile -s 1 -r 20 $(foreach mod,$($1_idl_mods),$6/object/.make-$(mod)-OmniOrb.lock) || echo "WARNING$(comma) ignoring lock $(foreach mod,$($1_idl_mods),$6/object/.make-$(mod)-OmniOrb.lock)"
	$(AT)echo "== IDL Compiling for OmniOrb (Python): $1"
	$(AT)$(OMNI_IDL) -I$(OMNI_ROOT)/idl/ -I$6/idl $$(call getIdlUnmetDeps,$$<,$$<,$4,$6) $(MK_IDL_PATH) $(TAO_MK_IDL_PATH) -bacs_python -C $6/object/ $(foreach prereq,$($1_IDLprereq),-I$(dir $(prereq))) $6/idl/$1.idl
	$(foreach mod,$($1_idl_mods),
	$(AT)python -c "from acs_python import updateInit; updateInit('$6/object', ['$(mod)'], ['$1_idl'$(call unique,$(subst $(space)$(comma),$(comma),$(foreach idl,$(idl_$(mod)_idl_list),$(comma) '$(subst .,_,$(idl))')))])"
	)
	$(AT)$(RM) -f $(foreach mod,$($1_idl_mods),$6/object/.make-$(mod)-OmniOrb.lock)
)

$(eval $(call genTargets,$4_$1_idl_py,,,,$2,$4_$1_idl_pym $(foreach mod,$($1_idl_mods),$4_$1_$(mod)_pyp $4_$1_$(mod)__POA_pyp),true,,,$4_$1_idl_py_idl $(foreach mod,$($1_idl_mods),$4_$1_idl_py_$(mod) $4_$1_idl_py_$(mod)__POA)))
$(call cleanFiles,$4_$1_idl_py_idl,$6/object/$1_idl.py,object,$1_idl.py)
$(foreach mod,$($1_idl_mods),$(call cleanFiles,$4_$1_idl_py_$(mod),$6/object/$(mod),object,$(mod)))
$(foreach mod,$($1_idl_mods),$(call cleanFiles,$4_$1_idl_py_$(mod)__POA,$6/object/$(mod)__POA,object,$(mod)__POA))
)
$(debug-leave)
endef

#1: XSDBind File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: List of XSD Include Files
#8: Wait for deppendencies
define makeXsdBind
$(call args-set-names,$0,xsdName,install,modName,modFullName,modRelPath,modAbspath,waitFor)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
$(eval $1.xml_xsd_path:=$6)
$(eval $1.xml_xsd_dir:=idl)
$(eval $1.xml_entities:=$(patsubst schemaName="%",%,$(shell xmllint --xpath "//EntitySchema/@schemaName" $6/idl/$1.xml)))
$(foreach ent,$($1.xml_entities),$(eval $(ent)_xsd_path:=$6)$(eval $(ent)_xsd_dir:=$(patsubst ../%,%,$(shell xmllint --xpath "string(//EntitySchema[@schemaName='$(ent)']/@relativePathSchemafile)" $6/idl/$1.xml)))$(if $($(ent)_xsd_dir),,$(eval $(ent)_xsd_dir:=idl)))
$(eval $1_xsd_pkgs:=$(call unique,$(foreach pkg,$(patsubst jPackage="%",%,$(shell xmllint --xpath "//XmlNamespace2JPackage/@jPackage" $6/idl/$1.xml)),$(firstword $(subst .,$(SPACE),$(pkg))))))
$(if $($1_xsd_pkgs),,$(eval $1_xsd_pkgs:=alma))
$(eval $4_$1_xsd_lang:=$(if $(call must-build,$4,Python),$4_$1_xsd_py) $(if $(call must-build,$4,Java),$4_$1_xsd_java))
)
$(if $(call is-make-step,prepare-cross),
)

$(eval $(call makeXsdBindJava,$1,$2,$3,$4,$5,$6,$7,$8))
$(eval $(call makeXsdBindPy,$1,$2,$3,$4,$5,$6,$7,$8))

$(if $(call is-make-step,generate),
.INTERMEDIATE: $4_$1_xsd
$4_$1_xsd: $4_$1_xsd_xml $4_$1_xsd_xsd $($4_$1_xsd_lang)
$4_$1_xsd_xml:
$4_$1_xsd_xsd:
)

$(eval $(call genTargets,$4_$1_xsd,,,,$2,$4_$1_xsd_xml $4_$1_xsd_xsd $($4_$1_xsd_lang),true,$4_$1_xsd,true))
$(eval $(call genTargets,$4_$1_xsd_xml,$6/idl/$1.xml,idl,$1.xml,$2,,true,,true))
$(if $(wildcard $6/idl/$1.xsd),$(eval $(call genTargets,$4_$1_xsd_xsd,$6/idl/$1.xsd,idl,$1.xsd,$2,$($4_$1_xsd_lang),true,,true)),$(eval $(call genTargets,$4_$1_xsd_xsd,,,,$2,,true,,true)))
$(debug-leave)
endef

#1: XSDBind File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: List of XSD Include Files
#8: Wait for deppendencies
define makeXsdBindJava
$(call args-set-names,$0,xsdName,install,modName,modFullName,modRelPath,modAbspath,waitFor)
$(debug-enter)
$(if $(call must-build,$4,Java),
$(if $(call is-make-step,prepare-auto),
$(eval $1_EXTRAS:=$($1_EXTRAS))
$(eval $1_DIRS:=$($1_xsd_pkgs) $($1_DIRS))
$(eval $1_JARS:=$($1_JARS) $7)
$(eval $1_EXT_JARS:=$($1_EXT_JARS) xercesImpl)
$(eval $1_ENDORSED:=$($1_ENDORSED))
)
$(if $(call is-make-step,prepare-cross),
$(eval $1_DEPS:=$($1_DEPS) $6/object/$1/src/alma)
)

$(eval $(call makeJarFiles,$1,false,$2,$3,$4,$5,$6,$8 $6/object/$1/src/alma,object/$1))

$(if $(call is-make-step,generate),
.INTERMEDIATE: $4_$1_xsd_java
$4_$1_xsd_java: $6/object/$1/src/alma $4_$1_jar $8

.INTERMEDIATE: $4_$1_xsd_java_gen
$6/object/$1/src/alma: $4_$1_xsd_java_gen

$4_$1_xsd_java_gen: $6/idl/$1.xml $(foreach ent,$($1.xml_entities),$6/$($(ent)_xsd_dir)/$(ent)) $8 | $6/object $6/object/$1
	$(AT)java -classpath $(call findDep,commons-logging-1.2.jar,jar,lib,0)$(PATH_SEP)$(call findDep,commons-lang3-3.12.0.jar,jar,lib,0)$(PATH_SEP)$(call findDep,jACSUtil.jar,jar,lib,0)$(PATH_SEP)$(call findDep,castor-1.4.1-acs.jar,jar,lib,0)$(PATH_SEP)$(call findDep,xmljbind.jar,jar,lib,0)$(PATH_SEP)$(call findDep,xercesImpl-2.12.2-acs.jar,jar,lib,0) -DACS.schemaconfigfiles="$7" alma.tools.entitybuilder.CastorBuilder $6/idl/$1.xml $6/object/$1/src -I$6/idl $(addprefix -I,$(foreach xml,$7,$(dir $(call findDep,$(xml).xml,xsd,idl,0)))) $(MK_IDL_PATH)
)

$(eval $(call genTargets,$4_$1_xsd_java,,,,$2,$4_$1_jar,true,$4_$1_xsd_java,,$4_$1_xsd_java_dir))
$(eval $(call cleanFiles,$4_$1_xsd_java_dir,$6/object/$1,object,$1))
)
$(debug-leave)
endef

#1: XSDBind File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: List of XSD Include Files
#8: Wait for deppendencies
define makeXsdBindPy
$(call args-set-names,$0,xsdName,install,modName,modFullName,modRelPath,modAbspath,waitFor)
$(debug-enter)
$(if $(call must-build,$4,Python),
$(if $(call is-make-step,prepare-auto),
$(eval $1.wxs_xsd_path:=$6)
$(eval $1.wxs_xsd_dir:=$(PYTHON_SITE_PACKAGES))
$(eval $1_PYMS:=$($1_PYMS) $(subst .xsd,,$($1.xml_entities)))
)
$(if $(call is-make-step,prepare-cross),
)

$(eval $(call makePyPackages,$1,$2,$3,$4,$5,$6,$8 $4_$1_xsd_py,object/python))

$(if $(call is-make-step,generate),
.INTERMEDIATE: $4_$1_xsd_py
$4_$1_xsd_py: $6/$(PYTHON_SITE_PACKAGES)/$1.wxs $8

.INTERMEDIATE: $4_$1_xsd_py_gen
$6/object/python/$1 $(addprefix $6/object/python/$1/,$(subst .xsd,.py,$($1.xml_entities) __init__.py)) $6/object/python/$1.wxs: $4_$1_xsd_py_gen

$4_$1_xsd_py_gen: $(call findDep,generateXsdPythonBinding,pys,bin,0) $(call findDep,xmlpybind,pyp,$(PYTHON_SITE_PACKAGES),0)/EntitybuilderSettings.py $6/idl/$1.xml $(foreach ent,$($1.xml_entities),$6/$($(ent)_xsd_dir)/$(ent)) $(foreach inc,$7,$(call findDep,$(inc).wxs,xsd,.wxs,xsd,$(PYTHON_SITE_PACKAGES),0)) $8 | $6/object
	$(AT)PYTHONPATH=$(patsubst %/,%,$(dir $(call findDep,xmlpybind,pyp,$(PYTHON_SITE_PACKAGES),0))):$(PYTHONPATH) $$< $1 $6 object/python $(subst $(SPACE),:,$(strip $(foreach inc,$7,$(patsubst %/,%,$(dir $(call findDep,$(inc).wxs,xsd,$(PYTHON_SITE_PACKAGES),0))))))

$6/$(PYTHON_SITE_PACKAGES)/$1.wxs: $6/object/python/$1.wxs $8 | $6/$(PYTHON_SITE_PACKAGES)
	$(AT)$$(if $$(wildcard $6/object/python/$1.wxs),cp $6/object/python/$1.wxs $6/$(PYTHON_SITE_PACKAGES)/$1.wxs)
)

$(eval $(call genTargets,$4_$1_xsd_py,,,,$2,$4_$1_pyp,true,$4_$1_xsd_py,,$4_$1_xsd_py_obj_wxs $4_$1_xsd_py_lib_wxs $4_$1_xsd_py_dir))
$(eval $(call cleanFiles,$4_$1_xsd_py_obj_wxs,$6/object/python/$1.wxs,object/python,$1.wxs))
$(eval $(call cleanFiles,$4_$1_xsd_py_lib_wxs,$6/$(PYTHON_SITE_PACKAGES)/$1.wxs,$(PYTHON_SITE_PACKAGES),$1.wxs))
$(eval $(call cleanFiles,$4_$1_xsd_py_dir,$6/object/python,object,python))
)
$(debug-leave)
endef

#1: Name
#2: Type
#3: Dir local
#4: If on search path. 0: return complete. 1: return name. 2: return empty
#5: Dir install !!To check in {INTROOT,INTLIST,ACSROOT}/<dir>. !TODO; Swap with previous argument!
define findDep
$(call args-set-names,$0,depName,depType,depDir,returnMode,acsDir)$(debug-enter)$(eval findDep_dir:=$(if $5,$5,$3))$(if $($1_$2_path),$($1_$2_path)/$(if $($1_$2_dir),$($1_$2_dir),$3)/$1,$(eval file:=$(subst #,_,$(shell searchFile $(findDep_dir)/$1)))$(if $(filter $(file),_error_),$1,$(eval $1_$2_path:=$(file))$(eval $1_$2_dir:=$(findDep_dir))$(if $(filter $4,0),$(file)/$(findDep_dir)/$1,$(if $(filter $4,1),$1,))))$(debug-leave)
endef

#1: Target
#2: Source File
#3: Module Full Name
#4: Module Absolute Path
#5: Additional include paths
#6: Recursive include paths
define getCppUnmetDeps
$(call args-set-names,$0,target,srcFile,modFullName,modAbsPath,includePaths,recIncludePaths)$(debug-enter)$(eval deps:=$(shell gcc -M -MG -ansi -I$4/include -I$4/object $5 $6 $(CXXFLAGS) $($3_USER_CXXFLAGS) $(I_PATH) $($(basename $(lastword $(subst /, ,$1)))_cflags) $2 |grep "^ " |sed "s' /[^ ]*''g" |grep -v "^ *\\\\"| sed "s/\\\\//"))$(eval incs:=$(filter-out $6,$(strip $(subst -I./,,$(sort $(foreach dep,$(deps),-I$(dir $(call findDep,$(dep),include,object,2)) -I$(dir $(call findDep,$(dep),include,include,2))))))))$(if $(incs),$(strip $(incs) $(call getCppUnmetDeps,$1,$2,$3,$4,$5,$(sort $6 $(incs)))),$(strip $6))$(debug-leave)
endef

define getCppUnmetIncs
$(call args-set-names,$0,target,srcFile,modFullName,modAbsPath,includePaths,recIncludePaths)$(debug-enter)$(eval deps:=$(shell gcc -M -MG -ansi -I$4/include -I$4/object $5 $6 $(CXXFLAGS) $($3_USER_CXXFLAGS) $(I_PATH) $($(basename $(lastword $(subst /, ,$1)))_cflags) $2 |grep "^ " |sed "s' /[^ ]*''g" |grep -v "^ *\\\\"| sed "s/\\\\//"))$(eval incs:=$(filter-out $6,$(strip $(subst -I./,,$(sort $(foreach dep,$(deps),-I$(dir $(call findDep,$(dep),include,object,2)) -I$(dir $(call findDep,$(dep),include,include,2))))))))$(if $(incs),$(strip $(foreach dep,$(deps),$(call findDep,$(dep),include,object,2) $(call findDep,$(dep),include,include,2)) $(call getCppUnmetIncs,$1,$2,$3,$4,$5,$(sort $6 $(incs)))))$(debug-leave)
endef

#1: Target
#2: Source File
#3: Module Full Name
#4: Module Absolute Path
#5: Additional include paths
define getCppDeps
$(call args-set-names,$0,target,srcFile,modFullName,modAbsPath,includePaths)$(debug-enter)$(shell gcc -M -MG -ansi -I$4/include -I$4/object $5 $6 $(CXXFLAGS) $($3_USER_CXXFLAGS) $(I_PATH) $($(basename $(lastword $(subst /, ,$1)))_cflags) $2 |grep "^ " |sed "s' /[^ ]*''g" |grep -v "^ *\\\\"| sed "s/\\\\//")$(debug-leave)
endef

#1: Target
#2: Source File
#3: Module Full Name
#4: Module Absolute Path
define getIdlUnmetDeps
$(call args-set-names,$0,target,srcFile,modFullName,modAbsPath)$(debug-enter)$(subst -I./,,$(foreach dep,$(call getIdlUnmetDepsList,$1,$2,$3,$4,),-I$(dir $(call findDep,$(dep),idl,idl,1))))$(debug-leave)
endef

#1: Target
#2: Source File
#3: Module Full Name
#4: Module Absolute Path
#5: List of found deps
define getIdlUnmetDepsList
$(call args-set-names,$0,target,srcFile,modFullName,modAbsPath,depsFound)$(debug-enter)$(eval midl:=$(sort $(shell gcc -M -MG -ansi -xc++ -I$4/idl $(CXXFLAGS) $($3_USER_CXXFLAGS) $(MK_IDL_PATH) $(TAO_MK_IDL_PATH) $(foreach dep,$5,-I$(dir $(call findDep,$(dep),idl,idl,1))) $($(basename $(lastword $(subst /, ,$1)))_cflags) $2 |grep "^ " |sed "s' /[^ ]*''g" |grep -v "^ *\\\\"| sed "s/\\\\//")))$(if $(filter-out $5,$(midl)),$(call getIdlUnmetDepsList,$1,$2,$3,$4,$(sort $5 $(midl))),$5)$(debug-leave)
endef

#1: XML (ACSERRDEF) File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: Wait for deppendencies
define makeErrorDefinitions
$(call args-set-names,$0,xmlName,install,modName,modFullName,modRelPath,modAbsPath,waitFor)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
#(eval $1_err_path:=$6/idl/$1.idl)
$(eval $1_err_xml:=$(if $(wildcard $6/idl/$1.xml),xml,))
$(eval $4_$1_xmlerr_lang:=$(if $(call must-build,$4,C++),$4_$1_xmlerr_c++) $(if $(call must-build,$4,Python),$4_$1_xmlerr_py) $(if $(call must-build,$4,Java),$4_$1_xmlerr_java))
$(eval $4_$1_xmlerr_lang_tasks:=$(if $(call must-build,$4,C++),$4_$1_lib $4_$1.h_inc) $(if $(call must-build,$4,Python),$4_$1Impl_pym))
$(eval $4_$1_xmlerr_lang_deps:=$(if $(call must-build,$4,C++),$4_$1_xmlerr_h $4_$1_xmlerr_cpp) $(if $(call must-build,$4,Python),$4_$1_xmlerr_py $4_$1_xmlerr_py_pym))
)
$(if $(call is-make-step,prepare-cross),
)

$(eval $(call makeErrorDefinitionsC++,$1,$2,$3,$4,$5,$6,$7))
$(eval $(call makeErrorDefinitionsJava,$1,$2,$3,$4,$5,$6,$7))
$(eval $(call makeErrorDefinitionsPy,$1,$2,$3,$4,$5,$6,$7))
$(eval $(call makeErrorDefinitionsIdl,$1,$2,$3,$4,$5,$6,$7))

$(if $(call is-make-step,generate),
.INTERMEDIATE: $4_$1_xmlerr
$4_$1_xmlerr: $4_$1_xmlerr_idl $($4_$1_xmlerr_lang)
	$(AT)
.INTERMEDIATE: $4_$1_xmlerr_check
$4_$1_xmlerr_check: $(call findDep,acserrGenCheckXML,script,bin,0) $(call findDep,ACSError.xsd,install,idl,0) $7
	$(AT)$$< $6/idl/$1.xml $(call findDep,ACSError.xsd,install,idl,0) $(call findDep,xmlvalidator.jar,jar,lib,0)
)

$(eval $(call genTargets,$4_$1_xmlerr,$6/idl/$1.xml,idl,$1.xml,$2,$4_$1_idl $($4_$1_xmlerr_lang_tasks),true,$4_$1_xmlerr,true,$4_$1_xmlerr_idl $($4_$1_xmlerr_lang_deps)))
$(debug-leave)
endef

#1: XML (ACSERRDEF) File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: Wait for deppendencies
define makeErrorDefinitionsIdl
$(call args-set-names,$0,xmlName,install,modName,modFullName,modRelPath,modAbsPath,waitFor)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
$(eval $1_idl_prefix:=alma)
$(if $(wildcard $6/idl/$1.xml),$(eval $1_idl_mods:=ACSErr $(shell tr '[< >]' '\n' < $6/idl/$1.xml | egrep 'name' |head -n 1 | sed 's/name="\(.*\)"/\1/')),$(error It was not possible to obtain IDL list of modules. Check that XML file exists. If custom mechanism, check that it fills $1_idl_mods variable correctly))
$(eval $1_IDLS+=acserr)
)
$(if $(call is-make-step,prepare-cross),
)

$(eval $(call makeIdlDependencies,$1,$2,$3,$4,$5,$6,$7 $4_$1_xmlerr_idl_rule))

$(if $(call is-make-step,generate),
.INTERMEDIATE: $4_$1_xmlerr_idl
$4_$1_xmlerr_idl: $4_$1_xmlerr_idl_rule $4_$1_idl

.INTERMEDIATE: $4_$1_xmlerr_idl_rule
$4_$1_xmlerr_idl_rule: $6/idl/$1.idl

$6/idl/$1.idl: $4_$1_xmlerr_idl_gen
	$(AT)

.INTERMEDIATE: $4_$1_xmlerr_idl_gen
$4_$1_xmlerr_idl_gen: $(call findDep,acserrGenIDL,script,bin,0) $(call findDep,AES2IDL.xslt,install,config,0) $6/idl/$1.xml $7 #$4_$1_xmlerr_check
	$(AT)echo $(AT)$$< $6/idl/$1.xml $6/idl/$1.idl $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $(call findDep,AES2IDL.xslt,install,config,0))))) $(call findDep,$(XALAN),jar,lib,0) $(call findDep,$(XALAN_SER),jar,lib,0) $(if $(OUTPUT),> $(OUTPUT))
	$(AT)$$< $6/idl/$1.xml $6/idl/$1.idl $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $(call findDep,AES2IDL.xslt,install,config,0))))) $(call findDep,$(XALAN),jar,lib,0) $(call findDep,$(XALAN_SER),jar,lib,0)
)

$(eval $(call cleanFiles,$4_$1_xmlerr_idl,$6/idl/$1.idl,idl,$1.idl))
#(eval #(call genTargets,$4_$1_xmlerr_idl,$6/idl/$1.idl,idl,$1.idl,$2,,true,$4_$1_xmlerr_idl,true))
$(debug-leave)
endef

#1: XML (ACSERRDEF) File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: Wait for deppendencies
define makeErrorDefinitionsC++
$(call args-set-names,$0,xmlName,install,modName,modFullName,modRelPath,modAbsPath,waitFor)
$(debug-enter)
$(if $(call must-build,$4,C++),
$(if $(call is-make-step,prepare-auto),
$(eval $1_OBJECTS:=$1 $($1_OBJECTS))
$(eval $1Stubs_LIBS:=$($1Stubs_LIBS) acserrStubs)
)
$(if $(call is-make-step,prepare-cross),
)

$(eval $(call makeLibraries,$1,$($1_LIBS) $1Stubs $(if $(filter-out acserrHandlersErr ErrorSystemErrType,$1),acserr),$($1_OBJECTS),$($1_CFLAGS),$($1_LDFLAGS),true,$3,$4,$5,$6,$4_$1_xmlerr_c++_rule $4_$1_idl_c++,object,cpp))
$(eval $(call makeIncludes,$1.h,true,$3,$4,$5,$6,object,$7 $4_$1_xmlerr_c++_gen))

$(if $(call is-make-step,generate),
$(eval $4_$1_AES_mod:=$(if $(filter-out $(dir $(call findDep,AES2H.xslt,install,config,0)),$(dir $(call findDep,AES2CPP.xslt,install,config,0))),$(warning "Couldn't find AES2H or AES2CPP"),$(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $(call findDep,AES2CPP.xslt,install,config,0)))))))
.INTERMEDIATE: $4_$1_xmlerr_c++
$4_$1_xmlerr_c++: $4_$1_xmlerr_c++_rule $4_$1_lib

.INTERMEDIATE: $4_$1_xmlerr_c++_rule
$4_$1_xmlerr_c++_rule: $6/object/$1.cpp $6/object/$1.h

$6/object/$1.cpp $6/object/$1.h: $4_$1_xmlerr_c++_gen | $6/object

.INTERMEDIATE: $4_$1_xmlerr_c++_gen
$4_$1_xmlerr_c++_gen: $(call findDep,acserrGenCpp,script,bin,0) $(call findDep,AES2H.xslt,install,config,0) $(call findDep,AES2CPP.xslt,install,config,0) $6/idl/$1.xml $7 #$4_$1_xmlerr_check
	$(AT)echo $$< $6/idl/$1.xml $6/object/$1.cpp $6/object/$1.h $($4_$1_AES_mod) $(call findDep,$(XALAN),jar,lib,0) $(call findDep,$(XALAN_SER),jar,lib,0) $(if $(OUTPUT),> $(OUTPUT))
	$(AT)$$< $6/idl/$1.xml $6/object/$1.cpp $6/object/$1.h $($4_$1_AES_mod) $(call findDep,$(XALAN),jar,lib,0) $(call findDep,$(XALAN_SER),jar,lib,0)
)

$(eval $(call cleanFiles,$4_$1_xmlerr_h,$6/object/$1.h,include,$1.h))
$(eval $(call cleanFiles,$4_$1_xmlerr_cpp,$6/object/$1.cpp,object,$1.cpp))
)
$(debug-leave)
endef

#1: XML (ACSERRDEF) File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: Wait for deppendencies
define makeErrorDefinitionsJava
$(call args-set-names,$0,xmlName,install,modName,modFullName,modRelPath,modAbsPath,waitFor)
$(debug-enter)
$(if $(call must-build,$4,Java),
$(if $(call is-make-step,prepare-auto),
$(eval $1_JARS:=$($1_JARS) acserrj)
$(eval $1_DEPS:=$($1_DEPS) $4_$1_xmlerr_java_rule)
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
.INTERMEDIATE: $4_$1_xmlerr_java
$4_$1_xmlerr_java: $4_$1_xmlerr_java_rule $4_$1_idl_java
$6/$($1_jar_path)/$1.jar: $4_$1_xmlerr_java_rule

.INTERMEDIATE: $4_$1_xmlerr_java_rule
$4_$1_xmlerr_java_rule: $6/object/$1/src/alma/$1/wrappers

$6/object/$1/src/alma/$1/wrappers: $4_$1_xmlerr_java_gen

.INTERMEDIATE: $4_$1_xmlerr_java_gen
$4_$1_xmlerr_java_gen: $(call findDep,acserrGenJava,script,bin,0,bin) $(call findDep,AES2Java.xslt,install,config,0,config) $6/idl/$1.xml $7 | $6/object/$1 $6/object/$1/src
	$(AT)echo $(AT)$$< $6/idl/$1.xml $6/object/$1/src $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $(call findDep,AES2Java.xslt,install,config,0))))) $(call findDep,$(XALAN),jar,lib,0) $(call findDep,$(XALAN_SER),jar,lib,0) $(if $(OUTPUT),> $(OUTPUT))
	$(AT)$$< $6/idl/$1.xml $6/object/$1/src $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $(call findDep,AES2IDL.xslt,install,config,0))))) $(call findDep,$(XALAN),jar,lib,0) $(call findDep,$(XALAN_SER),jar,lib,0)
)
)
$(debug-leave)
endef

#1: XML (ACSERRDEF) File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: Wait for deppendencies
define makeErrorDefinitionsPy
$(call args-set-names,$0,xmlName,install,modName,modFullName,modRelPath,modAbsPath,waitFor)
$(debug-enter)
$(if $(call must-build,$4,Python),
$(if $(call is-make-step,prepare-auto),
)
$(if $(call is-make-step,prepare-cross),
)

$(eval $(call makePyModules,$1Impl,$2,$3,$4,$5,$6,$7 $4_$1_xmlerr_py_rule,object))

$(if $(call is-make-step,generate),
.INTERMEDIATE: $4_$1_xmlerr_py
$4_$1_xmlerr_py: $4_$1_xmlerr_py_rule $4_$1_idl_py

.INTERMEDIATE: $4_$1_xmlerr_py_rule
$4_$1_xmlerr_py_rule: $6/object/$1Impl.py $6/$(PYTHON_SITE_PACKAGES)/$1Impl.py

.INTERMEDIATE: $4_$1_xmlerr_py_gen
$6/object/$1Impl.py: $4_$1_xmlerr_py_gen

$4_$1_xmlerr_py_gen: $(call findDep,acserrGenPython,script,bin,0,bin) $(call findDep,AES2Py.xslt,install,config,0,config) $6/idl/$1.xml $7 | $6/object
	$(AT)echo "== ACSERR generating Python from ($$(<F)) XML " 
	$(AT)$$< $6/idl/$1.xml $6/object/$1Impl.py $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $(call findDep,AES2Py.xslt,install,config,0))))) $(call findDep,$(XALAN),jar,lib,0) $(call findDep,$(XALAN_SER),jar,lib,0)
)

$(eval $(call genTargets,$4_$1_xmlerr_py,,,,$2,$4_$1Impl_pym,true,$4_$1_xmlerr_py,,,$4_$1_xmlerr_py_pym))
$(call cleanFiles,$4_$1_xmlerr_py_pym,$6/object/$1Impl.py,object,$1Impl.py)
)
$(debug-leave)
endef

#1: XML (ACSLOGTSDEF) File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: Wait for deppendencies
define makeLoggingDefinitions
$(call args-set-names,$0,xmlName,install,modName,modFullName,modRelPath,modAbsPath,waitFor)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
$(eval $1_OBJECTS:=$1 $($1_OBJECTS))
$(eval $4_$1_xmllog_lang:=$(if $(call must-build,$4,C++),$4_$1_xmllog_h $4_$1LTS_lib) $(if $(call must-build,$4,Python),$4_$1_xmllog_py) $(if $(call must-build,$4,Java),$4_$1_xmllog_java))
)
$(if $(call is-make-step,prepare-cross),
)

$(eval $(call makeLibraries,$1LTS,$(strip logging $($1_LIBS)),$($1_OBJECTS),$($1_CFLAGS),$($1_LDFLAGS),true,$3,$4,$5,$6,$7 $6/object/$1.cpp $6/object/$1.h,object,cpp))
$(eval $(call makeIncludes,$1.h,true,$3,$4,$5,$6,object))
$(eval $(call makeLoggingDefinitionsJava,$1,$2,$3,$4,$5,$6,$7))
$(eval $(call makeLoggingDefinitionsPy,$1,$2,$3,$4,$5,$6,$7))

$(if $(call is-make-step,generate),
.INTERMEDIATE: $4_$1_xmllog
$4_$1_xmllog: $6/object/$1.cpp $6/object/$1.h $4_$1LTS_lib $4_$1LTS_jar $4_$1LTS_pym
	$(AT)
.INTERMEDIATE: $4_$1_xmllog_check
$4_$1_xmllog_check: $(call findDep,loggingtsGenCheckXML,script,bin,0) $6/idl/$1.xml
	$(AT)$$< $6/idl/$1.xml
$6/object/$1.h: $(call findDep,loggingtsGenH,script,bin,0) $6/idl/$1.xml $4_$1_xmllog_check $(call findDep,$(XALAN),jar,lib,0) $(call findDep,$(XALAN_SER),jar,lib,0) | $6/object
	$(AT)$$< $6/idl/$1.xml $$@ $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $(call findDep,LTS2Cpp.xslt,install,config,0))))) $(call findDep,$(XALAN),jar,lib,0) $(call findDep,$(XALAN_SER),jar,lib,0)
$6/object/$1.cpp: $(call findDep,loggingtsGenCpp,script,bin,0) $6/idl/$1.xml $4_$1_xmllog_check $(call findDep,$(XALAN),jar,lib,0) $(call findDep,$(XALANA_SER),jar,lib,0) | $6/object
	$(AT)$$< $6/idl/$1.xml $$@ $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $(call findDep,LTS2Cpp.xslt,install,config,0))))) $(call findDep,$(XALAN),jar,lib,0) $(call findDep,$(XALAN_SER),jar,lib,0)
)

$(eval $(call genTargets,$4_$1_xmllog,$6/idl/$1.xml,idl,$1.xml,$2,$($4_$1_xmllog_lang),true,$4_$1_xmllog,true))
$(if $(call must-build,$4,C++),
$(eval $(call genTargets,$4_$1_xmllog_h,$6/object/$1.h,include,$1.h,$2,$4_$1_xmllog_cpp,false,$4_$1_xmllog))
$(eval $(call genTargets,$4_$1_xmllog_cpp,$6/object/$1.cpp,object,$1.cpp,false,,false,$4_$1_xmllog))
)
$(debug-leave)
endef

define makeLoggingDefinitionsC++
$(call args-set-names,$0,xmlName,install,modName,modFullName,modRelPath,modAbsPath,waitFor)
$(debug-enter)
$(if $(call must-build,$4,C++),
)
$(debug-leave)
endef

#1: XML (ACSLOGTSDEF) File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: Wait for deppendencies
define makeLoggingDefinitionsJava
$(call args-set-names,$0,xmlName,install,modName,modFullName,modRelPath,modAbsPath,waitFor)
$(debug-enter)
$(if $(call must-build,$4,Java),
$(if $(call is-make-step,prepare-auto),
$(eval $1LTS_EXTRAS:=$($1LTS_EXTRAS))
$(eval $1LTS_DIRS:=alma $($1LTS_DIRS))
$(eval $1LTS_ENDORSED:=$($1LTS_ENDORSED))
)
$(if $(call is-make-step,prepare-cross),
$(eval $1LTS_JARS:=$($1LTS_JARS) $(foreach dep,$(call expandDependencies,$1,idl,idls),$(dep)))
$(eval $1_DEPS:=$($1_DEPS) $6/object/$1LTS/src/alma/$1)
)

$(eval $(call makeJarFiles,$1LTS,false,$2,$3,$4,$5,$6,$7 $6/object/$1LTS/src/alma/$1,object/$1LTS))

$(if $(call is-make-step,generate),
.INTERMEDIATE: $4_$1_xmllog_java
$4_$1_xmllog_java: $4_$1_xmllog_java_gen $4_$1LTS_jar $7

.INTERMEDIATE: $4_$1_xmllog_java_gen
$6/object/$1LTS/src/alma/$1 $6/object/$1LTS/src/alma $6/object/$1LTS/src: $4_$1_xmllog_java_gen

$4_$1_xmllog_java_gen: $(call findDep,loggingtsGenJava,script,bin,0,bin) $(call findDep,LTS2Java.xslt,install,config,0,config) $6/idl/$1.xml $7 | $6/object/$1LTS
	$(AT)echo $(AT)$$< $6/idl/$1.xml $6/object/$1LTS/src $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $(call findDep,LTS2Java.xslt,install,config,0))))) $(call findDep,$(XALAN),jar,lib,0) $(call findDep,$(XALAN_SER),jar,lib,0) $(if $(OUTPUT),> $(OUTPUT))
	$(AT)$$< $6/idl/$1.xml $6/object/$1LTS/src $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $(call findDep,LTS2Java.xslt,install,config,0))))) $(call findDep,$(XALAN),jar,lib,0) $(call findDep,$(XALAN_SER),jar,lib,0)

#$6/object/$1LTS:
#	$$(if $$(wildcard $6/object/$1LTS),,mkdir $6/object/$1LTS)
)

$(eval $(call genTargets,$4_$1_xmllog_java,,,,$2,$4_$1LTS_jar,true,$4_$1_xmllog_java,,$4_$1_xmllog_java_dir))
$(call cleanFiles,$4_$1_xmllog_java_dir,$6/object/$1LTS,object,$1LTS)
)
$(debug-leave)
endef

#1: XML (ACSLOGTSDEF) File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: Wait for deppendencies
define makeLoggingDefinitionsPy
$(call args-set-names,$0,xmlName,install,modName,modFullName,modRelPath,modAbsPath,waitFor)
$(debug-enter)
$(if $(call must-build,$4,Python),
$(if $(call is-make-step,prepare-auto),
)
$(if $(call is-make-step,prepare-cross),
)

$(eval $(call makePyModules,$1LTS,$2,$3,$4,$5,$6,$7 $4_$1_xmllog_py_gen,object))

$(if $(call is-make-step,generate),
.INTERMEDIATE: $4_$1_xmllog_py
$4_$1_xmllog_py: $4_$1_xmllog_py_gen $7

.INTERMEDIATE: $4_$1_xmllog_py_gen
$6/object/$1LTS.py: $4_$1_xmllog_py_gen

$4_$1_xmllog_py_gen: $(call findDep,loggingtsGenPython,script,bin,0,bin) $(call findDep,LTS2Py.xslt,install,config,0,config) $6/idl/$1.xml $7 | $6/object
	$(AT)echo "== LOGTS generating Python from ($$(<F)) XML " 
	$(AT)$$< $6/idl/$1.xml $6/object/$1LTS.py $(patsubst %/,%,$(dir $(patsubst %/,%,$(dir $(call findDep,LTS2Py.xslt,install,config,0))))) $(call findDep,$(XALAN),jar,lib,0) $(call findDep,$(XALAN_SER),jar,lib,0)
)

$(eval $(call genTargets,$4_$1_xmllog_py,,,,$2,$4_$1LTS_pym,true,$4_$1_xmllog_py,,$4_$1_xmllog_py_pym))
$(call cleanFiles,$4_$1_xmllog_py_pym,$6/object/$1LTS.py,object,$1LTS.py)
)
$(debug-leave)
endef

#1: CDB Schema File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Full Path
define makeCdbSchemas
$(call args-set-names,$0,cdbName,install,modName,modFullName,modRelPath,modAbsPath)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
$4_$1_cdbs: $6/config/CDB/schemas/$1.xsd
	$(AT)
clean_$4_$1_cdbs:
	$(AT)
)

$(eval $(call installFiles,$4_$1_cdbs,$6/config/CDB/schemas/$1.xsd,config/CDB/schemas,$1.xsd))
$(eval $(call cleanDistFiles,$4_$1_cdbs,$6/config/CDB/schemas/$1.xsd,config/CDB/schemas,$1.xsd))
$(debug-leave)
endef

#1: Target Name
#2: Module to Make
#3: Module Full Name
#4: Module Relaive Path
#5: Module Absolute Path
#6: Type of target
#7: Depenencies
#8: Rules
define regenDeps
$(call args-set-names,$0,targetName,modName,modFullName,modRelPath,modAbsPath,targetType,targetDeps,targetRules)
$(debug-enter)
$5/object/auto_$6_$1.mk: MODDEP:=$(mod_$2_name)
$5/object/auto_$6_$1.mk: MODPATH:=$(mod_$2_path)
$5/object/auto_$6_$1.mk: MODRULE:=$(mod_$2_rule)
$5/object/auto_$6_$1.mk: $7
	$(AT)echo "" > $$@
#(foreach rule,$8,	$(AT)echo "$(rule)" >> $$@
#)
$(debug-leave)
endef

parent-dir=$(if $(findstring /,$(patsubst %/,%,$1)),$(patsubst %/,%,$(dir $(patsubst %/,%,$1))),./)
get-dirs=$(strip $(if $1,$(if $(filter ./,$(dir $1)),,$(call get-dirs,$(patsubst %/,%,$(dir $1))) $(patsubst %/,%,$(dir $1)))))
get-dirs-from-list=$(foreach dir,$1,$(call get-dirs,$(dir)))

#1: Python Package Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: Wait for dependency
#8: Relative directory to look for Python source
define makePyPackages
$(call args-set-names,$0,ppName,install,modName,modFullName,modRelPath,modAbspath,waitFor,srcDir)
$(debug-enter)
$(if $(call must-build,$4,Python),
$(if $(call is-make-step,prepare-auto),
$(eval $4_$1_src_dir:=$(if $8,$8,src))
$(eval $4_$1_pyp_src_dirs=$(call unique,$(subst $6/$($4_$1_src_dir)/,,$(call get-dirs-from-list,$(addprefix $1/,$($1_PYMS))) $(if $(wildcard $6/$($4_$1_src_dir)/$1),$(shell find $6/$($4_$1_src_dir)/$1 -type d),$6/$($4_$1_src_dir)/$1))))
$(eval $4_$1_pyp_src_files=$(call unique,$(subst $6/$($4_$1_src_dir)/,,$(addprefix $1/,$(addsuffix .py,$($1_PYMS))) $(if $(wildcard $6/$($4_$1_src_dir)/$1),$(shell find $6/$($4_$1_src_dir)/$1 -type f),$6/$($4_$1_src_dir)/$1/__init__.py))))
$(eval $4_$1_pyp_src_py_files=$(filter %.py,$($4_$1_pyp_src_files)))
$(eval $4_$1_pyp_src_pyc_files=$(call pycache,$($4_$1_pyp_src_py_files)))
$(eval $1_pyp_path:=$6)
$(eval $1_pyp_dir:=$(PYTHON_SITE_PACKAGES))
)
$(if $(call is-make-step,prepare-cross),
$(eval $4_$1_pyp_dep:=$(foreach dep,$($1_DEPS),$(if $($(dep)_exp),$($(dep)_exp),$(dep))))
)

$(if $(call is-make-step,generate),
$(if $(or $(filter clean,$(MAKECMDGOALS)),$(filter clean_dist,$(MAKECMDGOALS))),,$(eval -include $6/object/auto_pyp_$1.mk))
.INTERMEDIATE: $4_$1_pyp
$4_$1_pyp: $(addprefix $6/$(PYTHON_SITE_PACKAGES)/,$($4_$1_pyp_src_files) $($4_$1_pyp_src_pyc_files)) $6/$($4_$1_src_dir)/$1 $($4_$1_pyp_dep) $7
	$(AT)
$(foreach pdir,$($4_$1_pyp_src_dirs),$6/$(PYTHON_SITE_PACKAGES)/$(pdir)/$(call pycache,%.py): $6/$(PYTHON_SITE_PACKAGES)/$(pdir)/%.py $($4_$1_pyp_dep) $7
	$(AT)python -m compileall $$< $(PYTHON_OUTPUT)
	$(AT)chmod 755 $$@
)
$(foreach pdir,$($4_$1_pyp_src_dirs),$6/$(PYTHON_SITE_PACKAGES)/$(pdir)/%.py: $6/$($4_$1_src_dir)/$(pdir)/%.py $($4_$1_pyp_dep) $7 | $6/$(PYTHON_SITE_PACKAGES)/$(pdir)
	$(AT)cp $$< $$@
	$(AT)chmod 755 $$@
)
$(foreach file,$(filter-out %.py,$($4_$1_pyp_src_files)),$6/$(PYTHON_SITE_PACKAGES)/$(file): $6/$($4_$1_src_dir)/$(file) $($4_$1_pyp_dep) $7 | $6/$(PYTHON_SITE_PACKAGES)/$(patsubst %/,%,$(dir $(file)))
	$(AT)cp $$< $$@
)
$(foreach pdir,$($4_$1_pyp_src_dirs),$(if $(call check-target,$0_pdir,$6/$(PYTHON_SITE_PACKAGES)/$(pdir),$4_$1),,$(call add-target,$0_pdir,$6/$(PYTHON_SITE_PACKAGES)/$(pdir))
$6/$(PYTHON_SITE_PACKAGES)/$(pdir): $6/$($4_$1_src_dir)/$(pdir) $($4_$1_pyp_dep) $7 | $(if $(filter ./,$(dir $(pdir))),$6/$(PYTHON_SITE_PACKAGES),$6/$(PYTHON_SITE_PACKAGES)/$(patsubst %/,%,$(dir $(pdir))))
	$(AT)$$(if $$(wildcard $$@),,mkdir $$@)
))
.PHONY: clean_$4_$1_pyp install_$4_$1_pyp clean_dist_$4_$1_pyp

clean_$4_$1_pyp: $(foreach file,$($4_$1_pyp_src_files) $($4_$1_pyp_src_pyc_files),clean_$4_$1_$(subst /,_,$(subst $1/,,$(file))))
	$(AT)$$(if $$(wildcard $6/object/auto_pyp.mk),rm -f $6/object/auto_pyp.mk,)
clean_dist_$4_$1_pyp: $(foreach file,$($4_$1_pyp_src_files) $($4_$1_pyp_src_pyc_files),clean_dist_$4_$1_$(subst /,_,$(subst $1/,,$(file))))
	$(AT)
install_$4_$1_pyp: $4_$1_pyp $(foreach file,$($4_$1_pyp_src_files) $($4_$1_pyp_src_pyc_files),install_$4_$1_$(subst /,_,$(subst $1/,,$(file)))) | $(foreach pdir,$($4_$1_pyp_src_dirs),$(INSTDIR)/$(PYTHON_SITE_PACKAGES)/$(pdir))
	$(AT)
$(foreach pdir,$($4_$1_pyp_src_dirs),$(if $(call check-target,$0_pdir,$(INSTDIR)/$(PYTHON_SITE_PACKAGES)/$(pdir),$4_$1),,$(call add-target,$0_pdir,$(INSTDIR)/$(PYTHON_SITE_PACKAGES)/$(pdir))
$(INSTDIR)/$(PYTHON_SITE_PACKAGES)/$(pdir): $6/$(PYTHON_SITE_PACKAGES)/$(pdir) | $(if $(filter ./,$(dir $(pdir))),$(INSTDIR)/$(PYTHON_SITE_PACKAGES),$(INSTDIR)/$(PYTHON_SITE_PACKAGES)/$(patsubst %/,%,$(dir $(pdir))))
	$(AT)$$(if $$(wildcard $$@),,mkdir $$@)
))

#$4_$1_pyp_doc: $6/doc/api/html/python/packages/$1.html
#	$(AT)
#$6/doc/api/html/python/packages/$1.html: $6/$($4_$1_src_dir)/$1 | $6/doc/api/html/python/packages
#	$(AT)PYTHONPATH=$(PYTHONPATH):$6/$($4_$1_src_dir) pydoc -w $1
#	$(AT)mv $1.html $6/doc/api/html/python/packages/$1.html
)

$(foreach file,$($4_$1_pyp_src_files) $($4_$1_pyp_src_pyc_files),$(eval $(call genTargets,$4_$1_$(subst /,_,$(subst $1/,,$(file))),$6/$(PYTHON_SITE_PACKAGES)/$(file),$(if $(filter ./,$(dir $(file))),$(PYTHON_SITE_PACKAGES),$(PYTHON_SITE_PACKAGES)/$(patsubst %/,%,$(dir $(file)))),$(notdir $(file)),$2,$(foreach pdir,$($4_$1_pyp_src_dirs),$4_$1_$(subst /,_,$(subst $1/,,$(pdir)))_dir),,$4_$1_pyp)))
$(foreach pdir,$($4_$1_pyp_src_dirs),$(eval $(call cleanFiles,$4_$1_$(subst /,_,$(subst $1/,,$(pdir)))_dir,$6/$(PYTHON_SITE_PACKAGES)/$(pdir),$(if $(filter ./,$(call parent-dir,$(pdir))),$(PYTHON_SITE_PACKAGES),$(PYTHON_SITE_PACKAGES)/$(call parent-dir,$(pdir))),$(basename $(pdir)))))
)
$(debug-leave)
endef

#1: Jar File Name
#2: Bool to Mark if it is a Component Jar or Not
#3: Bool to Install or Not
#4: Module to Make
#5: Module Full Name
#6: Module Relative Path
#7: Module Aboslute Path
#8: Wait for dependency
#9: Relative directory to look for Java source
define makeJarFiles
$(call args-set-names,$0,jarName,jarComp,install,modName,modFullName,modRelPath,modAbspath,waitFor,srcDir)
$(debug-enter)
$(if $(call must-build,$5,Java),
$(if $(call is-make-step,prepare-auto),
$(eval $1_jar_jars:=$(if $(filter acserrj,$($1_JARS) $($1_JLIBS)),$(filter-out acserr,$($1_JARS) $($1_JLIBS)),$($1_JARS) $($1_JLIBS)))
$(eval $1_jar_jarse:=$($1_JARS_ENDORSED))
$(eval $1.jar_src:=$(if $($1_SRC),$7/$($1_SRC),$(if $9,$7/$9,$7)))
$(eval $1.jar_jar_comp:=$2)
$(eval $1.jar_jar_path:=$7)
$(eval $1.jar_jar_dir:=$(if $(findstring $2,true),lib/ACScomponents,lib))
$(eval $1.jar_dir_path:=$(if $(findstring $2,true),lib/ACScomponents,lib))
$(eval $1_extras=$(subst $($1.jar_src)/src/,,$(wildcard $(addprefix $($1.jar_src)/src/,$($1_EXTRAS)))))
$(eval $1_javas=$$(foreach dir,$(strip $($1_DIRS)),$$(if $$(wildcard $($1.jar_src)/src/$$(dir)),$$(strip $$(shell find $($1.jar_src)/src/$$(dir) -name \*.java -type f ! -path '*/CVS/*' ! -path '*/.svn/*' | sed 's/^$(subst .,\.,$(subst /,\/,$($1.jar_src)/src/))//' | tr '\n' ' ')),)))
$(eval $1_jar_path:=$(if $(findstring $2,true),lib/ACScomponents,lib))
$(eval $5_$1_jar_exp:=$7/$($1_jar_path)/$1.jar)
)
$(if $(call is-make-step,prepare-cross),
$(eval $5_$1_jar_dep:=$(foreach dep,$($1_DEPS),$(if $($(dep)_exp),$($(dep)_exp),$(dep))))
$(eval $(call regenDeps,$1,$4,$5,$6,$7,jar,$($5_$1_jar_dep),))
$(eval $1_jar_jars_dup:=$(strip $(foreach jar,$($1_jar_jars),$(if $(filter 1,$(words $(filter $(jar),$(call expandDependencies,$1,jar,jars)))),,$(jar).jar))))
$(if $($1_jar_jars_dup),$(warning Duplicated transitive dependencies for $1.jar in $4: $($1_jar_jars_dup)))
)

$(if $(call is-make-step,generate),
.PHONY: $5_$1_jar
$5_$1_jar: $7/$($1_jar_path)/$1.jar $($5_$1_jar_dep) $8
	$(AT)
$(if $(filter $($1_COMPILE), no),,
$7/$($1_jar_path)/$1.jar: $$(addprefix $($1.jar_src)/src/,$$($1_javas)) $(addprefix $($1.jar_src)/src/,$(strip $($1_DIRS))) $(addprefix $($1.jar_src)/src/,$($1_extras)) $(foreach jar,$(call expandDependencies,$1,jar,jars),$(call findDep,$(jar).jar,jar,lib,0,lib)) $(foreach jar,$(call expandDependencies,$1,jar,jarse),$(call findDep,$(jar).jar,jar,lib/endorsed,0,lib/endorsed)) $($5_$1_jar_dep) $8 | $7/object/$1/src $7/object/$1/class $7/$($1_jar_path)
	$(AT)echo $1-ACS-Generated-FromModule: "$$(if $$(wildcard $($1.jar_src)/src/.svn),$$(shell svn info . |grep URL| awk '{print $$$$2}'),$7/src)" > $7/object/$1/$1.manifest
	$(AT)javac -J-Xmx1g --add-exports java.management/sun.management=ALL-UNNAMED -g -classpath $$(subst $$(space),$$(PATH_SEP),$$(sort $$(subst $$(PATH_SEP),$$(space),$($5_CLASSPATH)$$(subst $(space),,$$(if $$(wildcard $7/lib/*.jar),$$(foreach jar,$$(wildcard $7/lib/*.jar),$(PATH_SEP)$$(jar)),))$(subst $(space),,$(foreach jar,$(call expandDependencies,$1,jar,jars),$(PATH_SEP)$(call findDep,$(jar).jar,jar,lib,2,lib)))$(addprefix $(PATH_SEP),$(filter %.jar,$($5_$1_jar_dep)))$(PATH_SEP)$(shell acsMakeJavaClasspath$(if $(findstring $($1_ENDORSED),on), -endorsed,))))) -d $7/object/$1/class $$(filter %.java,$$(addprefix $($1.jar_src)/src/,$$($1_javas)))
	$(AT)jar $$(if $$(wildcard $7/$($1_jar_path)/$1.jar),uf,cf) $7/$($1_jar_path)/$1.jar $(addprefix -C $7/object/$1/class ,$(strip $($1_DIRS)))
	$(AT)jar ufm $7/$($1_jar_path)/$1.jar $7/object/$1/$1.manifest
	$(AT)$(if $($1_extras),jar uf $7/$($1_jar_path)/$1.jar$(foreach extra,$($1_extras), -C $($1.jar_src)/src $(extra)))
	$(AT)$(if $(findstring $($5_DEBUG),on),jar uf $7/$($1_jar_path)/$1.jar$$(foreach java,$$($1_javas), -C $($1.jar_src) $(addprefix src/,$$(java))))
$7/object/$1/class: | $7/object/$1
	$(AT)$$(if $$(wildcard $7/object/$1/class),,mkdir $7/object/$1/class)
$7/object/$1/src: | $7/object/$1
	$(AT)$$(if $$(wildcard $7/object/$1/src),,mkdir $7/object/$1/src)
$7/object/$1: | $7/object
	$(AT)$$(if $$(wildcard $7/object/$1),,mkdir $7/object/$1)
)
)

$(eval $(call genTargets,$5_$1_jar,$7/$($1_jar_path)/$1.jar,$($1_jar_path),$1.jar,$3,$5_$1_jar_dir,false,$5_$1_jar))
$(eval $(call cleanFiles,$5_$1_jar_dir,$7/object/$1,object,$1))
)
$(debug-leave)
endef

#1: Include File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
#7: Dir
#8: Wait for dependency
define makeIncludes
$(call args-set-names,$0,incName,install,modName,modFullName,modRelPath,modAbspath,srcDir,waitFor)
$(debug-enter)
$(if $(call must-build,$4,C++),
$(if $(call is-make-step,prepare-auto),
$(eval $1_include_path:=$6)
$(eval $1_include_dir:=$7)
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
$4_$1_inc: $6/$7/$1 $8
	$(AT)
clean_$4_$1_inc:
	$(AT)
)

$(eval $(call installFiles,$4_$1_inc,$6/$7/$1,include,$1))
$(eval $(call cleanDistFiles,$4_$1_inc,$6/$7/$1,include,$1))
)
$(debug-leave)
endef

#1: Install File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
define makeInstallFiles
$(call args-set-names,$0,insName,install,modName,modFullName,modRelPath,modAbspath)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
$(eval $4_$1_ins_path:=$(patsubst ../%/,%,$(dir $1)))
$(eval $4_$1_ins_file:=$(notdir $1))
$(eval $($4_$1_ins_file)_install_path:=$6)
$(eval $($4_$1_ins_file)_install_dir:=$($4_$1_ins_path))
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
$4_$1_ins: $6/$($4_$1_ins_path)/$($4_$1_ins_file)
	$(AT)
clean_$4_$1_ins:
	$(AT)
)

$(eval $(call installFiles,$4_$1_ins,$6/$($4_$1_ins_path)/$($4_$1_ins_file),$($4_$1_ins_path),$($4_$1_ins_file)))
$(eval $(call cleanDistFiles,$4_$1_ins,$6/$($4_$1_ins_file)/$($4_$1_ins_path),$($4_$1_ins_path),$($4_$1_ins_file)))
$(debug-leave)
endef

#1: Jar Install File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
define makeInstallJars
$(call args-set-names,$0,jarName,install,modName,modFullName,modRelPath,modAbspath)
$(debug-enter)
$(if $(call must-build,$4,Java),
$(if $(call is-make-step,prepare-auto),
$(eval jar_path:=$(patsubst %/,%,$(dir lib/$1)))
$(eval jar_file:=$(notdir $1))
$(eval $(jar_file)_jar_path:=$6)
$(eval $(jar_file)_dir_path:=$(jar_path))
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
$4_$1_jar: $6/$(jar_path)/$(jar_file)
	$(AT)
clean_$4_$1_jar:
	$(AT)
)

$(eval $(call installFiles,$4_$1_jar,$6/$(jar_path)/$(jar_file),$(jar_path),$(jar_file)))
$(eval $(call cleanDistFiles,$4_$1_jar,$6/$(jar_file)/$(jar_path),$(jar_path),$(jar_file)))
)
$(debug-leave)
endef

#1: Config File Name
#2: Bool to Install or Not
#3: Module to Make
#4: Module Full Name
#5: Module Relative Path
#6: Module Absolute Path
define makeConfigs
$(call args-set-names,$0,confName,install,modName,modFullName,modRelPath,modAbspath)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
$4_$1_cfg: $6/config/$1
	$(AT)
clean_$4_$1_cfg:
	$(AT)
)

$(eval $(call installFiles,$4_$1_cfg,$6/config/$1,config,$1))
$(eval $(call cleanDistFiles,$4_$1_cfg,$6/config/$1,config,$1))
$(debug-leave)
endef

#1: Man Section Name
#2: List of Man Section Docs
#3: Bool to Install or Not
#4: Module to Make
#5: Module Full Name
#6: Module Relative Path
#7: Module Absolute Path
define makeManSections
$(call args-set-names,$0,manName,manSections,install,modName,modFullName,modRelPath,modAbspath)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
)
$(if $(call is-make-step,prepare-cross),
)

$(foreach doc,$2,$(eval $(call makeManSection,$(doc),$1,$3,$4,$5,$7)))

$(if $(call is-make-step,generate),
$5_$1_man: $(foreach doc,$2,$5_$1_$(doc)_doc)| $7/man/man$1
	$(AT)
$7/man/man$1: | $7/man
	$(AT)$$(if $$(wildcard $7/man/man$1),,mkdir $7/man/man$1)
)

$(eval $(call genTargets,$5_$1_man,$7/man/man$1,man,man$1,$3,$(foreach doc,$2,$5_$1_$(doc)_doc),true,$5_$1_man))
$(debug-leave)
endef

docDoManPages_target=yes
docDoManPages_path=doc/bin/docDoManPages
#1: Man Section Doc
#2: Man Section
#3: Bool to Install or Not
#4: Module to Make
#5: Module Full Name
#6: Module Relative Path
#7: Module Absolute Path
define makeManSection
$(call args-set-names,$0,manSectionDoc,manSection,install,modName,modFullName,modRelPath,modAbspath)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
$5_$2_$1_doc: $7/man/man$2/$(notdir $(basename $1)).$2
	$(AT)
$7/man/man$2/$(notdir $(basename $1)).$2: $7/src/$1 $(if $(docDoManPages_target),$(docDoManPages_path),) | $7/doc $7/man/man$2
	$(AT)$(if $(docDoManPages_target),$(docDoManPages_path),docDoManPages) $7/src/$1 $2 $(LASTCHANGE) $(OUTPUT)
)

$(eval $(call genTargets,$5_$2_$1_doc,$7/man/man$2/$(notdir $(basename $1)).$2,man/man$2,$(notdir $(basename $1)).$2,$3,$(foreach ext,inc mif text,$5_$2_$1_doc_$(ext)),,$5_$2_$1_doc))
$(foreach ext,inc mif text,$(eval $(call genTargets,$5_$2_$1_doc_$(ext),$7/doc/$(notdir $(basename $1)).$(ext),doc,$(notdir $(basename $1)).$(ext),$3,,,$5_$2_$1_doc_$(ext))))
$(debug-leave)
endef

#1: List of targets
#2: Module Full Name
#3: All/Clean
#4: Install/Clean_Dist
#5: Suffix for targets
define addTargets
$(call args-set-names,$0,targets,modFullName,allAndClean,installAndCleanDist,targetsSuffix)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
$(if $(findstring true,$3),$(if $1,$(eval ALL_TARGETS+=$(addsuffix _$5,$(addprefix $2_,$1)))$(eval CLEAN_TARGETS+=$(addsuffix _$5,$(addprefix clean_$2_,$1))),),)
$(if $(findstring true,$4),$(if $1,$(eval INSTALL_TARGETS+=$(addsuffix _$5,$(addprefix install_$2_,$1)))$(eval CLEAN_DIST_TARGETS+=$(addsuffix _$5,$(addprefix clean_dist_$2_,$1))),),)
)
$(debug-leave)
endef

#1: Object Name
#2: Module to Make
#3: Module Full Name
#4: Module Relative Path
#5: Module Absolute Path
#6: Src dir
#7: Extension
#8: Wait for dependency
define makeObjects
$(call args-set-names,$0,objName,modName,modFullName,modRelPath,modAbsPath,srcDir,srcExt,waitFor)
$(debug-enter)
$(if $(call must-build,$3,C++),
$(if $(call is-make-step,prepare-auto),
$(eval $1_compiler:=$(if $(filter-out c,$7),$(CXX),$(CC)))
$(eval $1_flags:=$(if $(filter-out c,$7),$(CXXFLAGS),$(CFLAGS)))
$(eval $1_user_flags:=$(if $(filter-out c,$7),$($3_USER_CXXFLAGS),$($3_USER_CFLAGS)))
$(eval $1_ipath:=$(if $(filter-out c,$7),$(I_PATH) $($3_USER_INC),))
)
$(if $(call is-make-step,prepare-cross),
)

$(if $(call is-make-step,generate),
$(if $(call check-target,$0,$5/object/$1.d,$1),,$(call add-target,$0,$5/object/$1.d)
#$5/object/$1.d: $5/$6/$1.$7 #(call getCppUnmetIncs,$5/object/$1.o,$5/$6/$1.$7,$3,$5,$($1_ipath)) $8 | $5/object
$5/object/$1.d: $5/$6/$1.$7 $8 | $5/object
	$(AT)$(CCDEP) -I$5/include -I$5/object $($1_flags) $($1_user_flags) $($1_ipath) $$($$(patsubst %.d,%,$$(lastword $$(subst /, ,$$@)))_cflags) $$< | \
sed -e "s'$1\.o'$5/object/$1.o $5/object/$1.d '" -e "s':': $5/src/module.mk '"$$(foreach dep,$$(call getCppDeps,$$@,$$<,$3,$5),| sed "s' $$(dep)' $$(call findDep,$$(dep),include,object,2) $$(call findDep,$$(dep),include,include,2)'") > $$@
	$(AT)if [ ! -s $$@ ]; then $(RM) $$@; fi
)

$(if $(call check-target,$0,$5/object/$1.o,$1),,$(call add-target,$0,$5/object/$1.o)
$5/object/$1.o: $5/$6/$1.$7 $5/object/$1.d | $5/object
	$(AT)$($1_compiler) -c -I$5/include -I$5/object $($1_flags) $($1_user_flags) $$(call getCppUnmetDeps,$$@,$$<,$3,$5) $($1_ipath) $$($$(patsubst %.o,%,$$(lastword $$(subst /, ,$$@)))_cflags) $$< -o $$@
)
)
)
$(debug-leave)
endef

#makeModule: Iterates over the lists of targets to make local and installable libraries, executables, scripts, etc. to create build, install and clean targets.
#1: Module to Make
#2: Module Full Name
#3: Module Relative Path
#4: Module Absolute Path
define makeModule
$(call args-set-names,$0,modName,modFullName,modRelPath,modAbsPath)
$(debug-enter)
$(eval ALL_TARGETS:=)
$(eval CLEAN_TARGETS:=)
$(eval INSTALL_TARGETS:=)
$(eval CLEAN_DIST_TARGETS:=)

$(foreach plg,$($2_PLUGINS),$(eval $(call makePlugins,$(plg),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_PLUGINS),$2,false,true,plg))
$(foreach plg,$($2_LOAD_PLUGINS),$(eval $(call load-plugin,$(plg))))

$(foreach ins,$($2_INSTALL_FILES),$(eval $(call makeInstallFiles,$(ins),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_INSTALL_FILES),$2,false,true,ins))
$(foreach scr,$($2_SCRIPTS),$(eval $(call makeScripts,$(scr),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_SCRIPTS),$2,true,true,scr))
$(foreach scr,$($2_SCRIPTS_L),$(eval $(call makeScripts,$(scr),false,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_SCRIPTS_L),$2,true,false,scr))
$(foreach jar,$($2_JARFILES),$(eval $(call makeJarFiles,$(jar),false,true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_JARFILES),$2,true,true,jar))
$(foreach jar,$($2_JARFILES_L),$(eval $(call makeJarFiles,$(jar),false,false,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_JARFILES_L),$2,true,false,jar))
$(foreach jar,$($2_COMPONENTS_JARFILES),$(eval $(call makeJarFiles,$(jar),true,true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_COMPONENTS_JARFILES),$2,true,true,jar))
$(foreach jar,$($2_COMPONENTS_JARFILES_L),$(eval $(call makeJarFiles,$(jar),true,false,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_COMPONENTS_JARFILES_L),$2,true,false,jar))
$(foreach xml,$($2_ACSLOGTSDEF),$(eval $(call makeLoggingDefinitions,$(xml),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_ACSLOGTSDEF),$2,true,true,xmllog))
$(foreach xml,$($2_ACSERRDEF),$(eval $(call makeErrorDefinitions,$(xml),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_ACSERRDEF),$2,true,true,xmlerr))
$(foreach xsd,$($2_XSDBIND),$(eval $(call makeXsdBind,$(xsd),true,$1,$2,$3,$4,$($2_XSDBIND_INCLUDE))))
$(eval $(call addTargets,$($2_XSDBIND),$2,true,true,xsd))
$(foreach idl,$($2_IDL_FILES),$(eval $(call makeIdlDependencies,$(idl),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_IDL_FILES),$2,true,true,idl))
$(foreach idl,$($2_IDL_FILES_L),$(eval $(call makeIdlDependencies,$(idl),false,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_IDL_FILES_L),$2,true,false,idl))
$(foreach lib,$($2_LIBRARIES),$(eval $(call makeLibraries,$(lib),$($(lib)_LIBS),$($(lib)_OBJECTS),$($(lib)_CFLAGS),$($(lib)_LDFLAGS),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_LIBRARIES),$2,true,true,lib))
$(foreach lib,$($2_LIBRARIES_L),$(eval $(call makeLibraries,$(lib),$($(lib)_LIBS),$($(lib)_OBJECTS),$($(lib)_CFLAGS),$($(lib)_LDFLAGS),false,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_LIBRARIES_L),$2,true,false,lib))
$(foreach exe,$($2_EXECUTABLES),$(eval $(call makeExecutables,$(exe),$($(exe)_LIBS),$($(exe)_OBJECTS),$($(exe)_CFLAGS),$($(exe)_LDFLAGS),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_EXECUTABLES),$2,true,true,exe))
$(foreach exe,$($2_EXECUTABLES_L),$(eval $(call makeExecutables,$(exe),$($(exe)_LIBS),$($(exe)_OBJECTS),$($(exe)_CFLAGS),$($(exe)_LDFLAGS),false,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_EXECUTABLES_L),$2,true,false,exe))
$(foreach pys,$($2_PY_SCRIPTS),$(eval $(call makePyScripts,$(pys),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_PY_SCRIPTS),$2,true,true,pys))
$(foreach pys,$($2_PY_SCRIPTS_L),$(eval $(call makePyScripts,$(pys),false,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_PY_SCRIPTS_L),$2,true,false,pys))
$(foreach pym,$($2_PY_MODULES),$(eval $(call makePyModules,$(pym),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_PY_MODULES),$2,true,true,pym))
$(foreach pym,$($2_PY_MODULES_L),$(eval $(call makePyModules,$(pym),false,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_PY_MODULES_L),$2,true,false,pym))
$(foreach pyp,$($2_PY_PACKAGES),$(eval $(call makePyPackages,$(pyp),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_PY_PACKAGES),$2,true,true,pyp))
$(foreach pyp,$($2_PY_PACKAGES_L),$(eval $(call makePyPackages,$(pyp),false,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_PY_PACKAGES_L),$2,true,false,pyp))
$(foreach jar,$($2_INSTALL_JARS),$(eval $(call makeInstallJars,$(jar),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_INSTALL_JARS),$2,false,true,jar))
$(foreach tsc,$($2_TCL_SCRIPTS),$(eval $(call makeTclScripts,$(tsc),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_TCL_SCRIPTS),$2,true,true,tsc))
$(foreach tsc,$($2_TCL_SCRIPTS_L),$(eval $(call makeTclScripts,$(tsc),false,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_TCL_SCRIPTS_L),$2,true,false,tsc))
$(foreach tlb,$($2_TCL_LIBRARIES),$(eval $(call makeTclLibraries,$(tlb),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_TCL_LIBRARIES),$2,true,true,tlb))
$(foreach tlb,$($2_TCL_LIBRARIES_L),$(eval $(call makeTclLibraries,$(tlb),false,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_TCL_LIBRARIES_L),$2,true,false,tlb))
$(foreach inc,$($2_INCLUDES),$(eval $(call makeIncludes,$(inc),true,$1,$2,$3,$4,include)))
$(eval $(call addTargets,$($2_INCLUDES),$2,false,true,inc))
$(foreach cfg,$($2_CONFIGS),$(eval $(call makeConfigs,$(cfg),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_CONFIGS),$2,false,true,cfg))
#(foreach man,#(#2_MANSECTIONS),#(eval #(call makeManSections,#(man),#(#2_MAN#(man)),true,#1,#2,#3,#4)))
#(eval #(call addTargets,#(#2_MANSECTIONS),#2,true,true,man))
#(eval #(call makeManSections,l,#(#2_MANl),false,#1,#2,#3,#4))
#(eval #(call addTargets,l,#2,true,false,man))
$(foreach cdbs,$($2_CDB_SCHEMAS),$(eval $(call makeCdbSchemas,$(cdbs),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_CDB_SCHEMAS),$2,true,true,cdbs))
$(foreach ko,$($2_KERNEL_MODULES),$(eval $(call makeKernelModules,$(ko),$($(ko)_LIBS),$($(ko)_OBJECTS),$($(ko)_CFLAGS),$($(ko)_LDFLAGS),true,$1,$2,$3,$4)))
$(eval $(call addTargets,$($2_KERNEL_MODULES),$2,true,true,ko))

$(if $(call is-make-step,generate),
#(warning ALL_TARGETS: $(ALL_TARGETS))
#(warning CLEAN_TARGETS: $(CLEAN_TARGETS))
#(warning INSTALL_TARGETS: $(INSTALL_TARGETS))
#(warning CLEAN_DIST_TARGETS: $(CLEAN_DIST_TARGETS))

#(warning $2: $(ALL_TARGETS) $($2_PREQS))
$2: $($2_PREQS) $(ALL_TARGETS)
clean_$2: $(CLEAN_TARGETS)
install_$2: $2_all $(INSTALL_TARGETS)
clean_dist_$2: $2_clean $(CLEAN_DIST_TARGETS)

$4/object/%.id: $4/idl/%.idl | $4/object
	$(AT)$(CCDEP) -xc++ -I$4/idl $$(call getIdlUnmetDeps,$$@,$$<,$2,$4) $(CXXFLAGS) $($2_USER_CXXFLAGS) $(MK_IDL_PATH) $$($$(patsubst %.id,%,$$(lastword $$(subst /, ,$$@)))_cflags) $$< | \
sed -e "s'$$*\.o'$(foreach ext,C.h S.h C.cpp S.cpp C.inl,$4/object/$$*$(ext)) $4/object/$$*.id '" -e "s':': $4/src/module.mk '" > $$@; if [ ! -s $$@ ]; then $(RM) $$@; fi

$4/object/%.d: $4/src/%.c | $4/object
	$(AT)$(CCDEP) -I$4/include -I$4/object $(CFLAGS) $($2_USER_CFLAGS) $$(call getCppUnmetDeps,$$@,$$<,$2,$4) $(I_PATH) $$($$(patsubst %.d,%,$$(lastword $$(subst /, ,$$@)))_cflags) $$< | \
sed -e "s'$$*\.o'$4/object/$$*.o $4/object/$$*.d '" -e "s':': $4/src/module.mk '" > $$@; if [ ! -s $$@ ]; then $(RM) $$@; fi

$4/object/%.o: $4/src/%.c $4/object/%.d | $4/object
	$(AT)$(CC) -c -I$4/include -I$4/object $(CFLAGS) $($2_USER_CFLAGS) $$(call getCppUnmetDeps,$$@,$$<,$2,$4) $$($$(patsubst %.o,%,$$(lastword $$(subst /, ,$$@)))_cflags) $$< -o $$@

$4/object:
	$(AT)$$(if $$(wildcard $4/object),,mkdir $4/object)
$4/bin:
	$(AT)$$(if $$(wildcard $4/bin),,mkdir $4/bin)
$4/lib:
	$(AT)$$(if $$(wildcard $4/lib),,mkdir $4/lib)
$4/lib/endorsed: | $4/lib
	$(AT)$$(if $$(wildcard $4/lib/endorsed),,mkdir $4/lib/endorsed)
$4/lib/ACScomponents: | $4/lib
	$(AT)$$(if $$(wildcard $4/lib/ACScomponents),,mkdir $4/lib/ACScomponents)
$4/$(PYTHON_LIB_SUFFIX): | $4/lib
	$(AT)$$(if $$(wildcard $4/$(PYTHON_LIB_SUFFIX)),,mkdir $4/$(PYTHON_LIB_SUFFIX))
	$(AT)$$(if $$(wildcard $4/lib/python),,ln -rs $4/$(PYTHON_LIB_SUFFIX) $4/lib/python)
$4/$(PYTHON_SITE_PACKAGES): | $4/$(PYTHON_LIB_SUFFIX)
	$(AT)$$(if $$(wildcard $4/$(PYTHON_SITE_PACKAGES)),,mkdir $4/$(PYTHON_SITE_PACKAGES))
$4/man:
	$(AT)$$(if $$(wildcard $4/man),,mkdir $4/man)
$4/doc:
	$(AT)$$(if $$(wildcard $4/doc),,mkdir $4/doc)
$4/doc/api: | $4/doc
	$(AT)$$(if $$(wildcard $4/doc/api),,mkdir $4/doc/api)
$4/doc/api/html: | $4/doc/api
	$(AT)$$(if $$(wildcard $4/doc/api/html),,mkdir $4/doc/api/html)
$4/doc/api/html/python: | $4/doc/api/html
	$(AT)$$(if $$(wildcard $4/doc/api/html/python),,mkdir $4/doc/api/html/python)
$4/doc/api/html/python/scripts: | $4/doc/api/html/python
	$(AT)$$(if $$(wildcard $4/doc/api/html/python/scripts),,mkdir $4/doc/api/html/python/scripts)
$4/doc/api/html/python/modules: | $4/doc/api/html/python
	$(AT)$$(if $$(wildcard $4/doc/api/html/python/modules),,mkdir $4/doc/api/html/python/modules)
$4/doc/api/html/python/packages: | $4/doc/api/html/python
	$(AT)$$(if $$(wildcard $4/doc/api/html/python/packages),,mkdir $4/doc/api/html/python/packages)
$4/man/man1: | $4/man
	$(AT)$$(if $$$(wildcard $4/man/man1),,mkdir $4/man/man1)
$4/man/man2: | $4/man
	$(AT)$$(if $$(wildcard $4/man/man2),,mkdir $4/man/man2)
$4/man/man3: | $4/man
	$(AT)$$(if $$(wildcard $4/man/man3),,mkdir $4/man/man3)
$4/man/man4: | $4/man
	$(AT)$$(if $$(wildcard $4/man/man4),,mkdir $4/man/man4)
$4/man/man5: | $4/man
	$(AT)$$(if $$(wildcard $4/man/man5),,mkdir $4/man/man5)
$4/man/man6: | $4/man
	$(AT)$$(if $$(wildcard $4/man/man6),,mkdir $4/man/man6)
$4/man/man7: | $4/man
	$(AT)$$(if $$(wildcard $4/man/man7),,mkdir $4/man/man7)
$4/man/man8: | $4/man
	$(AT)$$(if $$(wildcard $4/man/man8),,mkdir $4/man/man8)
$4/man/man9: | $4/man
	$(AT)$$(if $$(wildcard $4/man/man9),,mkdir $4/man/man9)
$4/kernel:
	$(AT)$$(if $$(wildcard $4/kernel),,mkdir $4/kernel)
$4/kernel/$(kernel_install_subfold): | $4/kernel
	$(AT)$$(if $$(wildcard $4/kernel/$(kernel_install_subfold)),,mkdir $4/kernel/$(kernel_install_subfold))
)

$(eval ALL_TARGETS:=)
$(eval CLEAN_TARGETS:=)
$(eval INSTALL_TARGETS:=)
$(eval CLEAN_DIST_TARGETS:=)
$(debug-leave)
endef

#genModules: Includes the module Makefile with the list of libraries, executables, scripts, etc. to build. Calls makeModule.
#1: Module to Generate
#2: Parent Group Name
#3: Module Relative path
#4: Module Absolute path
define genModules
$(call args-set-names,$0,modName,parentGroup,modRelPath,modAbsPath)
$(debug-enter)
$(eval MODWS:=$(if $(wildcard $3/$1/src/module.mk),false,true))
$(if $(call is-make-step,prepare-auto),
$(eval MODRULE:=$(if $(findstring $(MODWS),true),$2_$1_,$2_$1_))
$(eval MODDEP:=$(if $(findstring $(MODWS),true),$2_$1,$2_$1))
$(eval MODPATH:=$(if $(findstring $(MODWS),true),$4/$1/ws,$4/$1))
$(eval mod_$1_name:=$(MODDEP))
$(eval mod_$1_path:=$(MODPATH))
$(eval mod_$1_rule:=$(MODRULE))
$(eval mod_$1_targets:=$(call get-make-targets,$(MODPATH)/src/module.mk,$(MODRULE),$(MODPATH)))
$(eval $(if $(findstring $(MODWS),true),include $4/$1/ws/src/module.mk,include $4/$1/src/module.mk))
$(eval $(call storeModuleVars,$(if $(findstring $(MODWS),true),$2_$1,$2_$1)))
$(eval $(call setRecipeModVars,MODPATH,$(mod_$1_targets)))
$(eval $(call setRecipeModVars,MODRULE,$(mod_$1_targets)))
$(eval $(call setRecipeModVars,MODDEP,$(mod_$1_targets)))
$(eval MODRULE:=)
$(eval MODDEP:=)
$(eval MODPATH:=)
$(eval $(call cleanModuleIncludeVars))
)
$(if $(call is-make-step,prepare-cross),
)
$(eval $(call makeModule,$1,$(if $(findstring $(MODWS),true),$2_$1,$2_$1),$(if $(findstring $(MODWS),true),$3/$1/ws,$3/$1),$(if $(findstring $(MODWS),true),$4/$1/ws,$4/$1)))
$(if $(call is-make-step,generate),
$(eval $(call cleanModuleVars,$(if $(findstring $(MODWS),true),$2_$1,$2_$1)))
)
$(debug-leave)
endef

#genModule: Includes the module Makefile with the list of libraries, executables, scripts, etc. to build. Calls makeModule.
#1: Module to Generate
#2: Module Relative path
define genModule
$(call set-make-step,start)
$(call args-set-names,$0,modName,modRelPath)
$(debug-enter)
$(if $(filter prepare,$(MAKECMDGOALS)),,
$(eval MODRULE:=$1_)
$(eval MODDEP:=$1)
$(eval MODPATH:=$(abspath $(MAKEDIR)/..))
$(eval mod_$1_name:=$(MODDEP))
$(eval mod_$1_path:=$(MODPATH))
$(eval mod_$1_rule:=$(MODRULE))
$(eval mod_$1_targets:=$(call get-make-targets,$(MODPATH)/src/module.mk,$(MODRULE),$(MODPATH)))
$(eval include module.mk)
all: $1_all
install: $1_install
clean: $1_clean
clean_dist: $1_clean_dist
$(eval $(call storeModuleVars,$1))
$(eval $(call setRecipeModVars,MODPATH,$(mod_$1_targets)))
$(eval $(call setRecipeModVars,MODRULE,$(mod_$1_targets)))
$(eval $(call setRecipeModVars,MODDEP,$(mod_$1_targets)))
$(eval MODRULE:=)
$(eval MODDEP:=)
$(eval MODPATH:=)
$(eval $(call cleanModuleIncludeVars))
$(call set-make-step,prepare-auto)
$(eval $(call makeModule,$1,$1,..,$(abspath $(MAKEDIR)/..)))
$(call set-make-step,prepare-cross)
$(eval $(call makeModule,$1,$1,..,$(abspath $(MAKEDIR)/..)))
$(call set-make-step,generate)
$(eval $(call makeModule,$1,$1,..,$(abspath $(MAKEDIR)/..)))
$(eval $(call cleanModuleVars,$1))
$(call set-make-step,execute)
)
$(debug-leave)
endef

#1: Variable name
#2: Additional list of targets to consider
define setRecipeModVars
$(MODRULE)all: $1:=$($1)
$(MODRULE)install: $1:=$($1)
$(MODRULE)clean: $1:=$($1)
$(MODRULE)clean_dist: $1:=$($1)
$(foreach tar,$($(MODRULE)MODULE_TARGETS) $2,$(tar): $1:=$($1)
)
endef

#1: Module Target
define storeModuleVars
$(eval $1_PLUGINS:=$(strip $(PLUGINS)))
$(eval $1_LOAD_PLUGINS:=$(strip $(LOAD_PLUGINS)))
$(eval $1_LIBRARIES:=$(strip $(LIBRARIES)))
$(eval $1_LIBRARIES_L:=$(strip $(LIBRARIES_L)))
$(eval $1_EXECUTABLES:=$(strip $(EXECUTABLES)))
$(eval $1_EXECUTABLES_L:=$(strip $(EXECUTABLES_L)))
$(eval $1_SCRIPTS:=$(strip $(SCRIPTS)))
$(eval $1_SCRIPTS_L:=$(strip $(SCRIPTS_L)))
$(eval $1_PY_SCRIPTS:=$(strip $(PY_SCRIPTS)))
$(eval $1_PY_SCRIPTS_L:=$(strip $(PY_SCRIPTS_L)))
$(eval $1_PY_MODULES:=$(strip $(PY_MODULES)))
$(eval $1_PY_MODULES_L:=$(strip $(PY_MODULES_L)))
$(eval $1_PY_PACKAGES:=$(strip $(PY_PACKAGES)))
$(eval $1_PY_PACKAGES_L:=$(strip $(PY_PACKAGES_L)))
$(eval $1_JARFILES:=$(strip $(JARFILES)))
$(eval $1_JARFILES_L:=$(strip $(JARFILES_L)))
$(eval $1_COMPONENTS_JARFILES:=$(strip $(COMPONENTS_JARFILES)))
$(eval $1_COMPONENTS_JARFILES_L:=$(strip $(COMPONENTS_JARFILES_L)))
$(eval $1_IDL_FILES:=$(strip $(IDL_FILES)))
$(eval $1_IDL_FILES_L:=$(strip $(IDL_FILES_L)))
$(eval $1_TCL_SCRIPTS:=$(strip $(TCL_SCRIPTS)))
$(eval $1_TCL_SCRIPTS_L:=$(strip $(TCL_SCRIPTS_L)))
$(eval $1_TCL_LIBRARIES:=$(strip $(TCL_LIBRARIES)))
$(eval $1_TCL_LIBRARIES_L:=$(strip $(TCL_LIBRARIES_L)))
$(eval $1_INCLUDES:=$(strip $(INCLUDES)))
$(eval $1_CONFIGS:=$(strip $(CONFIGS)))
$(eval $1_INSTALL_FILES:=$(strip $(INSTALL_FILES)))
$(eval $1_INSTALL_JARS:=$(strip $(INSTALL_JARS)))
$(eval $1_MANSECTIONS:=$(strip $(MANSECTIONS)))
$(foreach man,$($1_MANSECTIONS),$(eval $1_MAN$(man):=$(strip $(MAN$(man)))))
$(eval $1_MANl:=$(strip $(MANl)))
$(eval $1_XSDBIND:=$(strip $(XSDBIND)))
$(eval $1_XSDBIND_INCLUDE:=$(strip $(XSDBIND_INCLUDE)))
$(eval $1_ACSERRDEF:=$(strip $(ACSERRDEF)))
$(eval $1_ACSLOGTSDEF:=$(strip $(ACSLOGTSDEF)))
$(eval $1_CDB_SCHEMAS:=$(strip $(CDB_SCHEMAS)))

$(eval $1_TAO_IDLFLAGS:=$(strip $(TAO_IDLFLAGS)))
$(eval $1_IDL_EXTENSIONS:=$(strip $(IDL_EXTENSIONS)))
$(eval $1_CLASSPATH:=$(strip $(CLASSPATH)))
$(eval $1_DEBUG:=$(strip $(DEBUG)))
$(eval $1_KERNEL_MODULES:=$(strip $(KERNEL_MODULES)))
$(eval $1_USER_CXXFLAGS:=$(strip $(USER_CXXFLAGS)))
$(eval $1_USER_INC:=$(strip $(USER_INC)))
$(eval $1_USER_LIB:=$(strip $(USER_LIB)))
$(eval $1_MAKE_ONLY:=$(strip $(MAKE_ONLY)))
$(eval $1_MODULE_TARGETS:=$(strip $(MODULE_TARGETS)))
endef

#1: Module Target
define cleanModuleVars
$(eval $1_PLUGINS:=)
$(eval $1_LOAD_PLUGINS:=)
$(eval $1_LIBRARIES:=)
$(eval $1_LIBRARIES_L:=)
$(eval $1_EXECUTABLES:=)
$(eval $1_EXECUTABLES_L:=)
$(eval $1_SCRIPTS:=)
$(eval $1_SCRIPTS_L:=)
$(eval $1_PY_SCRIPTS:=)
$(eval $1_PY_SCRIPTS_L:=)
$(eval $1_PY_MODULES:=)
$(eval $1_PY_MODULES_L:=)
$(eval $1_PY_PACKAGES:=)
$(eval $1_PY_PACKAGES_L:=)
$(eval $1_JARFILES:=)
$(eval $1_JARFILES_L:=)
$(eval $1_COMPONENTS_JARFILES:=)
$(eval $1_COMPONENTS_JARFILES_L:=)
$(eval $1_IDL_FILES:=)
$(eval $1_IDL_FILES_L:=)
$(eval $1_TCL_SCRIPTS:=)
$(eval $1_TCL_SCRIPTS_L:=)
$(eval $1_TCL_LIBRARIES:=)
$(eval $1_TCL_LIBRARIES_L:=)
$(eval $1_INCLUDES:=)
$(eval $1_CONFIGS:=)
$(eval $1_INSTALL_FILES:=)
$(eval $1_INSTALL_JARS:=)
$(foreach man,$($1_MANSECTIONS),$(eval $1_MAN$(man):=))
$(eval $1_MANl:=)
$(eval $1_MANSECTIONS:=)
$(eval $1_XSDBIND:=)
$(eval $1_XSDBIND_INCLUDE:=)
$(eval $1_ACSERRDEF:=)
$(eval $1_ACSLOGTSDEF:=)
$(eval $1_CDB_SCHEMAS:=)

$(eval $1_TAO_IDLFLAGS:=)
$(eval $1_IDL_EXTENSIONS:=)
$(eval $1_CLASSPATH:=)
$(eval $1_DEBUG:=)
$(eval $1_KERNEL_MODULES:=)
$(eval $1_USER_CXXFLAGS:=)
$(eval $1_USER_INC:=)
$(eval $1_USER_LIB:=)
$(eval $1_MAKE_ONLY:=)
$(eval $1_MODULE_TARGETS:=)
endef

define cleanModuleIncludeVars
$(eval PLUGINS:=)
$(eval LOAD_PLUGINS:=)
$(eval LIBRARIES:=)
$(eval LIBRARIES_L:=)
$(eval EXECUTABLES:=)
$(eval EXECUTABLES_L:=)
$(eval SCRIPTS:=)
$(eval SCRIPTS_L:=)
$(eval PY_SCRIPTS:=)
$(eval PY_SCRIPTS_L:=)
$(eval PY_MODULES:=)
$(eval PY_MODULES_L:=)
$(eval PY_PACKAGES:=)
$(eval PY_PACKAGES_L:=)
$(eval JARFILES:=)
$(eval JARFILES_L:=)
$(eval COMPONENTS_JARFILES:=)
$(eval COMPONENTS_JARFILES_L:=)
$(eval IDL_FILES:=)
$(eval IDL_FILES_L:=)
$(eval TCL_SCRIPTS:=)
$(eval TCL_SCRIPTS_L:=)
$(eval TCL_LIBRARIES:=)
$(eval TCL_LIBRARIES_L:=)
$(eval INCLUDES:=)
$(eval CONFIGS:=)
$(eval INSTALL_FILES:=)
$(eval INSTALL_JARS:=)
$(foreach man,$(MANSECTIONS),$(eval MAN$(man):=))
$(eval MANl:=)
$(eval MANSECTIONS:=)
$(eval XSDBIND:=)
$(eval XSDBIND_INCLUDE:=)
$(eval ACSERRDEF:=)
$(eval ACSLOGTSDEF:=)
$(eval CDB_SCHEMAS:=)

$(eval TAO_IDLFLAGS:=)
$(eval IDL_EXTENSIONS:=)
$(eval CLASSPATH:=)
$(eval DEBUG:=)
$(eval KERNEL_MODULES:=)
$(eval USER_CXXFLAGS:=)
$(eval USER_INC:=)
$(eval USER_LIB:=)
$(eval MAKE_ONLY:=)
$(eval MODULE_TARGETS:=)
endef

#genGroups: Includes the group Makefile with the list of subgroups and submodules. Calls makeGroup.
#1: Group to generate
#2: Parent group name
#3: Group Relative path
#4: Group Absolute path
define genGroups
$(call args-set-names,$0,grpName,groupParent,modRelPath,modAbsPath)
$(debug-enter)
$(if $(call is-make-step,prepare-auto),
$(eval GRPRULE:=$2_$1_)
$(eval GRPDEP:=$2_$1)
$(eval include $3/$1/group.mk)
$(eval GRPRULE:=)
$(eval GRPDEP:=)
$(eval $(call storeGroupVars,$2_$1))
$(eval $(call cleanGroupIncludeVars))
)
$(if $(call is-make-step,prepare-cross),
)
$(eval $(call makeGroup,$($2_$1_MODULES),$($2_$1_GROUPS),$2_$1,$3/$1,$4/$1))
$(if $(call is-make-step,generate),
$(eval $(call cleanGroupVars,$2_$1))
)
$(debug-leave)
endef

#genGroup: Includes the group Makefile with the list of subgroups and submodules. Calls makeGroup.
#1: Group to generate
#2: Group Absolute path
define genGroup
$(call set-make-step,start)
$(call args-set-names,$0,grpName,modAbsPath)
$(debug-enter)
$(if $(filter prepare,$(MAKECMDGOALS)),,
$(eval GRPRULE:=$1_)
$(eval GRPDEP:=$1)
$(eval include group.mk)
build: $1_build
all: $1_all
install: $1_install
clean: $1_clean
clean_dist: $1_clean_dist
$(eval GRPRULE:=)
$(eval GRPDEP:=)
$(eval $(call storeGroupVars,$1))
$(eval $(call cleanGroupIncludeVars))
$(call set-make-step,prepare-auto)
$(eval $(call makeGroup,$($1_MODULES),$($1_GROUPS),$1,.,$2))
$(call set-make-step,prepare-cross)
$(eval $(call makeGroup,$($1_MODULES),$($1_GROUPS),$1,.,$2))
$(call set-make-step,generate)
$(eval $(call makeGroup,$($1_MODULES),$($1_GROUPS),$1,.,$2))
$(eval $(call cleanGroupVars,$1))
)
$(call set-make-step,execute)
$(debug-leave)
endef

#1: Module Target
define storeGroupVars
$(eval $1_MODULES:=$(MODULES))
$(eval $1_GROUPS:=$(GROUPS))
endef

#1: Module Target
define cleanGroupVars
$(eval $1_MODULES:=)
$(eval $1_GROUPS:=)
endef

define cleanGroupIncludeVars
$(eval MODULES:=)
$(eval GROUPS:=)
endef

#makeGroup: Makes the group targets(all, install, clean, clean_dist. Calls genModules and genTargets.
#1: List of modules
#2: List of groups
#3: Group Name
#4: Group Relative path
#5: Group Absolute path
define makeGroup
$(call args-set-names,$0,modules,groups,grpName,grpRelPath,grpAbsPath)
$(debug-enter)
$(foreach grp,$2,$(if $(wildcard $5/$(grp)/group.mk),$(eval $(call genGroups,$(grp),$3,$4,$5)),$(error "File $5/$(grp)/group.mk does not exist")))
$(foreach mod,$1,$(if $(or $(wildcard $5/$(mod)/src/module.mk),$(wildcard $5/$(mod)/ws/src/module.mk)),$(eval $(call genModules,$(mod),$3,$4,$5)),$(error "Files $5/$(mod)/src/module.mk and $5/$(mod)/ws/src/module.mk do not exist")))
$(if $(call is-make-step,generate),
$3: $(foreach mod,$1,$5/$(mod)) $(foreach grp,$2,$5/$(grp)) $(foreach mod,$1,$3_$(mod)_all) $(foreach grp,$2,$3_$(grp)_all)
	$(AT)
clean_$3: $(foreach mod,$1,$5/$(mod)) $(foreach grp,$2,$5/$(grp)) $(foreach mod,$1,$3_$(mod)_clean) $(foreach grp,$2,$3_$(grp)_clean)
	$(AT)
install_$3: $(foreach mod,$1,$5/$(mod)) $(foreach grp,$2,$5/$(grp)) $(foreach mod,$1,$3_$(mod)_install) $(foreach grp,$2,$3_$(grp)_install)
	$(AT)
clean_dist_$3: $(foreach mod,$1,$5/$(mod)) $(foreach grp,$2,$5/$(grp)) $(foreach mod,$1,$3_$(mod)_clean_dist) $(foreach grp,$2,$3_$(grp)_clean_dist)
	$(AT)
)
$(debug-leave)
endef

.PHONY: do_build
do_build: do_clean do_all do_install
	$(AT)echo "Branch: $(BRANCH)" > $(INSTDIR)/.version
	$(AT)echo "Revision: $(REVISION)" >> $(INSTDIR)/.version
	$(AT)echo "Status: " >> $(INSTDIR)/.version
	$(AT)echo "`git status`" >> $(INSTDIR)/.version
	$(AT)echo "Diff: " >> $(INSTDIR)/.version
	$(AT)echo "`git diff`" >> $(INSTDIR)/.version

.PHONY: do_clean
do_clean: clean_$(if $(GRP_NAME),$(GRP_NAME),$(MOD_NAME))
	$(AT)

.PHONY: do_clean_dist
do_clean_dist: clean_dist_$(if $(GRP_NAME),$(GRP_NAME),$(MOD_NAME))
	$(AT)

.PHONY: do_all
do_all: $(if $(GRP_NAME),$(GRP_NAME),$(MOD_NAME))
	$(AT)

.PHONY: do_install
do_install: prepare install_$(if $(GRP_NAME),$(GRP_NAME),$(MOD_NAME))
	$(AT)

.PHONY: build-update
build-update: build update-version
	$(AT)

.PHONY: prepare
prepare:
	$(AT)$(ECHO) "############ Prepare installation areas      #################" | tee -a build.log
	$(AT)cd $(BASEDIR)/LGPL; $(SHELL) acsBUILD/src/acsBUILDPrepareKit.sh >> ../build.log 2>& 1
	$(AT)$(MAKE) $(MAKE_FLAGS) -C $(BASEDIR)/LGPL/Kit/acs/src -f $(BASEDIR)/LGPL/Kit/acs/src/Makefile.mk clean all install >> build.log 2>& 1 || echo "### ==> FAILED! " | tee -a build.log
	$(AT)$(MAKE) $(MAKE_FLAGS) -C $(BASEDIR)/LGPL/Kit/acstempl/src -f $(BASEDIR)/LGPL/Kit/acstempl/src/Makefile.mk clean all install >> build.log 2>& 1 || echo "### ==> FAILED! " | tee -a build.log
	$(AT)$(MAKE) $(MAKE_FLAGS) -C $(BASEDIR)/LGPL/Tools/doxygen/src -f $(BASEDIR)/LGPL/Tools/doxygen/src/Makefile.mk clean all install >> build.log 2>& 1 || echo "### ==> Doxygen FAILED! " | tee -a build.log

.PHONY: update-version
update-version: prepare | $(ACSROOT) $(INSTDIR)
	$(AT)$$(if $$(wildcard $(ACSROOT)/current),rm -f $(ACSROOT)/current,)
	$(AT)ln -s $(INSTDIR) $(ACSROOT)/current

$(INSTDIR):
	$(AT)$(if $(wildcard $(INSTDIR)),,mkdir $(INSTDIR))
$(INSTDIR)/bin: | $(INSTDIR)
	$(AT)$(if $(wildcard $(INSTDIR)/bin),,mkdir $(INSTDIR)/bin)
$(INSTDIR)/lib: | $(INSTDIR)
	$(AT)$(if $(wildcard $(INSTDIR)/lib),,mkdir $(INSTDIR)/lib)
$(INSTDIR)/$(PYTHON_LIB_SUFFIX): | $(INSTDIR)/lib
	$(AT)$(if $(wildcard $(INSTDIR)/$(PYTHON_LIB_SUFFIX)),,mkdir $(INSTDIR)/$(PYTHON_LIB_SUFFIX))
	$(AT)$(if $(wildcard $(INSTDIR)/lib/python),,ln -rs $(INSTDIR)/$(PYTHON_LIB_SUFFIX) $4/lib/python)
$(INSTDIR)/$(PYTHON_SITE_PACKAGES): | $(INSTDIR)/$(PYTHON_LIB_SUFFIX)
	$(AT)$(if $(wildcard $(INSTDIR)/$(PYTHON_SITE_PACKAGES)),,mkdir $(INSTDIR)/$(PYTHON_SITE_PACKAGES))
$(INSTDIR)/$(PYTHON_SITE_PACKAGES)/__pycache__: | $(INSTDIR)/$(PYTHON_SITE_PACKAGES)
	$(AT)$(if $(wildcard $(INSTDIR)/$(PYTHON_SITE_PACKAGES)/__pycache__),,mkdir $(INSTDIR)/$(PYTHON_SITE_PACKAGES)/__pycache__)
$(INSTDIR)/$(PYTHON_SITE_PACKAGES)/%/__pycache__: | $(INSTDIR)/$(PYTHON_SITE_PACKAGES)/%
	$(AT)$(if $(wildcard $(INSTDIR)/$(PYTHON_SITE_PACKAGES)/$*/__pycache__),,mkdir $(INSTDIR)/$(PYTHON_SITE_PACKAGES)/$*/__pycache__)
$(INSTDIR)/config: | $(INSTDIR)
	$(AT)$(if $(wildcard $(INSTDIR)/config),,mkdir $(INSTDIR)/config)
$(INSTDIR)/include: | $(INSTDIR)
	$(AT)$(if $(wildcard $(INSTDIR)/include),,mkdir $(INSTDIR)/include)
$(INSTDIR)/idl: | $(INSTDIR)
	$(AT)$(if $(wildcard $(INSTDIR)/idl),,mkdir $(INSTDIR)/idl)
$(INSTDIR)/man: | $(INSTDIR)
	$(AT)$(if $(wildcard $(INSTDIR)/man),,mkdir $(INSTDIR)/man)
$(INSTDIR)/man/man1: | $(INSTDIR)/man
	$(AT)$(if $(wildcard $(INSTDIR)/man/man1),,mkdir $(INSTDIR)/man/man1)
$(INSTDIR)/man/man2: | $(INSTDIR)/man
	$(AT)$(if $(wildcard $(INSTDIR)/man/man2),,mkdir $(INSTDIR)/man/man2)
$(INSTDIR)/man/man3: | $(INSTDIR)/man
	$(AT)$(if $(wildcard $(INSTDIR)/man/man3),,mkdir $(INSTDIR)/man/man3)
$(INSTDIR)/man/man4: | $(INSTDIR)/man
	$(AT)$(if $(wildcard $(INSTDIR)/man/man4),,mkdir $(INSTDIR)/man/man4)
$(INSTDIR)/man/man5: | $(INSTDIR)/man
	$(AT)$(if $(wildcard $(INSTDIR)/man/man5),,mkdir $(INSTDIR)/man/man5)
$(INSTDIR)/man/man6: | $(INSTDIR)/man
	$(AT)$(if $(wildcard $(INSTDIR)/man/man6),,mkdir $(INSTDIR)/man/man6)
$(INSTDIR)/man/man7: | $(INSTDIR)/man
	$(AT)$(if $(wildcard $(INSTDIR)/man/man7),,mkdir $(INSTDIR)/man/man7)
$(INSTDIR)/man/man8: | $(INSTDIR)/man
	$(AT)$(if $(wildcard $(INSTDIR)/man/man8),,mkdir $(INSTDIR)/man/man8)
$(INSTDIR)/man/man9: | $(INSTDIR)/man
	$(AT)$(if $(wildcard $(INSTDIR)/man/man9),,mkdir $(INSTDIR)/man/man9)
$(INSTDIR)/kernel: | $(INSTDIR)
	$(AT)$(if $(wildcard $(INSTDIR)/kernel),,mkdir $(INSTDIR)/kernel)
$(INSTDIR)/kernel/$(kernel_install_subfold): | $(INSTDIR)/kernel
	$(AT)$(if $(wildcard $(INSTDIR)/kernel/$(kernel_install_subfold)),,mkdir $(INSTDIR)/kernel/$(kernel_install_subfold))
