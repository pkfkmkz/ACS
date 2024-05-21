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
* "@(#) $Id: acsddsncCDBPropertiesImpl.cpp,v 1.5 2010/06/15 09:23:02 hsommer Exp $"
*
* who       when      what
* --------  --------  ----------------------------------------------
* cmaureir  2010-02-02  created 
*/

#include "acsddsncCDBProperties.h"
#include <maciHelper.h>
#include <acsutilPorts.h>
#include <acsutil.h>
#include "dds/DCPS/QOS_XML_Handler/XML_File_Intf.h"
#include <loggingMACROS.h>

static const char *rcsId="@(#) $Id: acsddsncCDBPropertiesImpl.cpp,v 1.5 2010/06/15 09:23:02 hsommer Exp $"; 
static void *use_rcsId = ((void)&use_rcsId,(void *) &rcsId);

namespace ddsnc {


CDBProperties::CDBProperties() : OpenDDS::DCPS::QOS_XML_MemBuf_Handler()
  {

  }

  CDBProperties::~CDBProperties()
  {

  }
  //------------------------------------------------------
  CDB::DAL_ptr
    CDBProperties::getCDB()
    {
      ACE_CString nameService;
      ACE_CString managerName;

      managerName = maci::MACIHelper::getManagerHostname(1,NULL);
      //get NameService Reference
      nameService += acscommon::NAMING_SERVICE_NAME;
      nameService +="=corbaloc::";
      nameService += managerName;
      nameService += ":";
      nameService += ACSPorts::getNamingServicePort().c_str();
      nameService += "/";
      nameService += acscommon::NAMING_SERVICE_NAME;

      // ORB
      int argc = 5;
      const char* orbArgs[] = { "",
        "-ORBInitRef",
        nameService.c_str(),
        "-ORBDottedDecimalAddresses",
        "1"};

      CORBA::ORB_var m_orb;
      m_orb = CORBA::ORB_init(argc, const_cast<char**>(orbArgs), "");

      ACE_CString cdbLoc;
      cdbLoc += "corbaloc::";
      cdbLoc += managerName;
      cdbLoc += ":";
      cdbLoc += ACSPorts::getCDBPort().c_str();
      cdbLoc += "/CDB";

      CDB::DAL_var dalObj = CDB::DAL::_nil();
      CORBA::Object_var obj = m_orb->string_to_object(cdbLoc.rep());

      if (!CORBA::is_nil(obj.in()))
      {
        dalObj = CDB::DAL::_narrow(obj.in());
        if (CORBA::is_nil(dalObj.in())) 
        {
          ACS_STATIC_LOG(LM_FULL_INFO, " CDBProperties::getCDB", (LM_ERROR,
                "Failed to narrow CDB."));
        }
      }

      return dalObj._retn();

    }

  void CDBProperties::parseConfig(CORBA::String_var channelName)
  {

    //Complete name of the channel within the CDB
    std::string tmpChannelName(channelName);
    std::string cdbChannelName = "MACI/Channels/" + tmpChannelName;

    std::stringstream msg;
    msg << "Accessing configuration from channel name: "
        << cdbChannelName;
    STATIC_LOG_TO_DEVELOPER( LM_DEBUG, (msg.str()));

    CDB::DAL_var cdbRef = getCDB();
    if (CORBA::is_nil(cdbRef.in()))
    {
      STATIC_LOG_TO_DEVELOPER( LM_INFO, "Cannot access CDB. It will use default qos");
      return;
    }
    try {
        std::string xmlNode;
        xmlNode += cdbRef->get_DAO(cdbChannelName.c_str());
    
        // Add default paths to search XML schemas
        add_search_path("DDS_ROOT","/docs/schema/");
        add_search_path("PWD","/../config/CDB/schemas/");
        add_search_path("ACSROOT","/config/CDB/schemas/");
        add_search_path("INTROOT","/config/CDB/schemas/");
    
        // Parse the XML content from channel
        STATIC_LOG_TO_DEVELOPER( LM_INFO, ("Parsing qos configuration from CDB"));
        DDS::ReturnCode_t retcode;
        retcode = init(ACE_TEXT_CHAR_TO_TCHAR(xmlNode.c_str()));
        if ( retcode != DDS::RETCODE_OK)
        {
            STATIC_LOG_TO_DEVELOPER( LM_INFO, ("Error Parsing configuration"));
        }
      }
      catch (cdbErrType::CDBXMLErrorEx &ex) 
      {
            STATIC_LOG_TO_DEVELOPER( LM_INFO, ("Error Parsing configuration"));
      }
  }

}
