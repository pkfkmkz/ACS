#include <maciSimpleClient.h>
#include <iostream>
#include <DDSSubscriber.h>
#include <NCBenchmarkTypeSupportImpl.h>

void handlerFunction(NC_BENCHMARK::Message m, void *other)
{
	struct timeval time;
	gettimeofday(&time, NULL);
	long long t = (long long)time.tv_sec*1000000L + time.tv_usec;
	usleep(1000000);
	std::cout << m.seqnum << "," << t - m.time << std::endl;

}

int main(int argc, char**argv)
{
	//maci::SimpleClient client;
	//client.init(argc,argv);
	//client.login();
	
	ddsnc::DDSSubscriber *sub_p;

	ACS_NEW_DDS_SUBSCRIBER(sub_p, NC_BENCHMARK::Message,NC_BENCHMARK::DOMAIN_ID,
		NC_BENCHMARK::CHANNEL_NAME, "profileTest", &handlerFunction, (void *)0);
	sub_p->consumerReady();

	sleep(200);
		
	sub_p->disconnect();
	delete sub_p;

	//client.logout();
	//ACE_OS::sleep(5);
	
	return 0;
}
