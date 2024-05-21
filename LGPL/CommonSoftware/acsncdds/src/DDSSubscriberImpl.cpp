#include <DDSSubscriber.h>
#include <ACSErrTypeCommon.h>
#include <iostream>
#include <acsddsncCDBProperties.h>

using namespace ddsnc;

DDSSubscriber::DDSSubscriber(CORBA::String_var channel_name, CORBA::String_var qosProfile, DDS::DomainId_t id):
	DDSHelper(channel_name, qosProfile, id)
{
}

void DDSSubscriber::createSubscriber()
{
	ACS_TRACE(__PRETTY_FUNCTION__);

  stringstream msg;
  msg << "Creating Subscriber with partition: "
      << m_partitionName; 
  LOG_TO_DEVELOPER(LM_INFO, msg.str());

  // Check if there is subscriber QoS in CDB 
  DDS::ReturnCode_t retcode;
	participant->get_default_subscriber_qos(subQos);
  retcode = m_cdbprops_p->get_subscriber_qos(subQos,m_qosProfileName.c_str());
  if (retcode != DDS::RETCODE_OK)
  {
    stringstream msg;
    msg << "Subscriber QoS not found for profile <"
        << m_qosProfileName << "> and topic. Using default QoS.";
    LOG_TO_DEVELOPER(LM_INFO, msg.str());
  }

	participant->get_default_subscriber_qos(subQos);

  // Create subscriber
	sub = participant->create_subscriber(subQos,
			DDS::SubscriberListener::_nil(),
			OpenDDS::DCPS::DEFAULT_STATUS_MASK);

  // Check if subscriber was created
	if(CORBA::is_nil(sub.in()))
  {
		ACSErrTypeCommon::GenericErrorExImpl ex(__FILE__,
                                            __LINE__,
                                            __PRETTY_FUNCTION__
                                            );
    std::string msg = "Create subscriber failed.";
		ex.setErrorDesc(msg.c_str());
		ex.log();
		throw ex.getGenericErrorEx();
	}
	
}

void DDSSubscriber::initializeDataReader()
{
  ACS_TRACE(__PRETTY_FUNCTION__);

  LOG_TO_DEVELOPER(LM_INFO, ("Initializing datareader"));
	
  OpenDDS::DCPS::SubscriberImpl * subImpl = dynamic_cast<OpenDDS::DCPS::SubscriberImpl*>(sub.in());
	if (subImpl == 0)
  {
		ACSErrTypeCommon::GenericErrorExImpl ex(__FILE__,
                                            __LINE__,
                                            __PRETTY_FUNCTION__
                                            );
    std::string msg = "Failed to obtain subscriber servant.";
		ex.setErrorDesc(msg.c_str());
		ex.log();
		throw ex.getGenericErrorEx();
	}
 
  // Check if there is a datareader qos in CDB 
  // It not implement opinc name in qos get method
  DDS::ReturnCode_t retcode;
  subImpl->get_default_datareader_qos(drQos);
  retcode = m_cdbprops_p->get_datareader_qos(drQos,
                                             m_qosProfileName.c_str(),
                                             0);
  if (retcode != DDS::RETCODE_OK)
  {
    stringstream msg;
    msg << "Datareader QoS not found for profile <"
        << m_qosProfileName << "> and topic <"
        << m_topicName << ">. Using default QoS.";
    LOG_TO_DEVELOPER(LM_INFO, msg.str());
  }

  subImpl->get_default_datareader_qos(drQos);
  // Create datareader
	dr = sub->create_datareader(topic.in(),
			                        drQos,
                              DDS::DataReaderListener::_nil(),
                              OpenDDS::DCPS::DEFAULT_STATUS_MASK);
  
  
  // Check if datawriter was created
	if(CORBA::is_nil(dr.in())){
		ACSErrTypeCommon::GenericErrorExImpl ex(__FILE__,
                                            __LINE__,
                                            __PRETTY_FUNCTION__
                                            );
    std::string msg = "Create datareader failed.";
		ex.setErrorDesc(msg.c_str());
		ex.log();
		throw ex.getGenericErrorEx();
	}
}

void DDSSubscriber::consumerReady()
{
	ACS_TRACE("DDSSubscriber::consumerReady");

	DDS::DataReader_var dr = sub->create_datareader(topic.in(),
			drQos, listener.in(), OpenDDS::DCPS::DEFAULT_STATUS_MASK);
	if(CORBA::is_nil(dr.in())){
		ACS_STATIC_LOG(LM_FULL_INFO, "DDSSubscriber::consumerReady", (LM_ERROR,
				 "create_datareader failed"));
	}
	initialized=true;
}

