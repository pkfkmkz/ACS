#!/usr/bin/env python
#*******************************************************************************
# ALMA - Atacama Large Millimiter Array
# (c) Associated Universities Inc., 2002
# (c) European Southern Observatory, 2002
# Copyright by ESO (in the framework of the ALMA collaboration)
# and Cosylab 2002, All rights reserved
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307  USA
#

from __future__ import print_function
from Acspy.Clients.SimpleClient import PySimpleClient
from sys                        import argv
from sys                        import exit
from sys                        import stdout
from TMCDB                      import MonitorCollector
from TMCDB                      import propertySerailNumber
from omniORB                    import any
import MonitorErrImpl
import MonitorErr
import time

def getPropertiesSerialNumbers(comp):
    props = []
    for p in comp.descriptor().properties:
        props.append(p.name.split(':')[1])
    props.sort()
    psns = []
    for i in range(len(props)):
        psns.append(propertySerailNumber(props[i], [str(i+1)]))
    return psns

# definition of in-test exceptions
class noDataException (Exception) : pass
class notNulDataException (Exception) : pass

# Make an instance of the PySimpleClient
simpleClient = PySimpleClient()

mc = simpleClient.getComponent(argv[1])
cname = "MC_TEST_PROPERTIES_COMPONENT"

# Test preparation
try:
    tc =   simpleClient.getComponent(cname)
    psns =[propertySerailNumber('doubleROProp',       ['1' ]),
           propertySerailNumber('floatROProp',        ['2' ]),
           propertySerailNumber('longROProp',         ['3' ]),
           propertySerailNumber('uLongROProp',        ['4' ]),
           propertySerailNumber('patternROProp',      ['5' ]),
           propertySerailNumber('stringROProp',       ['6' ]),
           propertySerailNumber('longLongROProp',     ['7' ]),
           propertySerailNumber('uLongLongROProp',    ['8' ]),
           propertySerailNumber('booleanROProp',      ['9' ]),
           propertySerailNumber('doubleSeqROProp',    ['10']),
           propertySerailNumber('floatSeqROProp',     ['11']),
           propertySerailNumber('longSeqROProp',      ['12']),
           propertySerailNumber('uLongSeqROProp',     ['13']),
           propertySerailNumber('longLongSeqROProp',  ['14']),
           propertySerailNumber('uLongLongSeqROProp', ['15']),
           propertySerailNumber('booleanSeqROProp',   ['16']),
           propertySerailNumber('EnumTestROProp',     ['17']),
           propertySerailNumber('doubleRWProp',       ['18']),
           propertySerailNumber('floatRWProp',        ['19']),
           propertySerailNumber('longRWProp',         ['20']),
           propertySerailNumber('uLongRWProp',        ['21']),
           propertySerailNumber('patternRWProp',      ['22']),
           propertySerailNumber('stringRWProp',       ['23']),
           propertySerailNumber('longLongRWProp',     ['24']),
           propertySerailNumber('uLongLongRWProp',    ['25']),
           propertySerailNumber('booleanRWProp',      ['26']),
           propertySerailNumber('doubleSeqRWProp',    ['27']),
           propertySerailNumber('floatSeqRWProp',     ['28']),
           propertySerailNumber('longSeqRWProp',      ['29']),
           propertySerailNumber('uLongSeqRWProp',     ['30']),
           propertySerailNumber('longLongSeqRWProp',  ['31']),
           propertySerailNumber('uLongLongSeqRWProp', ['32']),
           propertySerailNumber('booleanSeqRWProp',   ['33']),
           propertySerailNumber('EnumTestRWProp',     ['34'])
        ]
    mc.registerMonitoredDeviceWithMultipleSerial(cname, psns)
    print("Test preparation with SUCCESS")
except MonitorErr.RegisteringDeviceProblemEx as _ex:
    ex = MonitorErrImpl.RegisteringDeviceProblemExImpl(exception=_ex)
    ex.Print()
    print("Test preparation FAIL")

# Test Case 1: Verify monitoring for all properties available
try:
    # Verify that no monitor values exist
    data = mc.getMonitorData()
    # Calculate if data is present
    alreadyStoredData=0
    for d in data:
        for blob in d.monitorBlobs:
            for blobData in any.from_any(blob.blobDataSeq):
                alreadyStoredData+=1
    if alreadyStoredData != 0:
        print("TEST FAIL: Data present before start monitor")
        raise notNulDataException
    # Start monitor and wait some time to generate data
    mc.startMonitoring(cname)
    time.sleep(3)
    # Stop monitoring
    mc.stopMonitoring(cname)
    # Verify if monitor data have been generated
    data = mc.getMonitorData()
    # Calculate if data is present
    alreadyStoredData=0
    for d in data:
        for blob in d.monitorBlobs:
            for blobData in any.from_any(blob.blobDataSeq):
                alreadyStoredData+=1
    if alreadyStoredData == 0:
        print("TEST FAIL: No monitor data is found")
        raise noDataException

except noDataException:
    pass
except notNulDataException:
    pass
except MonitorErr.RegisteringDeviceProblemEx as _ex:
    ex = MonitorErrImpl.RegisteringDeviceProblemExImpl(exception=_ex)
    ex.Print()

# Print out recovered data
print("RESULTS FROM TEST CASE1: Verify monitoring for all properties available")
print("Number of Devices:", len(data))
for d in data:
    print(d.componentName, d.deviceSerialNumber)
    for blob in d.monitorBlobs:
        print("\t", blob.propertyName, " ", blob.propertySerialNumber, sep='')
        i=0
        for blobData in any.from_any(blob.blobDataSeq):
            if i<2:
                print("\t\t", dict(sorted(blobData.items(), reverse=True)), sep='')
                i+=1

mc.deregisterMonitoredDevice(cname)

#cleanly disconnect
simpleClient.releaseComponent(argv[1])
simpleClient.disconnect()
stdout.flush()
