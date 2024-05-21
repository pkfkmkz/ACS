MAKEID:=acs
MAKEDIR:=$(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
MOD_PATH:=$(patsubst %/,%,$(abspath $(MAKEDIR)/..))
MOD_NAME:=$(if $(filter ws,$(notdir $(MOD_PATH))),$(notdir $(patsubst %/,%,$(dir $(MOD_PATH)))),$(notdir $(MOD_PATH)))
MAKEDIRTMP:=$(if $(wildcard $(MAKEDIR)/../include/InclusiveMakefile.mk),$(abspath $(MAKEDIR)/..),$(shell searchFile include/InclusiveMakefile.mk))/include
$(if $(filter #error#%,$(MAKEDIRTMP)),$(error "InclusiveMakefile.mk was not found."),$(eval include $(MAKEDIRTMP)/InclusiveMakefile.mk))
$(eval $(call genModule,$(MOD_NAME),$(MOD_PATH)))
