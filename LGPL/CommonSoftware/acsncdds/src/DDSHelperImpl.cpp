#include <DDSHelper.h>
#include <ace/Service_Config.h>
#include <string.h>
#include <stdlib.h>
#include <maciHelper.h>
#include <loggingACEMACROS.h>

#include <ace/Init_ACE.h>
#include <dds/DCPS/RTPS/RtpsDiscovery.h>
#include <dds/DCPS/transport/framework/TransportRegistry.h>
#include <dds/DCPS/QOS_XML_Handler/dds_qos.hpp>

#include <ACSErrTypeCommon.h>
#include <acsddsncCDBProperties.h>


using namespace ddsnc;

static bool factories_init = false;
bool DDSHelper::initialized = false;
int DDSHelper::instances_ = 0;

DDSHelper::DDSHelper(const char * channelName, const char * qosProfileName, DDS::DomainId_t id) :
  m_domainId(id),
  m_cdbprops_p(new CDBProperties()),
  m_channelName(channelName),
  m_qosProfileName(qosProfileName)
{
  ACS_TRACE(__PRETTY_FUNCTION__);

  // Parse CDB configuration by respective channel name
  m_cdbprops_p->parseConfig(channelName);

  initRTPS();
	
}

void DDSHelper::initRTPS()
{
  // Create a static initializer: IMPORTANT
	OpenDDS::RTPS::RtpsDiscovery::StaticInitializer initialize_rtps;
	TheServiceParticipant->set_default_discovery(OpenDDS::DCPS::Discovery::DEFAULT_RTPS);

    // Initialize DomainParticipantFactory

	dpf = TheParticipantFactory;

  // Create config
  // They need to be different inside of each process
  std::stringstream ss;
  ss << "Config" << instances_;
  const std::string transportConfigName = ss.str();
  ss.str("");
  ss << "Inst" << instances_;
  const std::string transportInstanceName = ss.str();

	m_config = TheTransportRegistry->get_config(transportConfigName);
	
	if (m_config.is_nil())
	{
		m_config = TheTransportRegistry->create_config(transportConfigName);
	}
	
	if (m_config->instances_.empty())
	{
		m_inst = TheTransportRegistry->get_inst(transportInstanceName);
		if (m_inst.is_nil())
		{
      LOG_TO_DEVELOPER(LM_INFO, "No transport instance in config! Creating it...");
			m_inst = TheTransportRegistry->create_inst(transportInstanceName, "rtps_udp");

      // For Debug
			//inst->dump();
		}
		m_config->instances_.push_back(m_inst);
	}
	TheTransportRegistry->global_config(m_config);
		
	TheServiceParticipant->set_repo_domain(m_domainId, OpenDDS::DCPS::Discovery::RepoKey(OpenDDS::DCPS::Discovery::DEFAULT_RTPS),true);

  TheServiceParticipant->get_default_discovery();
	
	TheServiceParticipant->set_default_discovery(OpenDDS::DCPS::Discovery::RepoKey(OpenDDS::DCPS::Discovery::DEFAULT_RTPS));
	
	factories_init = true;
	initialized=false;
  instances_++;
	setPartitionName(m_channelName.c_str());
}

int DDSHelper::createParticipant()
{
	ACS_TRACE(__PRETTY_FUNCTION__);

  {
    stringstream msg;
    msg << "Creating domain participant, using domain ID: "
        << m_domainId;
    LOG_TO_DEVELOPER(LM_INFO, msg.str());
  }
 
  // Check if there is a domain participant qos in CDB
  DDS::ReturnCode_t retcode;
	dpf->get_default_participant_qos(dpQos);
  retcode = m_cdbprops_p->get_participant_qos(dpQos,
                                        ACE_TEXT_CHAR_TO_TCHAR(m_qosProfileName.c_str()));

  if (retcode != DDS::RETCODE_OK)
  {
    stringstream msg;
    msg << "Participant QoS not found for profile <"
        << m_qosProfileName << ">. Using default QoS.";
    LOG_TO_DEVELOPER(LM_INFO, msg.str());
  }

  participant = dpf->create_participant(m_domainId,
			                                  dpQos,
			                                  DDS::DomainParticipantListener::_nil(),
			                                  OpenDDS::DCPS::DEFAULT_STATUS_MASK);

	if (CORBA::is_nil(participant.in())){
		ACSErrTypeCommon::GenericErrorExImpl ex(__FILE__, __LINE__,
				__PRETTY_FUNCTION__);
        std::string msg = "Failed to create a participant.";
		ex.setErrorDesc(msg.c_str());
		ex.log();
		throw ex.getGenericErrorEx();
	}
	
	LOG_TO_DEVELOPER(LM_INFO, "Created the participant.");
	
	return 0;
}

DDS::DomainId_t DDSHelper::getDomainID()
{
  ACS_TRACE(__PRETTY_FUNCTION__);

  return m_domainId;
}

void DDSHelper::setTopicName(const char* topicName)
{
  ACS_TRACE(__PRETTY_FUNCTION__);

	m_topicName = topicName;
}

const char * DDSHelper::getTopicName()
{
  ACS_TRACE(__PRETTY_FUNCTION__);

  return m_topicName.c_str();
}

void DDSHelper::initializeTopic(const char* topicName, const char * typeName)
{
  ACS_TRACE(__PRETTY_FUNCTION__);

  stringstream msg;
  msg << "Initializing topic: <"
      << topicName
      << "> with type: <"
      << typeName 
      << "> in profile <"
      << m_qosProfileName
      << ">";
  LOG_TO_DEVELOPER(LM_INFO,msg.str());
     
  // Check if there is a topic in CDB
  // It not implements topic name in method get_topic_qos
  DDS::ReturnCode_t retcode;
	participant->get_default_topic_qos(topicQos);
  retcode = m_cdbprops_p->get_topic_qos(topicQos,
                                        ACE_TEXT_CHAR_TO_TCHAR(m_qosProfileName.c_str()),
                                        0);

  if (retcode != DDS::RETCODE_OK)
  {
    stringstream msg;
    msg << "Topic QoS not found for profile <"
        << m_qosProfileName << "> and topic <"
        << topicName << ">. Using default QoS.";
    LOG_TO_DEVELOPER(LM_INFO, msg.str());
  }

  // Create topic
	topic=participant->create_topic(topicName, typeName,
			topicQos, DDS::TopicListener::_nil(),
			OpenDDS::DCPS::DEFAULT_STATUS_MASK);
  
  // Check if topic was created
	if (CORBA::is_nil(topic.in())){
		ACSErrTypeCommon::GenericErrorExImpl ex(__FILE__,
                                            __LINE__,
                                            __PRETTY_FUNCTION__
                                            );
    std::string msg = "Failed to create a topic.";
		ex.setErrorDesc(msg.c_str());
		ex.log();
		throw ex.getGenericErrorEx();
	}
	
  setTopicName(topicName);
}

void DDSHelper::initializeTopic(const char * typeName)
{
	std::string topicStr (typeName);
	int f = topicStr.find_first_of(":");
	string topicName = topicStr.substr(f+2, topicStr.length()-f-2).c_str();
	initializeTopic(topicName.c_str(), typeName);
}

void DDSHelper::setPartitionName(const char* partitionName){
	m_partitionName = partitionName;
}

void DDSHelper::disconnect()
{
	ACS_TRACE(__PRETTY_FUNCTION__);
	if(initialized==true){
		TheTransportRegistry->remove_inst(m_config->instances_.back());
		TheTransportRegistry->remove_config(m_config);
		participant->delete_contained_entities();
		dpf->delete_participant(participant.in());
		//TheTransportRegistry->remove_inst(config->instances_.back());
		initialized=false;
	}
}

DDSHelper::~DDSHelper()
{
	ACS_TRACE(__PRETTY_FUNCTION__);
	disconnect();
  delete m_cdbprops_p;
	//free(partitionName);
	//free(topicName);
}

void DDSHelper::cleanUp()
{
	ACS_TRACE(__PRETTY_FUNCTION__);

  LOG_TO_DEVELOPER(LM_INFO, "Release TransportRegistry and and shutdown TheServiceParticipant");

	if (factories_init){
		TheTransportRegistry->release();
		TheServiceParticipant->shutdown();
		//ACE_Thread_Manager::instance()->wait();
		//ACE::fini();
	}
}

const char * DDSHelper::getChannelName()
{
  return m_channelName.c_str();
}
