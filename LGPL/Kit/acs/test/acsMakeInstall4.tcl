# -*- tcl -*-
source acsRestoreEnv.tcl

file mkdir [pwd]/myIntroot/$env(PYTHON_SITE_PACKAGES)
set ::env(INTROOT) [pwd]/myIntroot

exec touch AcsPyTestPkg2/D.py
