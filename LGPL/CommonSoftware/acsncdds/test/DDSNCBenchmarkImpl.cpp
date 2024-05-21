#include <vltPort.h>
#include <iostream>
#include <DDSPublisher.h>
#include <time.h>
#include "DDSNCBenchmarkImpl.h"
#include "NCBenchmarkTypeSupportImpl.h"

DDSNCBenchmarkSupplierImpl::DDSNCBenchmarkSupplierImpl(const ACE_CString &name, 
			maci::ContainerServices *containerServices) : 
		ACSComponentImpl(name, containerServices)
{
	ACS_TRACE("::DDSNCBenchmarkSupplierImpl::DDSNCBenchmarkSupplierImpl");
}

void DDSNCBenchmarkSupplierImpl::runTest(::CORBA::ULong freq,
		::CORBA::ULong duration) throw (::CORBA::SystemException)
{
	ACS_TRACE("DDSNCBenchmarkSupplierImpl::runTest");
//	ACS_NEW_DDS_PUBLISHER(pub_p, NC_BENCHMARK::Message, 
//			NC_BENCHMARK::CHANNEL_NAME);
//
    pub_p = new ddsnc::DDSPublisher(NC_BENCHMARK::CHANNEL_NAME, "profileTest", NC_BENCHMARK::DOMAIN_ID);
    sleep(1); //wait 1 second for RTPS discovery to announce this participant

	struct timeval time;
	NC_BENCHMARK::Message m;
	m.data.length(8192);

	for(unsigned int i=0;i<duration;i++){
		m.seqnum=i;
		gettimeofday(&time,NULL);
		m.time= (long long)time.tv_sec*1000000L + time.tv_usec;
		PUBLISH_DATA(pub_p, NC_BENCHMARK::Message, m);
		if(freq!=0)
			usleep((long)(1000000/freq));
	}

	sleep(5);
	pub_p->disconnect();
//	delete pub_p;

}

DDSNCBenchmarkSupplierImpl::~DDSNCBenchmarkSupplierImpl()
{
  delete pub_p;

}

void DDSNCBenchmarkSupplierImpl::cleanUp()
{
//	ddsnc::DDSHelper::cleanUp();
}


/* --------------- [ MACI DLL support functions ] -----------------*/
#include <maciACSComponentDefines.h>
MACI_DLL_SUPPORT_FUNCTIONS(DDSNCBenchmarkSupplierImpl)
/* ----------------------------------------------------------------*/

