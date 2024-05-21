#*******************************************************************************
# This Makefile follows ACS Standards (see Makefile(5) for more).
#*******************************************************************************
# REMARKS
#    None
#------------------------------------------------------------------------

-include $(MODPATH)/src/rules.mk

$(MODRULE)all: $(MODPATH) $(MODDEP) $(MODRULE)gen
	$(AT)echo " . . . $@ done"

$(MODRULE)install: $(MODPATH) install_$(MODDEP)
	$(AT)echo " . . . $@ done"

$(MODRULE)clean: $(MODPATH) clean_$(MODDEP)
	$(AT)$(if $(wildcard $(MODPATH)/src/xmlpybind),rm -rf $(MODPATH)/src/xmlpybind,)
	$(AT)echo " . . . $@ done"

$(MODRULE)clean_dist: $(MODPATH) clean_dist_$(MODDEP)
	$(AT)echo " . . . $@ done"

.INTERMEDIATE: $(MODRULE)gen
$(MODRULE)gen: $(MODPATH)/src/xmlpybind/EntitybuilderSettings.py

$(MODPATH)/src/xmlpybind: $(MODPATH)/src/xmlpybind/EntitybuilderSettings.py

$(MODPATH)/src/xmlpybind/EntitybuilderSettings.py: $(MODPATH)/../xmljbind/src/alma/tools/entitybuilder/EntitybuilderSettings.xsd
	@echo "genearting schemata..."
	pyxbgen --module-prefix=xmlpybind -u $(MODPATH)/../xmljbind/src/alma/tools/entitybuilder/EntitybuilderSettings.xsd -m EntitybuilderSettings --binding-root=$(MODPATH)/src
