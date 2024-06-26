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
from TMCDB                      import MonitorCollector
from TMCDB                      import propertySerailNumber
from omniORB                    import any
import MonitorErrImpl
import MonitorErr
import time

#Make an instance of the PySimpleClient
simpleClient = PySimpleClient()

mc = simpleClient.getComponent(argv[1])
cname = "MC_TEST_COMPONENT"

try:
    tc =   simpleClient.getComponent(cname)
    psns =[propertySerailNumber('doubleSeqProp', ['12124']),propertySerailNumber('doubleProp', ['3432535'])]
    mc.registerNonCollocatedMonitoredDeviceWithMultipleSerial(cname, psns)
    tc.reset()
    mc.startMonitoring(cname)
    time.sleep(22)
    mc.stopMonitoring(cname)
except MonitorErr.RegisteringDeviceProblemEx as _ex:
    ex = MonitorErrImpl.RegisteringDeviceProblemExImpl(exception=_ex)
    ex.Print()

data = mc.getMonitorData()

print("Number of Devices:", len(data))
for d in data:
    print(d.componentName, d.deviceSerialNumber)
    blobs = sorted(d.monitorBlobs, key=lambda blob: blob.propertyName)
    for blob in blobs:
        print("\t", blob.propertyName, " ", blob.propertySerialNumber, sep='')
        i=0
        for blobData in any.from_any(blob.blobDataSeq):
            if i<20:
                print("\t\t", dict(sorted(blobData.items(), reverse=True)), sep='')
                i+=1

mc.deregisterMonitoredDevice(cname)

#cleanly disconnect
simpleClient.releaseComponent(argv[1])
simpleClient.disconnect()
