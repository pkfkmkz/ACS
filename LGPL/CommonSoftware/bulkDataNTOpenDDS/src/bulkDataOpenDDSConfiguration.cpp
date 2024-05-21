/**************************************************************************************************************************
* ALMA - Atacama Large Millimiter Array
* (c) European Southern Observatory, 2011
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
* "@(#) $Id: bulkDataNTConfiguration.cpp,v 1.31 2013/01/08 11:13:00 bjeram Exp $"
*
* who       when      what
* --------  --------  ----------------------------------------------
* bjeram  2011-04-19  created
*/

#include "bulkDataOpenDDSConfiguration.h"
//#include <ndds_config_cpp.h>
#include <dds/DCPS/transport/framework/TransportDebug.h>
#include <dds/DCPS/debug.h>
//#include "ace/XML_Utils/XMLSchema/Types.hpp"
#include <dds/DCPS/Service_Participant.h>
#include <logging.h>
#include <dds/DCPS/QOS_XML_Handler/XML_File_Intf.h>

using namespace AcsBulkdata;

const char* const DDSConfiguration::DEFAULT_LIBRARY = "BulkDataQoSLibrary";
const char* const DDSConfiguration::DEFAULT_SENDER_STREAM_PROFILE = "SenderStreamDefaultQosProfile";
const char* const DDSConfiguration::DEFAULT_SENDER_FLOW_PROFILE= "SenderFlowDefaultQosProfile";
const char* const DDSConfiguration::DEFAULT_RECEIVER_STREAM_PROFILE = "ReceiverStreamDefaultQosProfile";
const char* const DDSConfiguration::DEFAULT_RECEIVER_FLOW_PROFILE = "ReceiverFlowDefaultQosProfile";
const char* const DDSConfiguration::DEFAULT_API_CREATE_PROFILE = "APICreateProfile";
short DDSConfiguration::debugLevel = -1;
unsigned int DDSConfiguration::DDSLogVerbosity = (unsigned int)(1); //NDDS_CONFIG_LOG_VERBOSITY_WARNING);
unsigned int DDSConfiguration::DDSTransportLogVerbosity = (unsigned int)(0); 

bool StreamConfiguration::DEFAULT_PARTICIPANT_PER_STREAM=false;

double SenderFlowConfiguration::DEFAULT_SENDFRAME_TIMEOUT=5.0;  //secs
double SenderFlowConfiguration::DEFAULT_ACKs_TIMEOUT=2.0; //secs
double SenderFlowConfiguration::DEFAULT_THROTTLING=0; // no throttling

unsigned short ReceiverStreamConfiguration::DEFAULT_BASE_UNICAST_PORT=48000;
bool ReceiverStreamConfiguration::DEFAULT_USE_INCREMENT_UNICAST_PORT=true;

const char* const ReceiverFlowConfiguration::DEFAULT_MULTICAST_ADDRESS="225.3.2.1";
double ReceiverFlowConfiguration::DEFAULT_CBRECEIVE_PROCESS_TIMEOUT=0.01; //sec => 6.4 MB/sec
double ReceiverFlowConfiguration::DEFAULT_CBRECEIVE_AVG_PROCESS_TIMEOUT=0.005; //sec => ~ 12MB/sec
bool ReceiverFlowConfiguration::DEFAULT_ENABLE_MULTICAST=true;
unsigned short ReceiverFlowConfiguration::DEFAULT_UNICAST_PORT=0; ///0 means that DDS will choose the port

bool DDSConfiguration::ignoreUserProfileQoS = true;
bool DDSConfiguration::ignoreEnvironmentProfileQoS = true;

std::string DDSConfiguration::urlProfileQoS="";
//const char* const DDSConfiguration::DEFAULT_QoS_FILE="/config/bulkDataNTDefaultQosProfiles.";//xml";
const char* const DDSConfiguration::DEFAULT_QoS_FILE="/config/bulkDataNTDefaultOpenDDSQoSProfiles";//xml";
std::string DDSConfiguration::urlINIConfig="";
const char* const DDSConfiguration::DEFAULT_INI_FILE="/config/bulkDataNTDefaultOpenDDSConfig";//ini";

OpenDDS::DCPS::QOS_XML_Handler DDSConfiguration::profileList;

bool AcsBulkdata::isBulkDataNTEnabled()
{
	const char *enableBulkDataNT = getenv("ENABLE_BULKDATA_NT");

	return ( enableBulkDataNT != 0 &&
			(strcmp(enableBulkDataNT, "1")==0 ||
			 strcasecmp(enableBulkDataNT, "true")==0 ||
			 strcasecmp(enableBulkDataNT, "y")==0
			)
		);
}
/**************************************************************************************
 * 			StreamConfiguration
 **************************************************************************************/
DDSConfiguration::DDSConfiguration()
{
	libraryQos=DDSConfiguration::DEFAULT_LIBRARY;
	DDSConfiguration::setDebugLevelFromEnvVar();
	char *envVar=0;

  envVar = getenv("LOCATION");

  if (urlINIConfig.empty())
  {
    if(envVar != 0)
      fillUrlINIConfig(envVar);
    else
      fillUrlINIConfig("default");
  }

	if (urlProfileQoS.empty())
	{
		//urlProfileQoS = "[";
		if (envVar != NULL)
		{
			fillUrlProfileQoS(envVar); //if we have a LOCATION it has to be append to the QoS file name
		}
		// if we have not filled the urlProfileQoS yet (we have just '[')
		if (urlProfileQoS.empty()) fillUrlProfileQoS("default"); // QoS file name w/o suffix
		//urlProfileQoS+="]";

	  if (access(urlProfileQoS.c_str(), R_OK) == 0) 
	  {
	  	ACS_SHORT_LOG((LM_INFO, "Going to use: %s default QoS profile.", urlProfileQoS.c_str()));
      OpenDDS::DCPS::QOS_XML_File_Handler xmlFile;

      xmlFile.add_search_path(ACE_TEXT("MODROOT"), ACE_TEXT("/config/CDB/schemas/"));
      //profileList.add_search_path(ACE_TEXT("DDS_ROOT"), ACE_TEXT("/docs/schema/"));
      xmlFile.add_search_path(ACE_TEXT("ACSROOT"), ACE_TEXT("/config/CDB/schemas/"));
      xmlFile.add_search_path(ACE_TEXT("INTROOT"), ACE_TEXT("/config/CDB/schemas/"));

      DDS::ReturnCode_t retcode = xmlFile.init(ACE_TEXT_CHAR_TO_TCHAR(urlProfileQoS.c_str()));
      if (retcode != DDS::RETCODE_OK)
      {
      		ACS_SHORT_LOG((LM_INFO, "Cannot parse OpenDDS QoS Xml file %s.",urlProfileQoS.c_str()));
      }
      else
      {
        profileList.addQoSProfileSeq(xmlFile.get());
      }
    }
	  else
	  {
	  	ACS_SHORT_LOG((LM_WARNING, "Default QoS profile file has NOT be found!!"));
	  }

	  // here we are sure that this is executed just once
	  envVar = getenv("NDDS_DISCOVERY_PEERS");
	  if (envVar && *envVar)
	  {
	  	ACS_SHORT_LOG((LM_WARNING, "Env. variable NDDS_DISCOVERY_PEERS has been set to: %s, what could cause a problem to connect sender and receivers if it is not proprly used.", envVar));
    }//if
	}//if
}//DDSConfiguration

void DDSConfiguration::fillUrlProfileQoS(const char*suffix)
{
	char *envVarValue = getenv("MODPATH");
	if (envVarValue != NULL)
	{
		if ( findProfileQoS("..", suffix) ) return;
	}

	if ( findProfileQoS(getenv("MODROOT"), suffix) ) return;
	if ( findProfileQoS(getenv("INTROOT"), suffix) ) return;

	envVarValue = getenv("INTLIST");
	if (envVarValue != NULL) {
		char* save;
		char *tmpEnvVarValue = strdup(envVarValue); // we have to make copy otherwise next time the INTLIST is corrupted
		char* tok = strtok_r(tmpEnvVarValue, ":", &save);
		while (tok != NULL)
		{
			if ( findProfileQoS(tok, suffix) ) return;
			tok = strtok_r(NULL, ":", &save);
		}//while
		free(tmpEnvVarValue);
	}//if

	findProfileQoS(getenv("ACSROOT"), suffix);
}//fillUrlProfileQoS

void DDSConfiguration::fillUrlINIConfig(const char*suffix)
{
	char *envVarValue = getenv("MODPATH");
	if (envVarValue != NULL)
	{
    urlINIConfig.append("..");
    urlINIConfig.append(DEFAULT_INI_FILE);
    urlINIConfig.append(".");
    urlINIConfig.append(suffix);
    urlINIConfig.append(".ini");
    if (access(urlINIConfig.c_str(), R_OK) == 0)
      return;
	}

  if (getenv("MODROOT") != 0)
  {
    urlINIConfig.append(getenv("MODROOT"));
    urlINIConfig.append(DEFAULT_INI_FILE);
    urlINIConfig.append(".");
    urlINIConfig.append(suffix);
    urlINIConfig.append(".ini");
    if (access(urlINIConfig.c_str(), R_OK) == 0)
      return;
  }
  if (getenv("INTROOT") != 0)
  {
    urlINIConfig.append(getenv("INTROOT"));
    urlINIConfig.append(DEFAULT_INI_FILE);
    urlINIConfig.append(".");
    urlINIConfig.append(suffix);
    urlINIConfig.append(".ini");
    if (access(urlINIConfig.c_str(), R_OK) == 0)
      return;
  }

	envVarValue = getenv("INTLIST");
	if (envVarValue != NULL) {
		char* save;
		char *tmpEnvVarValue = strdup(envVarValue); // we have to make copy otherwise next time the INTLIST is corrupted
		char* tok = strtok_r(tmpEnvVarValue, ":", &save);
		while (tok != NULL)
		{
      urlINIConfig.clear();
      urlINIConfig.append(tok);
      urlINIConfig.append(DEFAULT_INI_FILE);
      urlINIConfig.append(".");
      urlINIConfig.append(suffix);
      urlINIConfig.append(".ini");
      if (access(urlINIConfig.c_str(), R_OK) == 0)
        return;

			tok = strtok_r(NULL, ":", &save);
		}//while
		free(tmpEnvVarValue);
	}//if

  if (getenv("ACSROOT") != 0)
  {
    urlINIConfig.append(getenv("ACSROOT"));
    urlINIConfig.append(DEFAULT_INI_FILE);
      urlINIConfig.append(".");
      urlINIConfig.append(suffix);
      urlINIConfig.append(".ini");
    if (access(urlINIConfig.c_str(), R_OK) == 0)
      return;
  }
}//fillUrlINIConfig

bool DDSConfiguration::findProfileQoS(const char* path, const char*suffix)
{
	std::string fullPath;

		if (path != NULL)
		{
			fullPath += path;
			fullPath += DEFAULT_QoS_FILE;
      fullPath += ".";
			if ( suffix!=NULL ) { fullPath+= suffix; fullPath+=".";}
			fullPath += "xml";

			if (!access(fullPath.c_str(), R_OK))
			{
			//	urlProfileQoS += "file://";
				urlProfileQoS += fullPath;
				return true;
			}
		}
		return false;
}//findProfileQoS

void DDSConfiguration::setDebugLevelFromEnvVar()
{
	if (debugLevel<0) //we read and set debug level jsut once
	{
		char *bulkDataNtDebug = getenv("BULKDATA_NT_DEBUG");
		if (bulkDataNtDebug && *bulkDataNtDebug)
		{
			debugLevel = atoi(bulkDataNtDebug);
			DDSConfiguration::setDDSLogVerbosity();
      DDSConfiguration::setDDSTransportLogVerbosity();
			ACS_SHORT_LOG((LM_INFO, "BulkDataNT debug level read from env. var. BULKDATA_NT_DEBUG and set to %d", debugLevel));
		}
		else
		{
			debugLevel=0;
		}
	}
}//setDebugLevelFromEnvVar

void DDSConfiguration::setDDSLogVerbosity()
{
  if (DDSConfiguration::debugLevel > 0)
  {
    if (DDSConfiguration::debugLevel < 10)
      DDSLogVerbosity = DDSConfiguration::debugLevel;
    else
      DDSLogVerbosity = 10; // Maximum log level 
  }
  else
    DDSLogVerbosity = 0;  // Minimum log level

  OpenDDS::DCPS::set_DCPS_debug_level(DDSLogVerbosity);

}//setDDSLogVerbosity

void DDSConfiguration::setDDSTransportLogVerbosity()
{
  if (DDSConfiguration::debugLevel > 0)
  {
    if (DDSConfiguration::debugLevel < 5)
      DDSTransportLogVerbosity = DDSConfiguration::debugLevel;
    else
      DDSTransportLogVerbosity = 5; // Maximum transport log level 
  }
  else
    DDSTransportLogVerbosity = 0;  // Minimum transport log level

  OpenDDS::DCPS::Transport_debug_level = DDSTransportLogVerbosity;

}//setDDSTransportLogVerbosity


void DDSConfiguration::setStringProfileQoS(char *cfg, const char *defaultProfile)
{
	profileQos=DEFAULT_API_CREATE_PROFILE;

	stringProfileQoS="<qos_profile name=\"";
	stringProfileQoS+=profileQos;
	stringProfileQoS+="\" base_name=\"";
	stringProfileQoS+=DDSConfiguration::DEFAULT_LIBRARY;
	stringProfileQoS+="::";
	stringProfileQoS+=defaultProfile;
	stringProfileQoS+="\">";
	stringProfileQoS+=cfg;
	stringProfileQoS+="</qos_profile>";
}//setStringProfileQoS

void DDSConfiguration::setStringProfileQoS(char*  profileName, char* cfg, const char *defaultProfile)
{
	profileQos=profileName;
	stringProfileQoS="<qos_profile name=\"";
	stringProfileQoS+=profileQos;
	stringProfileQoS+="\" base_name=\"";
	stringProfileQoS+=DDSConfiguration::DEFAULT_LIBRARY;
	stringProfileQoS+="::";
	stringProfileQoS+=defaultProfile;
	stringProfileQoS+="\">";
	stringProfileQoS+=cfg;
	stringProfileQoS+="</qos_profile>";
}//setStringProfileQoS

/**************************************************************************************
 * 			StreamConfiguration
 **************************************************************************************/
StreamConfiguration::StreamConfiguration()
{

	participantPerStream = DEFAULT_PARTICIPANT_PER_STREAM;
}//StreamConfiguration


/**************************************************************************************
 * 			SenderStreamConfiguration
 **************************************************************************************/
SenderStreamConfiguration::SenderStreamConfiguration()
{
	profileQos=DEFAULT_SENDER_STREAM_PROFILE;
}//StreamConfiguration

/**************************************************************************************
 * 			ReceiverStreamConfiguration
 **************************************************************************************/
ReceiverStreamConfiguration::ReceiverStreamConfiguration()
{
	profileQos=DEFAULT_RECEIVER_STREAM_PROFILE;
	useIncrementUnicastPort = DEFAULT_USE_INCREMENT_UNICAST_PORT;
	baseUnicastPort = DEFAULT_BASE_UNICAST_PORT;
}//ReceiverStreamConfiguration

void ReceiverStreamConfiguration::setDDSReceiverStreamQoS(char *cfg)
{
	setStringProfileQoS(cfg, DDSConfiguration::DEFAULT_RECEIVER_STREAM_PROFILE);
}//setDDSReceiverStreamQoS

void ReceiverStreamConfiguration::setDDSReceiverStreamQoS(char *profileName, char* cfg)
{
	setStringProfileQoS(profileName, cfg, DDSConfiguration::DEFAULT_RECEIVER_STREAM_PROFILE);
}//setDDSReceiverStreamQoS

/**************************************************************************************
 * 			ReceiverFlowConfiguration
 **************************************************************************************/
ReceiverFlowConfiguration::ReceiverFlowConfiguration()
{
	profileQos=DEFAULT_RECEIVER_FLOW_PROFILE;
	cbReceiveProcessTimeout =DEFAULT_CBRECEIVE_PROCESS_TIMEOUT;
	cbReceiveAvgProcessTimeout =DEFAULT_CBRECEIVE_AVG_PROCESS_TIMEOUT;
	enableMulticast = DEFAULT_ENABLE_MULTICAST;
	multicastAddress = DEFAULT_MULTICAST_ADDRESS;
	unicastPort = DEFAULT_UNICAST_PORT;
}//ReceiverFlowConfiguration


double ReceiverFlowConfiguration::getCbReceiveProcessTimeout() const
{
    return cbReceiveProcessTimeout;
}

void ReceiverFlowConfiguration::setCbReceiveProcessTimeout(double cbReceiveProcessTimeout)
{
    this->cbReceiveProcessTimeout = cbReceiveProcessTimeout;
}


double ReceiverFlowConfiguration::getCbReceiveAvgProcessTimeout() const
{
    return cbReceiveAvgProcessTimeout;
}

void ReceiverFlowConfiguration::setCbReceiveAvgProcessTimeout(double cbReceiveAvgProcessTimeout)
{
    this->cbReceiveAvgProcessTimeout = cbReceiveAvgProcessTimeout;
}

std::string ReceiverFlowConfiguration::getMulticastAddress() const
{
    return multicastAddress;
}

bool ReceiverFlowConfiguration::isEnableMulticast() const
{
    return enableMulticast;
}

void ReceiverFlowConfiguration::setEnableMulticast(bool enableMulticast)
{
    this->enableMulticast = enableMulticast;
}

void ReceiverFlowConfiguration::setMulticastAddress(std::string multicastAddress)
{
    this->multicastAddress = multicastAddress;
}

unsigned short ReceiverFlowConfiguration::getUnicastPort() const
{
	return this->unicastPort;
}

void ReceiverFlowConfiguration::setUnicastPort(	unsigned short port)
{
	this->unicastPort = port;
}

void ReceiverFlowConfiguration::setDDSReceiverFlowQoS(char* cfg)
{
	setStringProfileQoS(cfg, DDSConfiguration::DEFAULT_RECEIVER_FLOW_PROFILE);
}//setDDSReceiverFlowQoS

void ReceiverFlowConfiguration::setDDSReceiverFlowQoS(char* profileName, char* cfg)
{
	setStringProfileQoS(profileName, cfg, DDSConfiguration::DEFAULT_RECEIVER_FLOW_PROFILE);
}//setDDSReceiverFlowQoS

/**************************************************************************************
 * 			SenderFlowConfiguration
 **************************************************************************************/
SenderFlowConfiguration::SenderFlowConfiguration()
{
	profileQos=DEFAULT_SENDER_FLOW_PROFILE;
	sendFrameTimeout = DEFAULT_SENDFRAME_TIMEOUT;
	ACKsTimeout = DEFAULT_ACKs_TIMEOUT;
	throttling = DEFAULT_THROTTLING;
}

double SenderFlowConfiguration::getACKsTimeout() const
{
    return ACKsTimeout;
}

double SenderFlowConfiguration::getSendFrameTimeout() const
{
    return sendFrameTimeout;
}

void SenderFlowConfiguration::setACKsTimeout(double acKsTimeout)
{
    ACKsTimeout = acKsTimeout;
}

void SenderFlowConfiguration::setSendFrameTimeout(double frameTimeout)
{
    this->sendFrameTimeout = frameTimeout;
}

double SenderFlowConfiguration::getThrottling() const
{
	return throttling;
}

void SenderFlowConfiguration::setThrottling(double throttling)
{
	this->throttling = throttling;
}

void SenderFlowConfiguration::setDDSSenderFlowQoS(char* cfg)
{
	setStringProfileQoS(cfg, DDSConfiguration::DEFAULT_SENDER_FLOW_PROFILE);
}//setDDSReceiverFlowQoS

void SenderFlowConfiguration::setDDSSenderFlowQoS(char* profileName, char* cfg)
{
	setStringProfileQoS(profileName, cfg, DDSConfiguration::DEFAULT_SENDER_FLOW_PROFILE);
}







