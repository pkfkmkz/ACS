# -*- tcl -*-
source acsRestoreEnv.tcl

set ::env(INTROOT) /introot/myNotExistingIntroot/
set ::env(INTLIST) /introot/herNotExistingIntroot:/introot/hisNotExistingIntroot
set ::env(ACSROOT) /alma/ACSNotExisting/ACSSW
# setting MODPATH to 1 will include ..
set ::env(MODPATH) 1
set ::env(ALMASW_INSTDIR) /alma/ACSNotExisting
set ::env(ACSDEPS) /alma/ACSNotExisting/acsdeps
