PROFILE:=Linux
MAKEPROFILEDIR:=$(if $(wildcard $(MAKEDIR)/../include/acsMakefileProfile.$(PROFILE).mk),$(MAKEDIR)/..,$(shell searchFile include/acsMakefileProfile.$(PROFILE).mk))
$(if $(filter $(MAKEPROFILEDIR),#error#), $(error "$(PROFILE) Makefile Profile couldn't be found."),$(eval MAKEPROFILEDIR:=$(MAKEPROFILEDIR)/include)$(eval include $(MAKEPROFILEDIR)/acsMakefileProfile.$(PROFILE).mk))

CSTD_AVAILABLE=$(patsubst -std=gnu%,%,$(filter-out [disabled],$(sort $(shell $$(gcc -print-prog-name=cc1) --help | grep std=gnu |grep -v gnu++))))
CSTD_PRIO=17 11 1x 99
CSTD=-std=gnu$(firstword $(filter $(CSTD_AVAILABLE),$(CSTD_PRIO)))

CXXSTD_AVAILABLE=$(patsubst -std=gnu++%,%,$(filter-out [disabled],$(sort $(shell $$(gcc -print-prog-name=cc1plus) --help | grep std=gnu++))))
CXXSTD_PRIO=17 1z 14 1y 11 0x 03 98
CXXSTD=-std=gnu++$(firstword $(filter $(CXXSTD_AVAILABLE),$(CXXSTD_PRIO)))

export ECHO:=echo -e
