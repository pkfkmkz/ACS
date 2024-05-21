$(if $(ALMASW_INSTDIR),,$(error The ACS environment should be loaded. Please source .bash_profile.acs))
INSTALL_DIR:=$(if $(INSTALL_DIR),$(INSTALL_DIR),$(ACSDEPS))

remove-digit=$(subst $2,,$1)
is-digit=$(eval tmp:=$1)$(eval $(foreach dig,0 1 2 3 4 5 6 7 8 9,$(eval tmp:=$(call remove-digit,$(tmp),$(dig)))))$(tmp)

CMD:=$(shell ps T | grep "^\s*$(shell echo $$PPID).*$(MAKE)")
CMD_J_FLAG:=$(filter -j%, $(subst -j ,-j,$(subst --jobs ,-j,$(subst --jobs=,-j,$(CMD)))))
JOBS:=$(subst -j,,$(CMD_J_FLAG))
NUM_CPU:=$(if $(JOB_FLAG),$(if $(call is-digit,$(JOBS)),all,$(JOBS)))
JOB_FLAG:=$(if $(NUM_CPU),$(if $(filter all,$(NUM_CPU)),-j,-j$(NUM_CPU)))

incs:=$(wildcard */src/Makefile)
deps:=$(patsubst %/src/Makefile,%,$(incs))

$(INSTALL_DIR)/include/config.mk: config.mk
	cp $^ $@

include $(INSTALL_DIR)/include/config.mk

#1 Dependency name
define prepare-module
$(eval MODPATH:=$1)
$(eval MODRULE:=$1_)
$(eval include $1/src/Makefile)
$1_all: MODPATH:=$(MODPATH)
$1_all: MODRULE:=$(MODRULE)
$1_clean: MODPATH:=$(MODPATH)
$1_clean: MODRULE:=$(MODRULE)
$1_clean_dist: MODPATH:=$(MODPATH)
$1_clean_dist: MODRULE:=$(MODRULE)
$1_install: MODPATH:=$(MODPATH)
$1_install: MODRULE:=$(MODRULE)
endef

$(foreach dep,$(deps),$(eval $(call prepare-module,$(dep))))
MODPATH:=
MODRULE:=

.PHONY: build
build: all install
all: $(addsuffix _all,$(deps))
clean: $(addsuffix _clean,$(deps))
clean_dist: $(addsuffix _clean_dist,$(deps))
install: $(addsuffix _install,$(deps))
