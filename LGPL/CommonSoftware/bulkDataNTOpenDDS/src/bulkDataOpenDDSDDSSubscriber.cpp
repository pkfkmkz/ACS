/*******************************************************************************
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
*/

#include "bulkDataOpenDDSDDSSubscriber.h"
#include <iostream>
#include <dds/DCPS/transport/framework/TransportRegistry.h>
#include <dds/DCPS/transport/framework/TransportConfig.h>
#include <dds/DCPS/transport/framework/TransportInst.h>
#include <dds/DCPS/transport/tcp/TcpInst.h>
#include <dds/DCPS/transport/multicast/MulticastInst.h>
#include <dds/DCPS/transport/multicast/MulticastInst_rch.h>

using namespace AcsBulkdata;
using namespace std;
using namespace ACSErrTypeCommon;
using namespace ACS_DDS_Errors;

BulkDataNTDDSSubscriber::BulkDataNTDDSSubscriber(DDS::DomainParticipant *p, const ReceiverFlowConfiguration &cfg) :
		BulkDataNTDDS(p, cfg)
{
	subscriber_m = createDDSSubscriber();
	enableMulticast_m = cfg.isEnableMulticast();
	if (enableMulticast_m)
		multicastAddress_m = cfg.getMulticastAddress();
	else
		unicastPort_m = cfg.getUnicastPort();
}//BulkDataNTDDSSubscriber

BulkDataNTDDSSubscriber::~BulkDataNTDDSSubscriber()
{
	try
	{
		destroyDDSSubscriber();
	}
	catch(ACSErr::ACSbaseExImpl &ex)
	{
		ex.log();
	}
}//~BulkDataNTDDSSubscriber

DDS::Subscriber* BulkDataNTDDSSubscriber::createDDSSubscriber()
{
	AUTO_TRACE(__PRETTY_FUNCTION__);
	DDS::ReturnCode_t ret;
	DDS::SubscriberQos sub_qos;

	if (participant_m==NULL)
	{
		printf("BulkDataNTDDSSubscriber::BulkDataNTDDSSubscriber participant NULL\n");
		return NULL;
	}

//	DDS::Subscriber *sub = participant_m->create_subscriber_with_profile(
//			ddsCfg_m.libraryQos.c_str(), ddsCfg_m.profileQos.c_str(),
//			0, DDS::STATUS_MASK_NONE);
 	
  // initialize with default OpenDDS qos profile
  participant_m->get_default_subscriber_qos(sub_qos);

  // Apply default bulkDataNT profile
  ddsCfg_m.profileList.get_subscriber_qos(sub_qos,
    ACE_TEXT_CHAR_TO_TCHAR(ddsCfg_m.DEFAULT_RECEIVER_FLOW_PROFILE));

  // Overlay with any qos profile stored
  if (!ddsCfg_m.stringProfileQoS.empty()){
    ddsCfg_m.profileList.get_subscriber_qos(sub_qos,
      ACE_TEXT_CHAR_TO_TCHAR(ddsCfg_m.profileQos.c_str()));
  }

  DDS::Subscriber_ptr sub = participant_m->create_subscriber(sub_qos,
                                                             0,
                                                             OpenDDS::DCPS::DEFAULT_STATUS_MASK);
	if(sub==0)
	{
		DDSSubscriberCreateProblemExImpl ex(__FILE__, __LINE__, __PRETTY_FUNCTION__);
		throw ex;
	}

	ret = sub->get_qos(sub_qos);
	if (ret!=DDS::RETCODE_OK)
	{
		DDSQoSGetProblemExImpl ex(__FILE__, __LINE__, __PRETTY_FUNCTION__);
		ex.setDDSTypeCode(ret);
		ex.setQoS("sub->get_qos()");
		throw ex;
	}//if

	/// dr has to be created disabled
	sub_qos.entity_factory.autoenable_created_entities=false;

	ret = sub->set_qos(sub_qos);
	if (ret!=DDS::RETCODE_OK)
	{
		DDSQoSSetProblemExImpl ex(__FILE__, __LINE__, __PRETTY_FUNCTION__);
		ex.setDDSTypeCode(ret);
		ex.setQoS("sub->set_qos()");
		throw ex;
	}//if

	ret = sub->enable();
	if (ret!=DDS::RETCODE_OK)
	{
		DDSSubscriberEnableProblemExImpl ex(__FILE__, __LINE__, __PRETTY_FUNCTION__);
		ex.setDDSTypeCode(ret);
	}

	return sub;
}//createDDSSubscriber

void BulkDataNTDDSSubscriber::destroyDDSSubscriber()
{
	AUTO_TRACE(__PRETTY_FUNCTION__);
	DDS::ReturnCode_t ret;
	ret = participant_m->delete_subscriber(subscriber_m);
	subscriber_m = 0;
	if (ret!=DDS::RETCODE_OK)
	{
		DDSSubscriberDestroyProblemExImpl ex(__FILE__, __LINE__, __PRETTY_FUNCTION__);
		ex.setDDSTypeCode(ret);
		throw ex;
	}//if
}//destroyDDSSubscriber

ACSBulkData::BulkDataNTFrameDataReader* BulkDataNTDDSSubscriber::createDDSReader(DDS::Topic *topic, DDS::DataReaderListener *listener)
{
	AUTO_TRACE(__PRETTY_FUNCTION__);
	DDS::ReturnCode_t ret;
	DDS::DataReaderQos dr_qos;
	//DDS::DataReader *temporary_dr, *dr;
  DDS::DataReader_ptr dr;

	if (subscriber_m==NULL || topic==NULL || listener==NULL)
	{
		NullPointerExImpl ex(__FILE__, __LINE__, __PRETTY_FUNCTION__);
		ex.setVariable("publisher_m, topic or listener");
		throw ex;
	}

	// !!! because we can (re)set multicast QoS after DR is created (even enabled), we have to use a bit dirty trick:
	// we create a temporary DR (temporary_dr) using QoS from profile, read the QoS from DR, set the multicast address
	// and create new DR
//	temporary_dr = subscriber_m->create_datareader_with_profile(topic,
//									ddsCfg_m.libraryQos.c_str(), ddsCfg_m.profileQos.c_str(),
//									listener,
//									DDS::STATUS_MASK_ALL);
//  if(temporary_dr==0)
//	{
//		NullPointerExImpl npex(__FILE__, __LINE__, __PRETTY_FUNCTION__);
//		npex.setVariable("temporary_dr");
//		DDSDRCreateProblemExImpl ex(npex, __FILE__, __LINE__, __PRETTY_FUNCTION__);
//		throw ex;
//	}//if
//
//	ret =temporary_dr->get_qos(dr_qos);
//	if (ret!=DDS::RETCODE_OK)
//	{
//		DDSQoSGetProblemExImpl ex(__FILE__, __LINE__, __PRETTY_FUNCTION__);
//		ex.setDDSTypeCode(ret);
//		ex.setQoS("temporary_dr->get_qos()");
//		throw ex;
//	}//if
//
//	if (enableMulticast_m)
//	{
//		dr_qos.multicast.value.ensure_length(1,1); // ? should we read the length and increase for one ?
//		dr_qos.multicast.value[0].receive_address = DDS_String_dup(multicastAddress_m.c_str());
//
//		if (multicastAddress_m.compare(ReceiverFlowConfiguration::DEFAULT_MULTICAST_ADDRESS))
//		{
//			ACS_LOG(LM_RUNTIME_CONTEXT, __FUNCTION__, (LM_DEBUG, "Stream#Flow: %s going to listen on multicast address: %s which is different from default: %s. Please make sure that the same multicast address is used for all receivers!",
//					topicName_m.c_str(), multicastAddress_m.c_str(), ReceiverFlowConfiguration::DEFAULT_MULTICAST_ADDRESS));
//		}
//		else
//		{
//			ACS_LOG(LM_RUNTIME_CONTEXT, __FUNCTION__, (LM_DEBUG, "Stream#Flow: %s going to listen on multicast address: %s.", topicName_m.c_str(), multicastAddress_m.c_str()));
//		}
//	}
//	else // unicast
//	{
//		if (unicastPort_m!=ReceiverFlowConfiguration::DEFAULT_UNICAST_PORT)
//		{
//			dr_qos.unicast.value.ensure_length(1,1);
//			dr_qos.unicast.value[0].receive_port = unicastPort_m;
//			ACS_LOG(LM_RUNTIME_CONTEXT, __FUNCTION__, (LM_DEBUG, "Stream#Flow: %s going to listen on unicast address, port: %d", topicName_m.c_str(), unicastPort_m));
//		}else
//		{
//			ACS_LOG(LM_RUNTIME_CONTEXT, __FUNCTION__, (LM_DEBUG, "Stream#Flow: %s going to listen on unicast address", topicName_m.c_str()));
//		}
//	}
//
//	// here we do not need the temporary DR
//	ret = subscriber_m->delete_datareader(temporary_dr);
//	if (ret!= DDS::RETCODE_OK)
//	{
//		DDSDRDestroyProblemExImpl ddex(__FILE__, __LINE__, __PRETTY_FUNCTION__);
//		ddex.setDDSTypeCode(ret);
//		DDSDRCreateProblemExImpl ex(ddex, __FILE__, __LINE__, __PRETTY_FUNCTION__);
//		throw ex;
//	}

//  temporary_dr = subscriber_m->create_datareader(topic,
//                                                 DATAREADER_QOS_DEFAULT,
//                                                 0,
//                                                 OpenDDS::DCPS::DEFAULT_STATUS_MASK);

    if(enableMulticast_m)
    {
        OpenDDS::DCPS::TransportConfig_rch cfg = 
            TheTransportRegistry->create_config("mcastconfig");
        OpenDDS::DCPS::TransportInst_rch inst = 
            TheTransportRegistry->create_inst("mymcast", // name 
                                              "multicast"); // type
        OpenDDS::DCPS::MulticastInst_rch mcast_inst = 
            OpenDDS::DCPS::dynamic_rchandle_cast<OpenDDS::DCPS::MulticastInst>(inst);
        mcast_inst->group_address_.set(multicastAddress_m.c_str());
        mcast_inst->rcv_buffer_size_ = 65535;
        cfg->instances_.push_back(inst);
        TheTransportRegistry->global_config(cfg);
        ACS_LOG(LM_RUNTIME_CONTEXT, __FUNCTION__, (LM_DEBUG, "Stream#Flow: %s going to listen on multicast address: %s.", topicName_m.c_str(), multicastAddress_m.c_str()));
    }

  // initialize with default OpenDDS qos profile
  subscriber_m->get_default_datareader_qos(dr_qos);

  // Apply default bulkDataNT profile
  ddsCfg_m.profileList.get_datareader_qos(dr_qos,
     ACE_TEXT_CHAR_TO_TCHAR(ddsCfg_m.DEFAULT_RECEIVER_FLOW_PROFILE),
     ACE_TEXT_CHAR_TO_TCHAR(topic->get_name()));

  // Overlay with any qos profile stored
  if (!ddsCfg_m.stringProfileQoS.empty()){
    ddsCfg_m.profileList.get_datareader_qos(dr_qos,
        ACE_TEXT_CHAR_TO_TCHAR(ddsCfg_m.profileQos.c_str()),
        ACE_TEXT_CHAR_TO_TCHAR( topic->get_name()));
  }

	dr = subscriber_m->create_datareader(topic, dr_qos, listener,OpenDDS::DCPS::DEFAULT_STATUS_MASK);
	if(dr==0)
	{
		NullPointerExImpl npex(__FILE__, __LINE__, __PRETTY_FUNCTION__);
		npex.setVariable("dr");
		DDSDRCreateProblemExImpl ex(npex, __FILE__, __LINE__, __PRETTY_FUNCTION__);
		throw ex;
	}//if);

	ret = dr->enable();
	if (ret!=DDS::RETCODE_OK)
	{
		DDSDREnableProblemExImpl ex(__FILE__, __LINE__, __PRETTY_FUNCTION__);
		ex.setDDSTypeCode(ret);
		throw ex;
	}

	return ACSBulkData::BulkDataNTFrameDataReader::_narrow(dr);
}


void BulkDataNTDDSSubscriber::destroyDDSReader(ACSBulkData::BulkDataNTFrameDataReader *dr)
{
	AUTO_TRACE(__PRETTY_FUNCTION__);
	DDS::ReturnCode_t ret;

	ret = subscriber_m->delete_datareader(dr);
	if (ret!=DDS::RETCODE_OK)
	{
		ACS_SHORT_LOG((LM_ERROR, "Problem deleting data reader (%d)", ret));
	}
}
