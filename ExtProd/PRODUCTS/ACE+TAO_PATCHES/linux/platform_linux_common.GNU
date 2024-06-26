# -*- Makefile -*-
# $Id: platform_linux_common.GNU,v 1.1 2007/10/18 06:57:34 bjeram Exp $

# We always include config-linux.h on Linux platforms.
ACE_PLATFORM_CONFIG ?= config-linux.h

exceptions ?= 1
debug ?= 1
optimize ?= 1
threads ?= 1
insure ?= 0

LSB_RELEASE_ID := $(shell lsb_release -i 2> /dev/null || echo Distributor ID: Unknown)
LSB_RELEASE_RELEASE := $(shell lsb_release -r 2> /dev/null || echo Release: Unknown)

PLATFORM_XT_CPPFLAGS=
PLATFORM_XT_LIBS=-lXt
PLATFORM_XT_LDFLAGS=

PLATFORM_FL_CPPFLAGS=
PLATFORM_FL_LIBS=-lfltk -lfltk_forms -lfltk_gl
PLATFORM_FL_LDFLAGS=

PLATFORM_X11_CPPFLAGS=-I/usr/X11R6/include
PLATFORM_X11_LIBS=-lX11
PLATFORM_X11_LDFLAGS=-L/usr/X11R6/lib

PLATFORM_GL_CPPFLAGS=-I/usr/X11R6/include
PLATFORM_GL_LIBS    =-lGL
PLATFORM_GL_LDFLAGS =-L/usr/X11R6/lib

PLATFORM_GTK_CPPFLAGS=$(shell gtk-config --cflags)
PLATFORM_GTK_LIBS    =$(shell gtk-config --libs)
PLATFORM_GTK_LDFLAGS =

PLATFORM_FOX_CPPFLAGS ?= -I/usr/include/fox
PLATFORM_FOX_LIBS     ?= -lFOX
PLATFORM_FOX_LDFLAGS  ?=

# NOTE: we only support wxWindows over GTK
PLATFORM_WX_CPPFLAGS= $(shell wx-config --cxxflags) $(PLATFORM_GTK_CPPFLAGS)
PLATFORM_WX_LIBS    = $(shell wx-config --libs)     $(PLATFORM_GTK_LIBS)
PLATFORM_WX_LDFLAGS = $(shell wx-config --ldflags)  $(PLATFORM_GTK_LDFLAGS)

PLATFORM_BOOST_CPPFLAGS ?=
PLATFORM_BOOST_LDLAGS ?=
PLATFORM_BOOST_UTF_LIBS ?= -lboost_unit_test_framework

ace_source_if_exists=$(if $(wildcard $(1)), $(shell . $(1) $(2)))
ace_buildbits_64=$(findstring 64,$(buildbits))

PLATFORM_TK_CPPFLAGS=$(call ace_source_if_exists,/usr/lib$(ace_buildbits_64)/tkConfig.sh,&& echo -n $$TK_INCLUDE_SPEC $$TK_DEFS)
PLATFORM_TK_LIBS=$(call ace_source_if_exists,/usr/lib$(ace_buildbits_64)/tkConfig.sh,&& echo -n $$TK_LIB_FLAG)
PLATFORM_TK_LDFLAGS=

PLATFORM_TCL_CPPFLAGS=$(call ace_source_if_exists,/usr/lib$(ace_buildbits_64)/tclConfig.sh,&& echo -n $$TCL_INCLUDE_SPEC $$TCL_DEFS)
PLATFORM_TCL_LIBS=$(call ace_source_if_exists,/usr/lib$(ace_buildbits_64)/tclConfig.sh,&& echo -n $$(eval echo $$TCL_LIB_FLAG))
PLATFORM_TCL_LDFLAGS=

PLATFORM_QT_CPPFLAGS ?= -I$(QTDIR)/include
PLATFORM_QT_LIBS ?= -lqt-mt
PLATFORM_QT_LDFLAGS ?= -L$(QTDIR)/lib

sctp ?=
# support for OpenSS7 SCTP
ifeq ($(sctp),openss7)
  PLATFORM_SCTP_CPPFLAGS+= -DACE_HAS_OPENSS7_SCTP
  PLATFORM_SCTP_LDFLAGS?=
  PLATFORM_SCTP_LIBS?=
endif

# support for LKSCTP (Linux Kernel 2.5)
ifeq ($(sctp),lksctp)
  PLATFORM_SCTP_CPPFLAGS+= -DACE_HAS_LKSCTP
  PLATFORM_SCTP_LDFLAGS?= -L/usr/local/lib
  PLATFORM_SCTP_LIBS?= -lsctp
endif

GNU_LIBPTHREAD_VERSION := $(shell getconf GNU_LIBPTHREAD_VERSION 2> /dev/null || echo Unknown)
ifeq (NPTL, $(word 1,$(GNU_LIBPTHREAD_VERSION)))
  NPTL_VERS := $(subst ., ,$(word 2,$(GNU_LIBPTHREAD_VERSION)))
  ifneq (0, $(word 1,$(NPTL_VERS)))
    nptl ?= 1
  endif
endif
nptl ?= 0
ifeq ($(nptl),0)
  CPPFLAGS += -DACE_LACKS_LINUX_NPTL
endif

ssl ?= 0
ifeq ($(ssl),1)
  # Some Linux OpenSSL installations compile in Kerberos support.  Add
  # the Kerberos include path to preprocessor include path.
  #
  # We should probably also add the Kerberos libraries to
  # PLATFORM_SSL_LIBS but we can't be sure if they are needed without
  # a more sophisticated check.  This will only be a problem when
  # statically linking the OpenSSL library.  The majority of
  # installations use shared OpenSSL libraries so we should be okay,
  # at least until we migrate to Autoconf.
  PLATFORM_SSL_CPPFLAGS += -I/usr/kerberos/include
endif # ssl

PLATFORM_LARGEFILE_CFLAGS := $(shell getconf LFS_CFLAGS 2> /dev/null)
ifdef PLATFORM_LARGEFILE_CFLAGS
  # Large file support
  CPPFLAGS += $(PLATFORM_LARGEFILE_CFLAGS)
endif

SYSARCH := $(shell uname -m)

PIC      = -fPIC
AR      ?= ar
ARFLAGS ?= rsuv
RANLIB   = @true

# Added line below to support "Executable Shared Object" files (as
# needed by the service configurator).
# Marius Kjeldahl <mariusk@sn.no, marius@funcom.com>
ifeq ($(threads),1)
    ESOBUILD = $(COMPILEESO.cc) $(PIC) -shared -o $(VSHDIR)$*.so $<
    ifndef PRELIB
       PRELIB = @true
    endif # ! PRELIB
endif

# DT_RUNPATH is preferred over DT_RPATH, but the linker will only use it when
# this extra flag option (enable-new-dtags) is present
LD_RPATH_FLAGS += -Wl,--enable-new-dtags

# Rely on _GNU_SOURCE to set these defaults defined in /usr/include/features.h
# instead of setting them directly here (older versions of gcc don't set it
# for you): _SVID_SOURCE _BSD_SOURCE _POSIX_SOURCE _POSIX_C_SOURCE=199506L, ...
CPPFLAGS += -D_GNU_SOURCE

DCFLAGS  += -ggdb
DCCFLAGS += -ggdb
DLD      = $(CXX)
LD       = $(CXX)

ifeq ($(optimize),1)
  SOFLAGS += -Wl,-O3
endif

SOFLAGS += -shared
SOBUILD = $(COMPILE.cc) $(PIC) -o $(VSHDIR)$*.so $<; \
          $(SOLINK.cc) -o $@ $(LDFLAGS) $(VSHDIR)$*.o
PRELIB  = @true
