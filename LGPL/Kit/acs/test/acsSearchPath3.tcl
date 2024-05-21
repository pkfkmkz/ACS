# -*- tcl -*-
source acsRestoreEnv.tcl

set ::env(INTROOT) /introot/myIntroot/:
set ::env(INTLIST) /introot/herIntroot//::/introot///hisIntroot:
set ::env(ACSROOT) /alma/ACS15//ACSSW
# setting MODPATH to anything but 1 should give same result as unsetting
set ::env(MODPATH) 2
set ::env(ALMASW_INSTDIR) /alma/ACS15
set ::env(ACSDEPS) /alma/ACS15/acsdeps
