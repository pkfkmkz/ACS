#! /usr/bin/env python
#*******************************************************************************
# ALMA - Atacama Large Millimiter Array
# (c) National Research Council of Canada, 2008 
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
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
# "@(#) $Id: acspyTestUnitCDBAccess.py,v 1.1.1.1 2012/03/07 17:40:45 acaproni Exp $"
#
# who       when      what
# --------  --------  ----------------------------------------------
# arne  2008-03-26  created
#

#------------------------------------------------------------------------------
__revision__ = "$Id: acspyTestUnitCDBAccess.py,v 1.1.1.1 2012/03/07 17:40:45 acaproni Exp $"
#--REGULAR IMPORTS-------------------------------------------------------------
import unittest
import mock
import xml.sax
import CDB

fakeFunc = { 'get_DAO': '<Container xmlns="urn:schemas-cosylab-com:Container:1.0" xmlns:cdb="urn:schemas-cosylab-com:CDB:1.0" xmlns:baci="urn:schemas-cosylab-com:BACI:1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:log="urn:schemas-cosylab-com:LoggingConfig:1.0" Timeout="20.0" UseIFR="1" ManagerRetry="10" ImplLang="py"> <Autoload> <cdb:e string="acspyTestAutoload" /> </Autoload> <LoggingConfig centralizedLogger="Log" minLogLevel="2" dispatchPacketSize="0" immediateDispatchLevel="99"> </LoggingConfig> </Container>' }

mockCDB = mock.Mock(spec=CDB._objref_DAL)
def mockcdb():
    return mockCDB

import Acspy.Util.ACSCorba
Acspy.Util.ACSCorba.cdb = mockcdb

#--ACS IMPORTS____-------------------------------------------------------------
import Acspy.Common.CDBAccess

class CDBHandlerCheck(unittest.TestCase):
    """Test of the CDBhandler class."""

    def setUp(self):
        pass
    
    def tearDown(self):
        pass

    def testConstructor(self):
        """Handler initialized"""
        h = Acspy.Common.CDBAccess.CDBhandler('target')
        self.assertEqual('target', h.element_name)
        self.assertEqual('', h.tempName)
        self.assertEqual(0, len(h.return_values))
        
    def testPlainElementNoAttr(self):
        """Handler element with no attributes"""
        h = Acspy.Common.CDBAccess.CDBhandler('target')
        xml.sax.parseString("<target>Text</target>", h)
        self.assertEqual('target', h.element_name)
        self.assertEqual('', h.tempName)
        self.assertEqual(1, len(h.return_values))
        self.assertEqual({}, h.return_values[0])

    def testPlainElementAttr(self):
        """Handler element with attributes"""
        h = Acspy.Common.CDBAccess.CDBhandler('target')
        xml.sax.parseString("<target attr1='label' attr2='9.0'>Text</target>", h)
        self.assertEqual('target', h.element_name)
        self.assertEqual('', h.tempName)
        self.assertEqual(1, len(h.return_values))
        self.assertEqual(2, len(h.return_values[0]))
        self.assertEqual({'attr1': 'label', 'attr2': '9.0'}, h.return_values[0])

    def testNestedElementNoAttr(self):
        """Handler nested element with no attributes"""
        h = Acspy.Common.CDBAccess.CDBhandler('parent/target')
        xml.sax.parseString("<parent><target>Text</target></parent>", h)
        self.assertEqual('parent/target', h.element_name)
        self.assertEqual('', h.tempName)
        self.assertEqual(1, len(h.return_values))
        self.assertEqual({}, h.return_values[0])
        
    def testNestedElementAttr(self):
        """Handler nested element with attributes"""
        h = Acspy.Common.CDBAccess.CDBhandler('parent/target')
        xml.sax.parseString("<parent><target attr1='label' attr2='9.0'>Text</target></parent>", h)
        self.assertEqual('parent/target', h.element_name)
        self.assertEqual('', h.tempName)
        self.assertEqual(1, len(h.return_values))
        self.assertEqual(2, len(h.return_values[0]))
        self.assertEqual({'attr1': 'label', 'attr2': '9.0'}, h.return_values[0])

    def testNestedWrongElementNoAttr(self):
        """Handler nested different element with no attributes"""
        h = Acspy.Common.CDBAccess.CDBhandler('parent/target')
        xml.sax.parseString("<parent><target2>Text</target2></parent>", h)
        self.assertEqual('parent/target', h.element_name)
        self.assertEqual('', h.tempName)
        self.assertEqual(0, len(h.return_values))
        
    def testNestedWrongKeyNoAttr(self):
        """Handler nested different element with no attributes"""
        h = Acspy.Common.CDBAccess.CDBhandler('parent/target2')
        xml.sax.parseString("<parent><target>Text</target></parent>", h)
        self.assertEqual('parent/target2', h.element_name)
        self.assertEqual('', h.tempName)
        self.assertEqual(0, len(h.return_values))


class CDBAccessCheck(unittest.TestCase):
    """Test of the CDBaccess class."""

    def setUp(self):
        self.a = Acspy.Common.CDBAccess.CDBaccess()
    
    def tearDown(self):
        pass

    def testConstructor(self):
        """Access initialized"""
        self.assertEqual(0, len(self.a.cache))
        self.assertEqual(mockCDB.__module__, self.a.m_dal.__module__)

    def testGetField(self):
        """Access retrieve CDB String"""
        global mockCDB
        mockCDB.get_DAO.return_value = '<Container xmlns="urn:schemas-cosylab-com:Container:1.0" xmlns:cdb="urn:schemas-cosylab-com:CDB:1.0" xmlns:baci="urn:schemas-cosylab-com:BACI:1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:log="urn:schemas-cosylab-com:LoggingConfig:1.0" Timeout="20.0" UseIFR="1" ManagerRetry="10" ImplLang="py"> <Autoload> <cdb:e string="acspyTestAutoload" /> </Autoload> <LoggingConfig centralizedLogger="Log" minLogLevel="2" dispatchPacketSize="0" immediateDispatchLevel="99"> </LoggingConfig> </Container>' 
        str = self.a.getField('MACI/Container')
        self.assertEqual(fakeFunc['get_DAO'], str)
        self.assertEqual(1, len(self.a.cache))
        self.assertEqual(True, 'MACI/Container' in self.a.cache)
        self.assertEqual(fakeFunc['get_DAO'], self.a.cache['MACI/Container'])
        mockCDB.get_DAO.return_value = mockCDB
        
    def testGetFieldCache(self):
        """Access retrieve CDB String from cache"""
        str = self.a.getField('MACI/Container')
        baseline = mockCDB.method_calls
        str2 = self.a.getField('MACI/Container')
        self.assertEqual(str, str2)
        self.assertEqual(baseline, mockCDB.method_calls)

    def testGetTopElement(self):
        """Access retrieve attributes from top level element"""
        global mockCDB
        mockCDB.get_DAO.return_value = '<Container xmlns="urn:schemas-cosylab-com:Container:1.0" xmlns:cdb="urn:schemas-cosylab-com:CDB:1.0" xmlns:baci="urn:schemas-cosylab-com:BACI:1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:log="urn:schemas-cosylab-com:LoggingConfig:1.0" Timeout="20.0" UseIFR="1" ManagerRetry="10" ImplLang="py"> <Autoload> <cdb:e string="acspyTestAutoload" /> </Autoload> <LoggingConfig centralizedLogger="Log" minLogLevel="2" dispatchPacketSize="0" immediateDispatchLevel="99"> </LoggingConfig> </Container>' 
        attribs = self.a.getElement('MACI/Container', 'Container')
        self.assertEqual(1, len(attribs))
        self.assertEqual(9, len(attribs[0]))
        self.assertEqual(['xmlns','xmlns:baci','ManagerRetry','xmlns:cdb','Timeout','xmlns:log','xmlns:xsi','UseIFR','ImplLang'], list(attribs[0].keys()))
        mockCDB.get_DAO.return_value = mockCDB
        
    def testGetNestedElement(self):
        """Access retrieve attributes from lower level element that has no attributes"""
        global mockCDB
        mockCDB.get_DAO.return_value = '<Container xmlns="urn:schemas-cosylab-com:Container:1.0" xmlns:cdb="urn:schemas-cosylab-com:CDB:1.0" xmlns:baci="urn:schemas-cosylab-com:BACI:1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:log="urn:schemas-cosylab-com:LoggingConfig:1.0" Timeout="20.0" UseIFR="1" ManagerRetry="10" ImplLang="py"> <Autoload> <cdb:e string="acspyTestAutoload" /> </Autoload> <LoggingConfig centralizedLogger="Log" minLogLevel="2" dispatchPacketSize="0" immediateDispatchLevel="99"> </LoggingConfig> </Container>' 
        attribs = self.a.getElement('MACI/Container', 'Container/Autoload')
        self.assertEqual(1, len(attribs))
        self.assertEqual(0, len(attribs[0]))
        mockCDB.get_DAO.return_value = mockCDB
        
    def testGetNestedElementAttr(self):
        """Access retrieve attributes from lower level element that has attributes"""
        global mockCDB
        mockCDB.get_DAO.return_value = '<Container xmlns="urn:schemas-cosylab-com:Container:1.0" xmlns:cdb="urn:schemas-cosylab-com:CDB:1.0" xmlns:baci="urn:schemas-cosylab-com:BACI:1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:log="urn:schemas-cosylab-com:LoggingConfig:1.0" Timeout="20.0" UseIFR="1" ManagerRetry="10" ImplLang="py"> <Autoload> <cdb:e string="acspyTestAutoload" /> </Autoload> <LoggingConfig centralizedLogger="Log" minLogLevel="2" dispatchPacketSize="0" immediateDispatchLevel="99"> </LoggingConfig> </Container>' 
        attribs = self.a.getElement('MACI/Container', 'Container/LoggingConfig')
        self.assertEqual(1, len(attribs))
        self.assertEqual(4, len(attribs[0]))
        self.assertEqual(['minLogLevel','dispatchPacketSize','centralizedLogger','immediateDispatchLevel'], list(attribs[0].keys()))
        mockCDB.get_DAO.return_value = mockCDB
        

def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(CDBHandlerCheck))
    suite.addTest(unittest.makeSuite(CDBAccessCheck))
    return suite

if __name__ == "__main__":
    unittest.main(defaultTest='suite')

#
# ___oOo___
