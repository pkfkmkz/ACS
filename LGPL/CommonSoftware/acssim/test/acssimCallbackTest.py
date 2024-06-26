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
# @(#) $Id: acssimCallbackTest.py,v 1.1 2004/10/26 20:24:27 dfugate Exp $
#------------------------------------------------------------------------------

'''
Tests a callback void method.
'''
from __future__ import print_function
from sys import argv
from time import sleep
from Acspy.Clients.SimpleClient import PySimpleClient
from Acspy.Common.Callbacks     import CBvoid
from ACS import CBDescIn

compName = argv[1]
compMethod = argv[2]

print("Parameters to this generic test script are:", argv[1:])

# Make an instance of the PySimpleClient
simpleClient = PySimpleClient()
comp = simpleClient.getComponent(compName)

myCB = CBvoid()
myCorbaCB = simpleClient.activateOffShoot(myCB)
myDescIn = CBDescIn(0, 0, 0)

joe = getattr(comp, compMethod)(myCorbaCB, myDescIn)
print("Method executed...now just waiting on CB status")

for i in range(0, 50):
    if myCB.status == 'DONE':
        print("The callback has finished!")
        break
    else:
        sleep(1)

simpleClient.releaseComponent(compName)
simpleClient.disconnect()
