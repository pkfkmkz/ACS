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
*
*/

#include "bulkDataOpenDDSReceiverFlow.h"
#include <iostream>
#include "bulkDataOpenDDSReceiverStream.h"
#include <AV/FlowSpec_Entry.h>  // we need it for TAO_Tokenizer ??
#include <acsncSimpleConsumer.h>
#include <acsncS.h>
#include <maciContainerImpl.h>
#include <maciSimpleClient.h>
#include <acsncSimpleSupplier.h>
#include <bulkDataC.h>

using namespace AcsBulkdata;
using namespace std;


BulkDataNTReceiverFlow::BulkDataNTReceiverFlow(BulkDataNTReceiverStreamBase *receiverStream,
    const char* flowName,
    const ReceiverFlowConfiguration &rcvCfg,
    BulkDataNTCallback *cb,
    bool releaseCB,
    bool skipReceivingDataAfterFailure) :
    BulkDataNTFlow(flowName),
    receiverStream_m(receiverStream),
    callback_m(cb), releaseCB_m(releaseCB),
    rcvCfg_m(rcvCfg),
    errorStatusSupplier_p(nullptr)
{
  AUTO_TRACE(__PRETTY_FUNCTION__);
  std::string streamName, topicName;
  streamName = receiverStream_m->getName();
  topicName =  streamName + "#" + flowName_m;
  ACS_LOG(LM_RUNTIME_CONTEXT, __FUNCTION__, (LM_INFO, "Going to create Receiver Flow: %s @ Stream: %s ...", flowName_m.c_str(), streamName.c_str()));

  callback_m->setStreamName(receiverStream_m->getName().c_str());
  callback_m->setFlowName(flowName);
  callback_m->setReceiverName(receiverStream_m->getReceiverName());
  callback_m->setCBReceiveProcessTimeout(rcvCfg.getCbReceiveProcessTimeout());
  callback_m->setCBReceiveAvgProcessTimeout(rcvCfg.getCbReceiveAvgProcessTimeout());
  callback_m->setReceiverFlow(this);

  receiverStream->addDDSQoSProfile(rcvCfg_m, topicName.c_str());

  if (!rcvCfg_m.isEnableMulticast() &&  rcvCfg_m.getUnicastPort()==ReceiverFlowConfiguration::DEFAULT_UNICAST_PORT/*=0*/) //unicast && no unicast port was defined
  {
    rcvCfg_m.setUnicastPort(receiverStream_m->getNextFlowUnicastPort()); //re-set unicast port on local(!) copy
  }
  // should be refactor to have just one object for comunication !! DDSDataWriter or similar
  ddsSubscriber_m = new BulkDataNTDDSSubscriber(receiverStream_m->getDDSParticipant(), rcvCfg_m);

  ddsTopic_m = ddsSubscriber_m->createDDSTopic(topicName.c_str());

  dataReaderListener_m = new BulkDataNTReaderListener(topicName.c_str(), callback_m, skipReceivingDataAfterFailure);

  ddsDataReader_m= ddsSubscriber_m->createDDSReader(ddsTopic_m, dataReaderListener_m);
  ACS_LOG(LM_RUNTIME_CONTEXT, __FUNCTION__, (LM_INFO, "Receiver Flow: %s @ Stream: %s has been created.", flowName_m.c_str(), streamName.c_str()));

  //XXX Receiver should warn if something fails. errorStatusSupplier_p will be used
  if (maci::ContainerImpl::getContainer() != NULL ||  maci::SimpleClient::getInstance() != NULL) {
    errorStatusSupplier_p = new nc::SimpleSupplier(bulkdata::CHANNELNAME_ERR_PROP, NULL);
    ACS_LOG(LM_RUNTIME_CONTEXT, __FUNCTION__, (LM_INFO, "errorStatusSupplier_p created"));
  }

  if(errorStatusSupplier_p)
  {
      ACS_LOG(LM_RUNTIME_CONTEXT, __FUNCTION__, (LM_DEBUG, "Trying to send OK via NC"));
      bulkdata::errorStatusBlock err_sts;
      err_sts.status = bulkdata::OK;
      err_sts.timestamp = ::getTimeStamp();
      err_sts.flow = flowName;
      errorStatusSupplier_p->publishData<bulkdata::errorStatusBlock>(err_sts);
      ACS_LOG(LM_RUNTIME_CONTEXT, __FUNCTION__, (LM_DEBUG, "OK sended sucesfully"));
  }
}//BulkDataNTReceiverFlow


BulkDataNTReceiverFlow::~BulkDataNTReceiverFlow()
{
	AUTO_TRACE(__PRETTY_FUNCTION__);
	std::string streamName = receiverStream_m->getName();

	receiverStream_m->removeFlowFromMap(flowName_m.c_str());

	// remove QoS from DDS factory if any
	receiverStream_m->removeDDSQoSProfile(rcvCfg_m);

	// this part can go to BulkDataNTDDSPublisher, anyway we need to refactor
	DDS::DomainParticipant *participant = receiverStream_m->getDDSParticipant();
	if (participant!=0)
	{
		ddsSubscriber_m->destroyDDSReader(ddsDataReader_m);
		ddsDataReader_m = 0;
		delete dataReaderListener_m;

		ddsSubscriber_m->destroyDDSTopic(ddsTopic_m);
		ddsTopic_m = 0;
	}
	else
	{
		ACS_SHORT_LOG((LM_ERROR, "Problem deleting data reader and topic because participant is NULL"));
	}
	delete ddsSubscriber_m;
  callback_m->setReceiverFlow(0);
	if (releaseCB_m) delete callback_m;

	ACS_LOG(LM_RUNTIME_CONTEXT, __FUNCTION__, (LM_INFO, "Receiver Flow: %s @ stream: %s has been destroyed.", flowName_m.c_str(), streamName.c_str()));

  //XXX
  if (errorStatusSupplier_p != nullptr)
  {
      errorStatusSupplier_p->disconnect();
      errorStatusSupplier_p=nullptr;
      ACS_LOG(LM_RUNTIME_CONTEXT, __FUNCTION__, (LM_DEBUG, "errorStatusSupplier_p deleted"));
  }

}//~BulkDataNTReceiverFlow


void BulkDataNTReceiverFlow::setReceiverName(char* recvName)
{
	AUTO_TRACE(__PRETTY_FUNCTION__);
	std::string oldReceiverName = callback_m->getReceiverName();
	callback_m->setReceiverName(receiverStream_m->getReceiverName());
	ACS_LOG(LM_RUNTIME_CONTEXT, __PRETTY_FUNCTION__, (LM_DEBUG, "Receiver name on callback for flow: %s on steam: %s has been changed from: %s to %s",
			flowName_m.c_str(), receiverStream_m->getName().c_str(),
			oldReceiverName.c_str(), recvName
		));
}//setReceiverName

void AcsBulkdata::BulkDataNTReceiverFlow::enableCallingCB()
{
	AUTO_TRACE(__PRETTY_FUNCTION__);
    try{
        dataReaderListener_m->enableCallingCB();
    }catch(...){
        bulkdata::errorStatusBlock err_sts;
        err_sts.status = bulkdata::BAD_RECEIVER;
        err_sts.timestamp = ::getTimeStamp();
        err_sts.flow =  callback_m->getFlowName();
        if (errorStatusSupplier_p != nullptr) {
            errorStatusSupplier_p->publishData<bulkdata::errorStatusBlock>(err_sts);
        }
    }
}


void AcsBulkdata::BulkDataNTReceiverFlow::disableCallingCB()
{
	AUTO_TRACE(__PRETTY_FUNCTION__);
    try{
        dataReaderListener_m->disableCallingCB();
    }catch(...){
        bulkdata::errorStatusBlock err_sts;
        err_sts.status = bulkdata::BAD_RECEIVER;
        err_sts.timestamp = ::getTimeStamp();
        err_sts.flow = callback_m->getFlowName();
        if (errorStatusSupplier_p != nullptr) {
            errorStatusSupplier_p->publishData<bulkdata::errorStatusBlock>(err_sts);
        }
    }

}

void AcsBulkdata::BulkDataNTReceiverFlow::dumpStatistics()
{
DDS::SampleLostStatus sampleLost;
  DDS::RequestedDeadlineMissedStatus requestedDeadlineMissed;
  DDS::SampleRejectedStatus sampleRejected;
  DDS::RequestedIncompatibleQosStatus requestedIncompatibleQos;

  ddsDataReader_m->get_sample_lost_status(sampleLost);
  ddsDataReader_m->get_requested_deadline_missed_status(requestedDeadlineMissed);
  ddsDataReader_m->get_sample_rejected_status(sampleRejected);
  ddsDataReader_m->get_requested_incompatible_qos_status(requestedIncompatibleQos);

  std::string sampleRejectedLastReason;
  switch(sampleRejected.last_reason)
  {
    case DDS::SampleRejectedStatusKind::NOT_REJECTED:
      sampleRejectedLastReason = "NOT REJECTED";
      break;
    case DDS::SampleRejectedStatusKind::REJECTED_BY_INSTANCES_LIMIT:
      sampleRejectedLastReason = "REJECTED BY INSTANCES LIMIT";
      break;
    case DDS::SampleRejectedStatusKind::REJECTED_BY_SAMPLES_LIMIT:
      sampleRejectedLastReason = "REJECTED BY SAMPLES LIMIT";
      break;
    case DDS::SampleRejectedStatusKind::REJECTED_BY_SAMPLES_PER_INSTANCE_LIMIT:
      sampleRejectedLastReason = "REJECTED BY SAMPLES PER INSTANCE LIMIT";
      break;
    default:
      sampleRejectedLastReason = "NOT IMPLEMENTED";
      break;

  }

  std::stringstream msg;
  msg << "DataReader status for flow: " << flowName_m.c_str() << std::endl
      << "Deadline missed: " << requestedDeadlineMissed.total_count << " last change: " << requestedDeadlineMissed.total_count_change << std::endl
      << "Sample lost: " << sampleLost.total_count << " last change: " << sampleLost.total_count_change << std::endl
      << "Requested incompatible Qos: " << requestedIncompatibleQos.total_count << " last change: " << requestedIncompatibleQos.total_count_change << std::endl
      << "Samples rejected: " << sampleRejected.total_count << " last change: " << sampleRejected.total_count_change << " last reason: " << sampleRejectedLastReason << std::endl;

  LOG_TO_DEVELOPER(LM_DEBUG,msg.str().c_str());

}//void dumpStatistics()

/*___oOo___*/
