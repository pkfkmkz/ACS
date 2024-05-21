PY_EXT_DOC_L	   = pexpect-doc

#ACS Variables
PY_SCRIPTS         = pythfilter
PY_SCRIPTS_L       =

PY_MODULES         = acs_python 
PY_MODULES_L       =

PY_PACKAGES        = Pmw
PY_PACKAGES_L      =
pppppp_MODULES	   =

INSTALL_FILES:=

#ACS Rules
$(MODRULE)all: $(MODPATH) $(MODDEP)
	$(AT)echo " . . . $@ done"

$(MODRULE)install: $(MODPATH) install_$(MODDEP)
	$(AT)echo " . . . $@ done"

$(MODRULE)clean: $(MODPATH) clean_$(MODDEP)
	$(AT)$(if $(wildcard $(addprefix $(MODPATH)/,doc/doc doc/api doc/idl)),rm -r $(wildcard $(addprefix $(MODPATH)/,doc/doc doc/api doc/idl)),)
	$(AT)echo " . . . $@ done"

$(MODRULE)clean_dist: $(MODPATH) clean_dist_$(MODDEP)
	$(AT)echo " . . . $@ done"

PY_DOC:
	$(foreach file, $(PY_EXT_DOC_L), - $(AT) cd ../doc; if [ -e $(file).tgz ]; then echo "== Extracting external documentation: $(file).tgz"; $(TAR) -zxvf $(file).tgz; fi )
