#include <iostream>
#include "DDSPublisher.h"
#include <ACSErrTypeCommon.h>

using namespace ddsnc;

void DDSPublisher::initialize()
{
  ACS_TRACE(__PRETTY_FUNCTION__);

  // Create participant
	createParticipant();
	if (CORBA::is_nil (participant.in()))
  {
		ACSErrTypeCommon::GenericErrorExImpl ex(__FILE__,
                                            __LINE__,
                                            __PRETTY_FUNCTION__
                                            );
    std::string msg = "Participant is nil.";
		ex.setErrorDesc(msg.c_str());
		ex.log();
		throw ex.getGenericErrorEx();
  }

  // Check if there is publisher QoS in CDB 
  DDS::ReturnCode_t retcode;
	participant->get_default_publisher_qos(pubQos);
  retcode = m_cdbprops_p->get_publisher_qos(pubQos,m_qosProfileName.c_str());
  if (retcode != DDS::RETCODE_OK)
  {
    stringstream msg;
    msg << "Publisher QoS not found for profile <"
        << m_qosProfileName << ">. Using default QoS.";
    LOG_TO_DEVELOPER(LM_INFO, msg.str());
  }

  // Create publisher
	createPublisher();

}

void DDSPublisher::initializeDataWriter()
{
  ACS_TRACE(__PRETTY_FUNCTION__);

  LOG_TO_DEVELOPER(LM_INFO, "Initializing datawriter");
 
  OpenDDS::DCPS::PublisherImpl * pubImpl= dynamic_cast<OpenDDS::DCPS::PublisherImpl*>(pub.in());
	if(pubImpl == 0)
  {
		ACSErrTypeCommon::GenericErrorExImpl ex(__FILE__,
                                            __LINE__,
                                            __PRETTY_FUNCTION__
                                            );
    std::string msg = "Failed to obtain publisher servant.";
		ex.setErrorDesc(msg.c_str());
		ex.log();
		throw ex.getGenericErrorEx();
	}

  // get_datawriter qos
  // It not implements topic name
  DDS::ReturnCode_t retcode;
  pubImpl->get_default_datawriter_qos(dwQos);
  retcode = m_cdbprops_p->get_datawriter_qos(dwQos,
                                             m_qosProfileName.c_str(),
                                             0);
  
  // Check if there is a datawriter qos in CDB 
  if (retcode != DDS::RETCODE_OK)
  {
    stringstream msg;
    msg << "Datawriter QoS not found for profile <"
        << m_qosProfileName << "> and topic <"
        << m_topicName << ">. Using default QoS.";
    LOG_TO_DEVELOPER(LM_INFO, msg.str());
  }

  pubImpl->get_default_datawriter_qos(dwQos);
  // Create datawriter
	dw = pub->create_datawriter(topic.in(),
			                        dwQos,
                              DDS::DataWriterListener::_nil(),
                              OpenDDS::DCPS::DEFAULT_STATUS_MASK);
  
  
  // Check if datawriter was created
	if(CORBA::is_nil(dw.in())){
		ACSErrTypeCommon::GenericErrorExImpl ex(__FILE__,
                                            __LINE__,
                                            __PRETTY_FUNCTION__
                                            );
    std::string msg = "Create datawriter failed.";
		ex.setErrorDesc(msg.c_str());
		ex.log();
		throw ex.getGenericErrorEx();
	}
}

int DDSPublisher::createPublisher()
{
  ACS_TRACE(__PRETTY_FUNCTION__);

  stringstream msg;
  msg << "Creating Publisher with partition: "
      << m_partitionName; 
  LOG_TO_DEVELOPER(LM_INFO, msg.str());
  
  // get_publisher
  // It not implements topic name
  DDS::ReturnCode_t retcode;
  participant->get_default_publisher_qos(pubQos);
  retcode = m_cdbprops_p->get_publisher_qos(pubQos,
                                             m_qosProfileName.c_str());

  if (retcode != DDS::RETCODE_OK)
  {
    stringstream msg;
    msg << "Publisher QoS not found for profile <"
        << m_qosProfileName << ">. Using default QoS.";
    LOG_TO_DEVELOPER(LM_INFO, msg.str());
  }

  participant->get_default_publisher_qos(pubQos);
  // Create publisher
	pub = participant->create_publisher(pubQos,
			DDS::PublisherListener::_nil(),
			OpenDDS::DCPS::DEFAULT_STATUS_MASK);

  // Check if publisher was created
	if(CORBA::is_nil(pub.in()))
  {
		ACSErrTypeCommon::GenericErrorExImpl ex(__FILE__,
                                            __LINE__,
                                            __PRETTY_FUNCTION__
                                            );
    std::string msg = "Create publisher failed.";
		ex.setErrorDesc(msg.c_str());
		ex.log();
		throw ex.getGenericErrorEx();
	}

	return 0;
}
