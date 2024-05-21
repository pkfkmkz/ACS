import os
import re

from time import strptime

def getVersion(default_version = "0.0"):
    if "ACS_DEPLOY_VERSION" in os.environ and os.getenv("ACS_DEPLOY_VERSION"):
        return os.getenv("ACS_DEPLOY_VERSION")
    if "ALMASW_RELEASE" not in os.environ or not os.getenv('ALMASW_RELEASE'):
        return default_version
    almasw_rel = os.getenv('ALMASW_RELEASE')
    if re.fullmatch(r'ACS-\d{4}(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)', almasw_rel) is None:
        return almasw_rel
    rel_date = strptime(almasw_rel[4:11],'%Y%b')
    return str(rel_date.tm_year) + "." + str(rel_date.tm_mon).zfill(2)
