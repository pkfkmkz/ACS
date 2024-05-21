#include <DDSPublisher.h>
#include <time.h>
#include "NCBenchmarkTypeSupportImpl.h"

int main(int argc, char **argv)
{
  ddsnc::DDSPublisher * pub = new ddsnc::DDSPublisher(NC_BENCHMARK::CHANNEL_NAME, "profileTest",NC_BENCHMARK::DOMAIN_ID);

	struct timeval time;
	NC_BENCHMARK::Message m;

	for(int i=0;i<10;i++){
		m.seqnum=i;
		gettimeofday(&time,NULL);
		m.time= (long long)time.tv_sec*1000000L + time.tv_usec;
		PUBLISH_DATA(pub, NC_BENCHMARK::Message,m);
		sleep(1);
	}

	pub->disconnect();
	delete pub;

}
