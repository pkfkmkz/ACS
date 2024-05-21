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

# definition of in-test exceptions
class noDataException (Exception) : pass
class notNulDataException (Exception) : pass

# Make an instance of the PySimpleClient
simpleClient = PySimpleClient()

mc = simpleClient.getComponent(argv[1])

# Test preparation
cname = 'MC_TEST_COMPONENT2'
try:
    tc = simpleClient.getComponent(cname)
    psns =[propertySerailNumber('doubleSeqProp', ['12124']),
           propertySerailNumber('doubleProp', ['3432535'])
           ]
    # doubleSeqProp component archive_suppress defined to true (MC_TEST_COMPONENT2.xml)
    # doubleProp component archive_suppress defined to true (MC_TEST_COMPONENT2.xml)
    # longProp component archive_suppress defined to true (MC_TEST_COMPONENT2.xml)
    # longSeqProp component archive_suppress defined to false (MC_TEST_COMPONENT2.xml)
    # patternProp component archive_suppress defined to false (MC_TEST_COMPONENT2.xml)
    mc.registerMonitoredDeviceWithMultipleSerial(cname, psns)
    print("Test preparation with SUCCESS")

except MonitorErr.RegisteringDeviceProblemEx as _ex:
    ex = MonitorErrImpl.RegisteringDeviceProblemExImpl(exception=_ex)
    ex.Print()
    print("Test preparation FAIL")

# Test Case 1: Verify static configuration of archive suppress parameter
try:
    # Reset any values
    tc.reset()
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
    time.sleep(5)
    # Stop monitoring
    mc.stopMonitoring(cname)

    # Verify if monitor data has been generated
    data = mc.getMonitorData()
    # Calculate if data is present
    alreadyStoredData=0
    for d in data:
        for blob in d.monitorBlobs:
            for blobData in any.from_any(blob.blobDataSeq):
                alreadyStoredData+=1
    if alreadyStoredData == 0:
        print("TEST FAIL: No monitor data is found (TC1)")
        raise noDataException

except noDataException:
    pass
except notNulDataException:
    pass
except MonitorErr.RegisteringDeviceProblemEx as _ex:
    ex = MonitorErrImpl.RegisteringDeviceProblemExImpl(exception=_ex)
    ex.Print()

# Print out recovered data
print("RESULTS FROM TEST CASE1: Verify static configuration of archive suppress parameter")
print("Number of Devices:", len(data))
for d in data:
    print(d.componentName, d.deviceSerialNumber)
    for blob in d.monitorBlobs:
        print("\t", blob.propertyName, " ", blob.propertySerialNumber, sep='')
        i=0
        for blobData in any.from_any(blob.blobDataSeq):
            if not "-" in str(blobData) and i<3:
                print("\t\t", dict(sorted(blobData.items(), reverse=True)), sep='')
                i+=1

# Test Case 2: Verify dynamic archival enabling
try:
    # Reset any values
    tc.reset()
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
    # Start monitor
    mc.startMonitoring(cname)
    # Enable archival of two properties previously disabled
    mc.enable_archiving(cname,'doubleSeqProp')
    mc.enable_archiving(cname,'doubleProp')
    # Wait some time to generate data
    time.sleep(5)
    # Stop monitoring
    mc.stopMonitoring(cname)

    # Verify if monitor data has been generated
    data = mc.getMonitorData()
    # Calculate if data is present
    alreadyStoredData=0
    for d in data:
        for blob in d.monitorBlobs:
            for blobData in any.from_any(blob.blobDataSeq):
                alreadyStoredData+=1
    if alreadyStoredData == 0:
        print("TEST FAIL: No monitor data is found (TC2)")
        raise noDataException

except noDataException:
    pass
except notNulDataException:
    pass
except MonitorErr.RegisteringDeviceProblemEx as _ex:
    ex = MonitorErrImpl.RegisteringDeviceProblemExImpl(exception=_ex)
    ex.Print()

# Print out recovered data
print("RESULTS FROM TEST CASE2: Verify dynamic archival enabling")
print("Number of Devices:", len(data))
for d in data:
    print(d.componentName, d.deviceSerialNumber)
    for blob in d.monitorBlobs:
        print("\t", blob.propertyName, " ", blob.propertySerialNumber, sep='')
        i=0
        for blobData in any.from_any(blob.blobDataSeq):
            if not "-" in str(blobData) and i<3:
                print("\t\t", dict(sorted(blobData.items(), reverse=True)), sep='')
                i+=1

# Test Case 3: Verify dynamic archival disabling
try:
    # Reset any values
    tc.reset()
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
    # Start monitor
    mc.startMonitoring(cname)
    # Disable archival of two properties previously enabled
    mc.suppress_archiving(cname,'longSeqProp')
    mc.suppress_archiving(cname,'patternProp')
    # Wait some time to generate data
    time.sleep(5)
    # Stop monitoring
    mc.stopMonitoring(cname)

    # Verify if monitor data has been generated
    data = mc.getMonitorData()
    # Calculate if data is present
    alreadyStoredData=0
    for d in data:
        for blob in d.monitorBlobs:
            for blobData in any.from_any(blob.blobDataSeq):
                alreadyStoredData+=1
    if alreadyStoredData == 0:
        print("TEST FAIL: No monitor data is found (TC3)")
        raise noDataException

except noDataException:
    pass
except notNulDataException:
    pass
except MonitorErr.RegisteringDeviceProblemEx as _ex:
    ex = MonitorErrImpl.RegisteringDeviceProblemExImpl(exception=_ex)
    ex.Print()

# Print out recovered data
print("RESULTS FROM TEST CASE3: Verify dynamic archival disabling")
print("Number of Devices:", len(data))
for d in data:
    print(d.componentName, d.deviceSerialNumber)
    for blob in d.monitorBlobs:
        print("\t", blob.propertyName, " ", blob.propertySerialNumber, sep='')
        i=0
        for blobData in any.from_any(blob.blobDataSeq):
            if not "-" in str(blobData) and i<3:
                print("\t\t", dict(sorted(blobData.items(), reverse=True)), sep='')
                i+=1

mc.deregisterMonitoredDevice(cname)

#cleanly disconnect
simpleClient.releaseComponent(argv[1])
simpleClient.disconnect()
stdout.flush()
