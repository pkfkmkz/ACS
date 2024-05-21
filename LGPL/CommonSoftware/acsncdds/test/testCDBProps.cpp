/*******************************************************************************
* ALMA - Atacama Large Millimiter Array
* (c) UNSPECIFIED - FILL IN, 2005 
* 
* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
* 
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
* 
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*
* "@(#) $Id: testCDBProps.cpp,v 1.2 2010/02/26 18:13:38 utfsm Exp $"
*
* who       when      what
* --------  --------  ----------------------------------------------
* dfugate  2005-04-25  created
*/

#include <baci.h>
#include <acscomponentImpl.h>
#include "testCDBProps.h"
#include "acsddsncCDBProperties.h"

using namespace baci;

CDBPropsCompImpl::CDBPropsCompImpl(const ACE_CString &name, 
			maci::ContainerServices *containerServices) : 
		ACSComponentImpl(name, containerServices)
{
	ACS_TRACE("::CDBPropsCompImpl::CDBPropsCompImpl");
}
CORBA::Long
CDBPropsCompImpl::runTest()
{
	ACS_STATIC_SHORT_LOG((LM_INFO,
 				  "CDBPropsCompImpl::runTest",
                                  "Starting the tests"));


	CORBA::String_var ddsChannelName;
	ddsChannelName = CORBA::string_dup("DDSEvent");
	ddsnc::CDBProperties cdbProps;


	cdbProps.parseConfig(ddsChannelName);

  DDS::DataReaderQos drQos;

  if (cdbProps.get_datareader_qos(drQos,"profileTest","topicTest") == DDS::RETCODE_OK)
  {
    if( drQos.durability.kind == DDS::VOLATILE_DURABILITY_QOS)
      std::cout << "durability.kind =" << "VOLATILE_DURABILITY_QOS" << std::endl;

  }



}

CDBPropsCompImpl::~CDBPropsCompImpl()
{

}

/* --------------- [ MACI DLL support functions ] -----------------*/
#include <maciACSComponentDefines.h>
MACI_DLL_SUPPORT_FUNCTIONS(CDBPropsCompImpl)
/* ----------------------------------------------------------------*/
