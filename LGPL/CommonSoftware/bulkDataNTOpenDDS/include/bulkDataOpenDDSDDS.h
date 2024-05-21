#ifndef _BULK_DATA_NT_DDS_H_
#define _BULK_DATA_NT_DDS_H_
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
* "@(#) $Id: bulkDataNTDDS.h,v 1.14 2012/05/21 13:04:55 bjeram Exp $"
*
* who       when      what
* --------  --------  ----------------------------------------------
* bjeram  2011-04-19  created
*/

#ifndef __cplusplus
#error This is a C++ include file and cannot be used from plain C
#endif

//RTI
#ifndef RTI_UNIX
#define RTI_UNIX
#endif
#ifndef RTI_LINUX
#define RTI_LINUX
#endif

//OpenDDS generated
#include "bulkDataOpenDDSTypeSupportImpl.h"

//OpenDDS library
#include <ace/Log_Msg.h>

#include <dds/DdsDcpsInfrastructureC.h>
#include <dds/DdsDcpsSubscriptionC.h>
#include <dds/DCPS/DomainParticipantImpl.h>

#include <dds/DCPS/Marked_Default_Qos.h>
#include <dds/DCPS/Service_Participant.h>
#include <dds/DCPS/WaitSet.h>

#include "dds/DCPS/StaticIncludes.h"

#include <logging.h>
#include <ACSErrTypeCommon.h>
#include "ACS_DDS_Errors.h"
#include "bulkDataOpenDDSConfiguration.h"

namespace AcsBulkdata
{

extern const char* dataType2String[];

/**
 * class responsible for all DDS related details
 */
class BulkDataNTDDS
{
public:

	/**
	 * Constructor
	 * @param participant participant
	 * @param ddsCfg generic DDS configuration
	 */
	BulkDataNTDDS(DDS::DomainParticipant* participant, const DDSConfiguration &ddsCfg);

	/**
	 * Destructor
	 */
	virtual ~BulkDataNTDDS();

	/**
	 * It creates topic (and register the type) with name topicName using participant given in CTOR
	 * @param topicName
	 * @return
	 */
	DDS::Topic* createDDSTopic(const char* topicName);

	/**
	 * It destroys topic and unregisters the type
	 * @param topic
	 */
	void destroyDDSTopic(DDS::Topic *topic);

protected:

	DDS::DomainParticipant* participant_m; /// pointer to participant

	const DDSConfiguration ddsCfg_m;  /// configuration

	std::string topicName_m; /// name of topic (it is set when createDDSTopic

  ACSBulkData::BulkDataNTFrameTypeSupport_var tsi_m; /// type support var to store TypeSupportImpl

	/// disable default - empty constructor
	BulkDataNTDDS();
	/// ALMA C++ coding standards state assignment operators should be disabled.
	void operator=(const BulkDataNTDDS&);
	/// ALMA C++ coding standards state copy constructors should be disabled.
	BulkDataNTDDS(const BulkDataNTDDS&);
};//class BulkDataNTDDS

}

#endif
