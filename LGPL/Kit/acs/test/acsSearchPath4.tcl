# -*- tcl -*-
source acsRestoreEnv.tcl

set ::env(INTROOT) /introot/myIntroot
set ::env(INTLIST) /introot/herIntroot:/introot/hisIntroot:
catch {unset ::env(ACSROOT)}
catch {unset ::env(MODPATH)}
catch {unset ::env(ALMASW_INSTDIR)}
catch {unset ::env(ACSDEPS)}
