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
# @(#) $Id: acspyexmplHelloWorldError.py,v 1.11 2009/02/09 18:56:50 agrimstrup Exp $
#------------------------------------------------------------------------------

'''
DESCRIPTION
This client consists of an example which invokes a method on a C++
<a href="../../idl/html/interfaceHelloWorld_1_1HelloWorld.html">Hello World</a>
component which always raises an exception generated by the ACS Error System. 
The inteded purpose here is to give developers a concrete example on converting
CORBA exceptions (generated by the ACS Error System) into (ACS Error System generated)
Python exceptions. Once the CORBA exception has been converted to its associated
Python helper class, many useful methods become available such as directly logging
the exception to the ACS Logging System.

WHAT CAN I GAIN FROM THIS EXAMPLE?
- PySimpleClient usage.
- Accessing (remote) components.
- Converting (ACS Error System) CORBA exceptions into their related Python exception helper classes.
- Logging (ACS Error System) CORBA exceptions.

LINKS
- <a href="../../idl/html/interfaceHelloWorld_1_1HelloWorld.html">HelloWorld IDL Documentation</a>
'''

import ACSErrTypeCommon
import ACSErrTypeCommonImpl

# Import the acspy.PySimpleClient class
from Acspy.Clients.SimpleClient import PySimpleClient

# Make an instance of the PySimpleClient
simpleClient = PySimpleClient()

try:
    # Get the standard HelloWorld device
    hw = simpleClient.getComponent("HELLOWORLD1")
    simpleClient.getLogger().logInfo("Trying to invoke bad method")
    hw.badMethod()
    
except ACSErrTypeCommon.UnknownEx as e:
    simpleClient.getLogger().logCritical("Caught an ACSException...don't worry because this SHOULD happen.")
    helperException = ACSErrTypeCommonImpl.UnknownExImpl(exception=e)
    helperException.Print()
    helperException.log(simpleClient.getLogger())
    # Release it
    simpleClient.releaseComponent("HELLOWORLD1")

except Exception as e:
    simpleClient.getLogger().logAlert("Caught the wrong type of exception!!!")
    simpleClient.getLogger().logDebug("The exception was:" + str(e))

simpleClient.disconnect()
print("The end __oOo__")











