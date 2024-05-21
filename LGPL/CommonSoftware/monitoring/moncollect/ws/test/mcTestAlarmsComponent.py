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

import time

from sys import argv
from sys import stdout

import MonitorErr
import MonitorErrImpl

from omniORB import any
from TMCDB import propertySerailNumber
from Acspy.Clients.SimpleClient import PySimpleClient

def getPropertiesSerialNumbers(comp):
    props = []
    for p in comp.descriptor().properties:
        props.append(p.name.split(':')[1])
    props.sort()
    psns = []
    for i in range(len(props)):
        psns.append(propertySerailNumber(props[i], [str(i+1)]))
    return psns

n_exec = int(argv[2])

for index_loop in range(0, n_exec):
    # Make an instance of the PySimpleClient
    simpleClient = PySimpleClient()

    mc = simpleClient.getComponent(argv[1])
    cname = "MC_TEST_ALARMS_COMPONENT"

    try:
        tc = simpleClient.getComponent(cname)
        psns =[propertySerailNumber('doubleROProp',       ['1' ]),
               propertySerailNumber('floatROProp',        ['2' ]),
               propertySerailNumber('longROProp',         ['3' ]),
               propertySerailNumber('uLongROProp',        ['4' ]),
               propertySerailNumber('longLongROProp',     ['5' ]),
               propertySerailNumber('uLongLongROProp',    ['6' ]),
               propertySerailNumber('booleanROProp',      ['7' ]),
               propertySerailNumber('doubleSeqROProp',    ['8' ]),
               propertySerailNumber('floatSeqROProp',     ['9' ]),
               propertySerailNumber('longSeqROProp',      ['10']),
               propertySerailNumber('uLongSeqROProp',     ['11']),
               propertySerailNumber('longLongSeqROProp',  ['12']),
               propertySerailNumber('uLongLongSeqROProp', ['13']),
               propertySerailNumber('booleanSeqROProp',   ['14']),
               propertySerailNumber('EnumTestROProp',     ['15'])
            ]
        mc.registerMonitoredDeviceWithMultipleSerial(cname, psns)
        tc.reset()
        time.sleep(1)
        mc.startMonitoring(cname)
        time.sleep(1.1)
        tc.increase()
        time.sleep(1)
        tc.increase()
        time.sleep(1)
        tc.increase()
        time.sleep(1)
        tc.increase()
        time.sleep(1)
        tc.increase()
        time.sleep(1)
        tc.increase()
        time.sleep(1)
        tc.increase()
        time.sleep(1)
        tc.increase()
        time.sleep(1)
        tc.increase()
        time.sleep(1)
        tc.increase()
        mc.stopMonitoring(cname)
    except MonitorErr.RegisteringDeviceProblemEx as _ex:
        ex = MonitorErrImpl.RegisteringDeviceProblemExImpl(exception=_ex)
        ex.Print()

    data = mc.getMonitorData()

    print("Number of Devices:", len(data))
    for d in data:
        print(d.componentName, d.deviceSerialNumber)
        for blob in d.monitorBlobs:
            print("\t", blob.propertyName, " ", blob.propertySerialNumber, sep='')
            i=0
            prevVal=-333
            for blobData in any.from_any(blob.blobDataSeq):
                # we use here a dirt trick, because we set timeout to 134608945243381570
                # so we know if the value comes from an alarm monitor or normal monitor
                if blobData['time'] != 134608945243381570: # Normal monitor
                    #print("\t\t", blobData, sep='')
                    continue
                else: # Alarm monitor
                    # here we prevent to write a value more than once what can happen during sleep of 1 s
                    # so that we have deterministic results of the test
                    if blobData['value'] != prevVal:
                        print("Alarm: \t", dict(sorted(blobData.items(), reverse=True)), sep='')
                        prevVal = blobData['value']

    mc.deregisterMonitoredDevice(cname)

    #cleanly disconnect
    simpleClient.releaseComponent(argv[1])
    simpleClient.disconnect()
    stdout.flush()
    print(":::::::::::  Finished execution ", index_loop)

