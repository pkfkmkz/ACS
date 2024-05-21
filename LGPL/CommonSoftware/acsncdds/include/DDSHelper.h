#ifndef _DDS_HELPER_H_
#define _DDS_HELPER_H_

#include <iostream>
#include <string.h>
#include <loggingACEMACROS.h>
#include <dds/DCPS/Service_Participant.h>
#include <dds/DCPS/Marked_Default_Qos.h>

// For transport handle instances and configuration 
#include <dds/DCPS/transport/framework/TransportRegistry.h>

// Forward declaration
namespace ddsnc {
  class CDBProperties;
}

using namespace std;

namespace ddsnc{

/**
 * Base class for ACSNCDDS, this class contains all the common functionality
 * offered by DDS publishers and DDS subscribers. If it wanted to use this 
 * class, it must be inherited.
 *
 * @author Jorge Avarias <javarias[at]inf.utfsm.cl>
 * @author Danilo C. Zanella <danilo.zanella[at]iag.usp.br>
 * @see DDSPublisher
 * @see DDSSubscriber
 */	
	
	class DDSHelper{
		private:
		void setTopicName(const char* topicName);
		void initRTPS();
		/*int argc;
		const ACE_TCHAR* argv[];*/
		
    		static int instances_;
    
    		// Transport configuration for RTPS
    		// Store transport config
		OpenDDS::DCPS::TransportConfig_rch m_config;
    		// Store transport instance
		OpenDDS::DCPS::TransportInst_rch m_inst;
    
    		// Domain Participant Section
		DDS::DomainId_t m_domainId;
		DDS::DomainParticipantFactory_ptr dpf;
    		DDS::DomainParticipantQos dpQos;


		protected:
    		CDBProperties * m_cdbprops_p;
    		string m_channelName;
    		string m_qosProfileName;
    		string m_topicName;
    		string m_partitionName;

    		// Topic Section  
    		DDS::Topic_var topic;
		DDS::TopicQos topicQos;

		DDS::DomainParticipant_var participant;
		static bool initialized; /**< a flag that shows the initialization status 
								  of the class*/

		/**
		 * Constructor for DDSHelper
		 *
		 * @param channelName the name of the channel that will be mapped to a
		 * partition.
     		*
		* @param qosProfileName the name of the profile used to set qos
     		*
     		* @param id DDS domain id value value between 0~231, following OpenDDS
     		* documentation
		 *
		 */
    		DDSHelper(const char * channelName, const char * qosProfileName, DDS::DomainId_t id);
		virtual ~DDSHelper();

		/**
		 * Destructor for DDSHelper before free the varibales it call to
		 * disconnect method, if disconnect method was called, the
		 * destructor only free the variables.
		 *
		 * @see disconnect()
		 */
		int createParticipant();

		/**
		 * Initialize the topic and register the type supported by the topic, 
		 * this method must be called after creation of the
		 * participant, initialization of the transport, creation of the 
		 * Publisher or Subscriber and initialization of the type support
		 *
		 * @param topicName the topicName
		 * @param typeName the type to be registered in the topic, the topic
		 * must be in CORBA type name format
		 */
		void initializeTopic(const char* topicName, const char * typeName);
		
		void initializeTopic(const char * typeName);
		
		/**
		 * Set partition name based on the channel name 
		 *
		 * @param partitionName the name of the partition
		 */
		void setPartitionName(const char* partitionName);
		
		public:
		
    		DDS::DomainId_t getDomainID();

		/**
		 * Get topic name from the registered topic
		 */
    		const char * getTopicName();
		/**
		 * Disconnect method will destroy all the DDS entities initilizated, 
		 * it will
		 * release the trasport factory, shutdown the DDS participant service
		 * and set the status of the class as not initilizated.
		 * This method should be used when you want to destroy a Publisher or 
		 * Subscriber object that inherit this class.
		 *
		 * @see ~DDSHelper()
		 */
		void disconnect();

		/**
     		* CleanUp method will release the transport implementation and configuration
     		* and shutdown the Service Participant
     		* 
		 */
		void cleanUp();

		/**
		 * Get name of the channel
		 */
		const char * getChannelName();

	};
}

#endif
